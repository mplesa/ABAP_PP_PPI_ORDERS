*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
CLASS lcl_c_nav DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_c.
    CONSTANTS: co_table_icon       TYPE tv_image VALUE icon_database_table,
               co_empty_table_icon TYPE tv_image VALUE icon_database_table_ina,
               co_entries_icon     TYPE tv_image VALUE icon_table_settings.

    METHODS: constructor IMPORTING ir_container        TYPE REF TO cl_gui_container
                                   ir_detail_container TYPE REF TO cl_gui_container
                                   ir_order            TYPE REF TO zif_order.
  PRIVATE SECTION.
    DATA: mr_tree             TYPE REF TO lcl_tree,
          mr_order            TYPE REF TO zif_order,
          mr_container        TYPE REF TO cl_gui_container,
          mr_detail_container TYPE REF TO cl_gui_container,
          mr_c_table          TYPE REF TO lcl_c_table.
    METHODS: build_navigation IMPORTING ir_order TYPE REF TO zif_order,
      set_handlers IMPORTING if_activation TYPE flag,
      add_order_tables IMPORTING ir_parent TYPE REF TO lcl_tree_item
                                 ir_order  TYPE REF TO zif_order,
      add_order_table IMPORTING ir_parent TYPE REF TO lcl_tree_item
                                if_table  TYPE string
                                ir_order  TYPE REF TO zif_order,
      add_operation_tables IMPORTING ir_parent    TYPE REF TO lcl_tree_item
                                     ir_operation TYPE REF TO zif_operation,
      add_operation_table IMPORTING ir_parent    TYPE REF TO lcl_tree_item
                                    ir_operation TYPE REF TO zif_operation
                                    if_table     TYPE string,

      handle_clicked_item IMPORTING ir_item TYPE REF TO lcl_tree_item,
      on_node_double_click FOR EVENT node_double_click OF cl_gui_alv_tree
        IMPORTING node_key,
      on_item_double_click FOR EVENT item_double_click OF cl_gui_alv_tree
        IMPORTING fieldname node_key,
      on_item_context_menu_request FOR EVENT item_context_menu_request OF cl_gui_alv_tree
        IMPORTING fieldname menu node_key,
      on_node_context_menu_request FOR EVENT node_context_menu_request OF cl_gui_alv_tree
        IMPORTING menu node_key,
      on_item_context_menu_selected FOR EVENT item_context_menu_selected OF cl_gui_alv_tree
        IMPORTING fcode fieldname node_key,
      on_node_context_menu_selected FOR EVENT node_context_menu_selected OF cl_gui_alv_tree
        IMPORTING fcode node_key.

ENDCLASS.
CLASS lcl_c_nav IMPLEMENTATION.
  METHOD on_item_context_menu_request.
    on_node_context_menu_request( menu     = menu
                                  node_key = node_key ).
  ENDMETHOD.
  METHOD on_node_context_menu_request.
    DATA: lr_m    TYPE REF TO lif_m,
          lr_item TYPE REF TO lcl_tree_item.

    lr_item = mr_tree->get_item( node_key ).

    TRY .
        lr_m ?= lr_item->mr_object.

        lr_m->get_functions( IMPORTING et_functions = DATA(lt_functions) ).
        LOOP AT lt_functions ASSIGNING FIELD-SYMBOL(<ls_function>).
          menu->add_function( fcode = <ls_function>-fcode
                              text  = <ls_function>-text ).
        ENDLOOP.
      CATCH cx_sy_move_cast_error.

    ENDTRY.

  ENDMETHOD.
  METHOD on_item_context_menu_selected.
    on_node_context_menu_selected( fcode    = fcode
                                   node_key = node_key ).
  ENDMETHOD.
  METHOD on_node_context_menu_selected.
    DATA: lr_m    TYPE REF TO lif_m,
          lr_item TYPE REF TO lcl_tree_item.
    lr_item = mr_tree->get_item( node_key ).
    TRY .
        lr_m ?= lr_item->mr_object.
        lr_m->handle_function( fcode ).
        IF fcode = lcl_m_order=>co_prodversion.
          lif_c~refresh( ).
        ENDIF.
      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.
  METHOD set_handlers.
    SET HANDLER on_node_double_click FOR mr_tree ACTIVATION if_activation.
    SET HANDLER on_node_context_menu_request FOR mr_tree ACTIVATION if_activation.
    SET HANDLER on_node_context_menu_selected FOR mr_tree ACTIVATION if_activation.
    SET HANDLER on_item_double_click FOR mr_tree ACTIVATION if_activation.
    SET HANDLER on_item_context_menu_request  FOR mr_tree ACTIVATION if_activation.
    SET HANDLER on_item_context_menu_selected FOR mr_tree ACTIVATION if_activation.
  ENDMETHOD.

  METHOD handle_clicked_item.
    DATA: lr_table TYPE REF TO lif_table,
          lr_m     TYPE REF TO lif_m.
    TRY .
        lr_table ?= ir_item->mr_object.
        lr_table->rebuild( ).
        IF mr_c_table IS BOUND.

          mr_c_table->set_table( lr_table ).
        ELSE.
          CREATE OBJECT mr_c_table
            EXPORTING
              ir_container = mr_detail_container
              ir_table     = lr_table.
          mr_c_table->lif_c~display( ).
        ENDIF.
      CATCH cx_sy_move_cast_error.
        TRY .
            lr_m ?= ir_item->mr_object.
            lr_m->double_click( ).
          CATCH cx_sy_move_cast_error.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.
  METHOD on_node_double_click.
    DATA: lr_item TYPE REF TO lcl_tree_item.
    lr_item = mr_tree->get_item( node_key ).
    handle_clicked_item( lr_item ).
  ENDMETHOD.
  METHOD on_item_double_click.
    DATA: lr_item TYPE REF TO lcl_tree_item.
    lr_item = mr_tree->get_item( node_key ).
    handle_clicked_item( lr_item ).
  ENDMETHOD.
  METHOD constructor.
    mr_order = ir_order.
    mr_container = ir_container.
    mr_detail_container = ir_detail_container.
    CREATE OBJECT mr_tree EXPORTING ir_container = mr_container.
    build_navigation( mr_order ).
  ENDMETHOD.
  METHOD lif_c~display.
    mr_tree->display( ).
    set_handlers( abap_true ).
  ENDMETHOD.
  METHOD lif_c~refresh.
    mr_tree->refresh( ).
    build_navigation( mr_order ).
    lif_c~display( ).
  ENDMETHOD.
  METHOD lif_c~destroy.
    set_handlers( space ).
    mr_tree->free( ).
    mr_container->finalize( ).
  ENDMETHOD.
  METHOD build_navigation.
    DATA: lf_name           TYPE lvc_value,
          lf_icon           TYPE tv_image,
          lr_order          TYPE REF TO zif_order,
          lr_plano          TYPE REF TO zcl_order_plano,
          lr_operation      TYPE REF TO zif_operation,
          lr_item           TYPE REF TO lcl_tree_item,
          lr_order_item     TYPE REF TO lcl_tree_item,
          lr_operation_item TYPE REF TO lcl_tree_item.
*#create the order node
    lr_order_item = mr_tree->add_item( ).
    lf_icon = icon_order.
    lr_order_item->set_icon( lf_icon ).

    lr_order_item->set_is_folder( abap_true ).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ir_order->mf_plnid
      IMPORTING
        output = lf_name.

    lr_order_item->set_name( lf_name ).
    lr_order_item->set_expanded( abap_true ).
    DATA: lr_m_order TYPE REF TO lcl_m_order.
    CREATE OBJECT lr_m_order EXPORTING ir_order = ir_order.
    lr_order_item->set_object( lr_m_order ).
    IF ir_order->has_long_text( ) IS NOT INITIAL.
      lf_icon = icon_display_text.
      lr_order_item->set_2nd_icon( lf_icon ).
    ENDIF.

    add_order_tables( ir_parent = lr_order_item
                      ir_order  = ir_order ).

*#operation nodes all link to the order node
    LOOP AT ir_order->mt_operation_sequances INTO DATA(lr_sequance).
      DATA(lr_sequance_item) = mr_tree->add_item( if_related_node_key = lr_order_item->mf_node_key ).
      lf_icon = icon_routing_sequence.
      lr_sequance_item->set_icon( lf_icon ).
      lr_sequance_item->set_expanded( abap_true ).
      lr_sequance_item->set_is_folder( abap_true ).
      lr_sequance_item->set_object( lr_m_order ).
      CASE lr_sequance->ms_affl-flgat.
        WHEN zif_operation_sequance=>co_type-standard.
          lf_name = 'Stammfolge'(020) && ':' && lr_sequance->ms_affl-ltxa1.
          lr_sequance_item->set_name( lf_name ).
        WHEN zif_operation_sequance=>co_type-alternative.
          lf_name = 'alternative Folge'(021) && ':' && lr_sequance->ms_affl-ltxa1.
          lr_sequance_item->set_name( lf_name ).
        WHEN zif_operation_sequance=>co_type-parallel.
          lf_name = 'parallele Folge'(022) && ':' && lr_sequance->ms_affl-ltxa1.
          lr_sequance_item->set_name( lf_name ).
      ENDCASE.
      CLEAR lr_operation.
      DO.
        IF lr_operation IS NOT BOUND.
          TRY .
              lr_operation = lr_sequance->get_first_operation( ).
            CATCH zcx_operation_notfound.
              EXIT.
          ENDTRY.
        ENDIF.

        lr_operation_item = mr_tree->add_item( if_related_node_key = lr_sequance_item->mf_node_key ).
        lf_icon = icon_routing_operation.
        lr_operation_item->set_icon( lf_icon ).
*#suboperation or phase
        IF lr_operation->is_main_operation( ) IS INITIAL.
          lf_icon = icon_routing_ref_operation.
          lr_operation_item->set_icon( lf_icon ).
        ENDIF.

*#Display Longtest
        IF lr_operation->has_long_text( ) IS NOT INITIAL.
          lf_icon = icon_display_text.
          lr_operation_item->set_2nd_icon( lf_icon ).
        ENDIF.

        DATA: lr_m_operation TYPE REF TO lcl_m_operation.
        CREATE OBJECT lr_m_operation EXPORTING ir_operation = lr_operation.

        lr_operation_item->set_object( lr_m_operation ).

        CONCATENATE lr_operation->mf_vornr
                    '-'
                    lr_operation->ms_afvgd-ltxa1
               INTO lf_name SEPARATED BY space.
        lr_operation_item->set_name( lf_name ).
*#some nasty thing hannpening here:)))

        add_operation_tables( ir_parent    = lr_operation_item
                              ir_operation = lr_operation ).
        TRY .
            lr_operation = lr_operation->get_successor( ).
          CATCH zcx_no_successor.
            EXIT.
        ENDTRY.

      ENDDO.
    ENDLOOP.

    CHECK pa_virt IS NOT INITIAL.
    IF lr_m_order->mr_virtual IS BOUND.
      build_navigation( lr_m_order->mr_virtual ).
    ENDIF.

  ENDMETHOD.
  METHOD add_order_tables.
    DATA: lr_plano TYPE REF TO zcl_order_plano.

    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_mara
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_marc
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_mkal
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_makt
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_caufvd
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_afpo
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_kbko
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_jstat
                     ir_order  = ir_order ).
    add_order_table( ir_parent = ir_parent
                     if_table  = lif_table=>co_affl
                     ir_order  = ir_order ).

    TRY .
        lr_plano ?= ir_order.
        add_order_table( ir_parent = ir_parent
                         if_table  = lif_table=>co_plaf
                         ir_order  = ir_order ).
      CATCH cx_sy_move_cast_error.

    ENDTRY.
  ENDMETHOD.
  METHOD add_operation_tables.
    add_operation_table( if_table     = lif_table=>co_crhd
                         ir_parent    = ir_parent
                         ir_operation = ir_operation ).
    add_operation_table( if_table     = lif_table=>co_kako
                         ir_parent    = ir_parent
                         ir_operation = ir_operation ).
    add_operation_table( if_table     = lif_table=>co_kbed
                         ir_parent    = ir_parent
                         ir_operation = ir_operation ).
    add_operation_table( if_table     = lif_table=>co_afvgd
                         ir_parent    = ir_parent
                         ir_operation = ir_operation ).
    add_operation_table( if_table     = lif_table=>co_jstat
                         ir_parent    = ir_parent
                         ir_operation = ir_operation ).
    add_operation_table( if_table     = lif_table=>co_affl
                         ir_parent    = ir_parent
                         ir_operation = ir_operation ).
  ENDMETHOD.
  METHOD add_operation_table.
    DATA: lr_table TYPE REF TO lcl_operation_table,
          lr_item  TYPE REF TO lcl_tree_item,
          lf_name  TYPE lvc_value.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
    lf_name = if_table.
    lr_item = mr_tree->add_item( if_related_node_key = ir_parent->mf_node_key ).
    lr_item->set_name( lf_name ).

    CREATE OBJECT lr_table
      EXPORTING
        if_table     = if_table
        ir_operation = ir_operation.
    lr_item->set_object( lr_table ).

    ASSIGN lr_table->lif_table~mr_table->* TO <lt_table>.
    IF lines( <lt_table> ) GT 0.
      lr_item->set_icon( co_table_icon ).
    ELSE.
      lr_item->set_icon( co_empty_table_icon ).
    ENDIF.
  ENDMETHOD.
  METHOD add_order_table.
    DATA: lr_table TYPE REF TO lcl_order_table,
          lr_item  TYPE REF TO lcl_tree_item,
          lf_name  TYPE lvc_value.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.

    lf_name = if_table.
    lr_item = mr_tree->add_item( if_related_node_key = ir_parent->mf_node_key ).
    lr_item->set_name( lf_name ).

    CREATE OBJECT lr_table
      EXPORTING
        if_table = if_table
        ir_order = mr_order.
    lr_item->set_object( lr_table ).

    ASSIGN lr_table->lif_table~mr_table->* TO <lt_table>.
    IF lines( <lt_table> ) GT 0.
      lr_item->set_icon( co_table_icon ).
    ELSE.
      lr_item->set_icon( co_empty_table_icon ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
