*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_tree DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree DEFINITION INHERITING FROM cl_gui_alv_tree.

  PUBLIC SECTION.
    METHODS: constructor IMPORTING ir_container TYPE REF TO cl_gui_container,
      refresh,
      display,
      expand,
      expand_fulltree,
      expand_item IMPORTING ir_item TYPE REF TO lcl_tree_item,
      update_calculations REDEFINITION,
      delete_item IMPORTING ir_item TYPE REF TO lcl_tree_item,
      add_item IMPORTING if_related_node_key TYPE lvc_nkey OPTIONAL
                         if_relationship     TYPE  int4 DEFAULT cl_gui_column_tree=>relat_last_child
               RETURNING VALUE(rr_item)      TYPE REF TO lcl_tree_item,
      get_item IMPORTING if_node_key    TYPE lvc_nkey
               RETURNING VALUE(rr_item) TYPE REF TO lcl_tree_item,
      get_toolbar RETURNING VALUE(rr_toolbar) TYPE REF TO lcl_toolbar,
      get_item_with_object IMPORTING ir_object      TYPE REF TO object
                           RETURNING VALUE(rr_item) TYPE REF TO lcl_tree_item.
    CLASS-METHODS: class_constructor.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_tree_data,
             item     TYPE REF TO lcl_tree_item,
             node_key TYPE lvc_nkey,
           END OF ts_tree_data,
           tt_tree_data TYPE TABLE OF ts_tree_data.
    TYPES:
      BEGIN OF ts_relat_key,
        level TYPE histu,     "Stufe in int. Tab. vorgegeben
        key   TYPE lvc_nkey,  "Ebene des Trees
      END OF ts_relat_key .
    TYPES:
      tt_relat_keys TYPE STANDARD TABLE OF ts_relat_key.
    DATA: mt_tree_data        TYPE tt_tree_data,
          mt_items            TYPE TABLE OF REF TO lcl_tree_item,
          mr_toolbar_shell    TYPE REF TO lcl_toolbar,
          mf_current_node_key TYPE lvc_nkey VALUE '1'.

    CLASS-DATA: gt_fieldcat          TYPE lvc_t_fcat,
                gt_toolbar_excluding TYPE  ui_functions.
    METHODS: register_events,
      add_item_intern IMPORTING ir_item TYPE REF TO lcl_tree_item.
ENDCLASS.                    "lcl_tree DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_tree IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree IMPLEMENTATION.
  METHOD refresh.
    CLEAR: mt_tree_data, mt_items.
  ENDMETHOD.                    "refresh
  METHOD expand_fulltree.
    DATA: lt_node_key  TYPE lvc_t_nkey,
          ls_tree_data TYPE ts_tree_data.
    READ TABLE mt_tree_data INTO ls_tree_data INDEX 1.
    CHECK sy-subrc = 0.
    APPEND ls_tree_data-node_key TO lt_node_key.
    me->handle_generic_functions( i_fcode = '&EXPAND'
                                  it_node_key = lt_node_key ).
  ENDMETHOD.                    "expand_fulltree
  METHOD get_toolbar.
    IF mr_toolbar_shell IS NOT BOUND.
      CREATE OBJECT mr_toolbar_shell
        EXPORTING
          ir_toolbar = mr_toolbar.
    ENDIF.
    rr_toolbar = mr_toolbar_shell.
  ENDMETHOD.                    "get_toolbar
  METHOD delete_item.
    DATA:ls_tree_data TYPE ts_tree_data,
         lf_node_key  TYPE  lvc_nkey,
         lt_children  TYPE lvc_t_nkey.

    READ TABLE mt_tree_data INTO ls_tree_data  WITH KEY item = ir_item.
    CHECK sy-subrc EQ 0.

    get_subtree( EXPORTING i_node_key       = ls_tree_data-node_key
                 IMPORTING et_subtree_nodes = lt_children ).

    SORT lt_children DESCENDING.

    LOOP AT lt_children INTO lf_node_key.

      READ TABLE mt_tree_data INTO ls_tree_data  WITH KEY node_key = lf_node_key.
      CHECK sy-subrc EQ 0.
      DELETE mt_items WHERE table_line = ls_tree_data-item.
      delete_subtree( EXPORTING
                        i_node_key                = ls_tree_data-node_key
                        i_update_parents_expander = 'X'
                        i_update_parents_folder   = space
                      EXCEPTIONS
                        node_key_not_in_model     = 1
                        OTHERS     = 2 ).
      IF sy-subrc = 0.
        DELETE mt_tree_data WHERE item = ls_tree_data-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "delete_item
  METHOD get_item_with_object.
    FIELD-SYMBOLS: <lr_item> TYPE REF TO lcl_tree_item.

*#...
    READ TABLE mt_items INTO rr_item WITH KEY table_line->mr_object = ir_object.

  ENDMETHOD.                    "get_item_with_object
  METHOD update_calculations.
    FIELD-SYMBOLS:  <lr_item> TYPE REF TO lcl_tree_item.
    LOOP AT mt_items ASSIGNING <lr_item>.
      READ TABLE mt_tree_data WITH KEY item = <lr_item> TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        add_item_intern( <lr_item> ).
      ENDIF.
    ENDLOOP.
    super->update_calculations( no_frontend_update ).
  ENDMETHOD.                    "update_calculations
  METHOD add_item_intern.
    DATA ls_tree_data TYPE ts_tree_data.
    DATA: ls_related_tree_data TYPE ts_tree_data.
    FIELD-SYMBOLS: <ls_tree_data> TYPE ts_tree_data.

    IF ir_item->mf_related_node_key IS NOT INITIAL.
      READ TABLE mt_tree_data INTO ls_related_tree_data
      WITH KEY item->mf_node_key = ir_item->mf_related_node_key.
    ENDIF.
    ls_tree_data-item = ir_item.

    add_node( EXPORTING  i_relat_node_key     = ls_related_tree_data-node_key   "#EC CI_SUBRC
                         i_relationship       = ir_item->mf_relationship
                         is_outtab_line       = ls_tree_data
                         is_node_layout       = ir_item->ms_node_settings
                         it_item_layout       = ir_item->mt_item_settings
                         i_node_text          = ir_item->mf_name" lf_node_text
              IMPORTING  e_new_node_key       = ls_tree_data-node_key
              EXCEPTIONS relat_node_not_found = 1
                         node_not_found       = 2
                         OTHERS               = 3 ).
    IF sy-subrc <> 0.                                       "#EC NEEDED

    ENDIF.

    READ TABLE mt_tree_data WITH KEY item = ir_item ASSIGNING <ls_tree_data>.
    IF sy-subrc EQ 0.
      <ls_tree_data>-node_key = ls_tree_data-node_key.
    ENDIF.
  ENDMETHOD.                    "add_item_intern
  METHOD expand_item.
    FIELD-SYMBOLS: <ls_tree_data> TYPE ts_tree_data.
    READ TABLE mt_tree_data ASSIGNING <ls_tree_data> WITH KEY item = ir_item.
    IF sy-subrc EQ 0.
      CHECK <ls_tree_data>-item->ms_node_settings-isfolder IS NOT INITIAL.
      <ls_tree_data>-item->set_expanded( 'X' ).
      expand_node( i_node_key = <ls_tree_data>-node_key ).
    ENDIF.
  ENDMETHOD.                    "expand_item
  METHOD expand.
    DATA: lt_expand_keys TYPE lvc_t_nkey.
    FIELD-SYMBOLS: <ls_tree_data> TYPE ts_tree_data.

    LOOP AT mt_tree_data ASSIGNING <ls_tree_data> WHERE item->ms_node_settings-isfolder IS NOT INITIAL
                                                    AND item->mf_expanded IS NOT INITIAL.
      expand_node( i_node_key = <ls_tree_data>-node_key ).
    ENDLOOP.
  ENDMETHOD.                    "expand
  METHOD get_item.
    FIELD-SYMBOLS: <ls_tree_data> TYPE ts_tree_data.
    READ TABLE mt_tree_data ASSIGNING <ls_tree_data> WITH KEY node_key = if_node_key.
    IF sy-subrc EQ 0.
      rr_item = <ls_tree_data>-item.
    ENDIF.
  ENDMETHOD.                    "get_item
  METHOD add_item.
    CREATE OBJECT rr_item
      EXPORTING
        if_node_key         = mf_current_node_key
        if_related_node_key = if_related_node_key
        if_relationship     = if_relationship.
    ADD 1 TO mf_current_node_key.
    APPEND rr_item TO mt_items.
  ENDMETHOD.                    "add_item
  METHOD display.
    delete_all_nodes( ).
    update_calculations( ).
    expand( ).
  ENDMETHOD.                    "display
  METHOD class_constructor.
    FIELD-SYMBOLS: <ls_fieldcat> TYPE lvc_s_fcat.
    DATA: ls_exclude TYPE ui_func.
*#fieldcatalog
    APPEND INITIAL LINE TO gt_fieldcat ASSIGNING <ls_fieldcat>.
    <ls_fieldcat>-fieldname = 'ITEM'.
    <ls_fieldcat>-tech = 'X'.
    APPEND INITIAL LINE TO gt_fieldcat ASSIGNING <ls_fieldcat>.
    <ls_fieldcat>-fieldname = 'NODE_KEY'.
    <ls_fieldcat>-tech = 'X'.
*# exclude from toolbar
    ls_exclude = cl_gui_alv_tree=>mc_fc_save_variant.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_load_variant.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_maintain_variant.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_current_variant.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_print_back.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_print_back_all.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_print_prev.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_print_prev_all.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_calculate_sum.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_calculate.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_calculate_avg.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_calculate_max.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_calculate_min.
    APPEND ls_exclude TO gt_toolbar_excluding.
    ls_exclude = cl_gui_alv_tree=>mc_fc_calculate_sum.
    APPEND ls_exclude TO gt_toolbar_excluding.
  ENDMETHOD.                    "class_constructor
  METHOD constructor.
    super->constructor(     "#EC CI_SUBRC
      EXPORTING
        parent                      = ir_container
        node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
        item_selection              = 'X'
        no_html_header              = 'X'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        illegal_node_selection_mode = 5
        failed                      = 6
        illegal_column_name         = 7
        OTHERS                      = 8 ).
    IF sy-subrc <> 0.

    ENDIF.
    register_events( ).
    set_table_for_first_display( EXPORTING it_toolbar_excluding = gt_toolbar_excluding
                                 CHANGING it_outtab = mt_tree_data
                                          it_fieldcatalog = gt_fieldcat ).
  ENDMETHOD.                    "constructor
  METHOD register_events.
    DATA: lt_events TYPE cntl_simple_events.
    FIELD-SYMBOLS: <ls_event> TYPE cntl_simple_event.
*# angemeldete Ereignisse auslesen / get registered events
    get_registered_events( IMPORTING events = lt_events ).
*# Doppelklick auf Knoten / double click for node
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid    = cl_gui_column_tree=>eventid_node_double_click.
    <ls_event>-appl_event = 'X'.
*# Doppelklick auf einen Eintrag / Double click for items
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid    = cl_gui_column_tree=>eventid_item_double_click.
    <ls_event>-appl_event = 'X'.
*# Klick auf einen Eintrag vom Typ LINK / Link click
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid    = cl_gui_column_tree=>eventid_link_click.
    <ls_event>-appl_event = 'X'.
*# Änderung einer Checkbox / Checkbox changed
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid    = cl_gui_column_tree=>eventid_checkbox_change.
    <ls_event>-appl_event = 'X'.
*# Anforderung eines Kontextmenüs auf einem Eintrag /
*# Context menu required for item
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
    <ls_event>-appl_event = 'X'.
*# Anforderung eines Kontextmenüs auf einem Knoten /
*# Context menu required for node
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid  = cl_gui_column_tree=>eventid_node_context_menu_req.
    <ls_event>-appl_event = 'X'.
*# Taste wurde gedrückt, Knoten war selektiert
*# Key stroke. node was selected.
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid    = cl_gui_column_tree=>eventid_node_keypress.
    <ls_event>-appl_event = 'X'.
*# Taste wurde gedrückt, Eintrag war selektiert
*# Key stroke. Item was selected.
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid = cl_gui_column_tree=>eventid_item_keypress.
*# Klick auf einen Eintrag vom Typ BUTTON / Button click
    APPEND INITIAL LINE TO lt_events ASSIGNING <ls_event>.
    <ls_event>-eventid = cl_gui_column_tree=>eventid_button_click.
    SORT lt_events BY eventid.
    DELETE ADJACENT DUPLICATES FROM lt_events COMPARING eventid.
*# Ereignisse anmelden / Register events on frontend
    set_registered_events(
      EXPORTING
        events                    = lt_events
      EXCEPTIONS
        cntl_error                = 1
        cntl_system_error         = 2
        illegal_event_combination = 3 ).
    IF sy-subrc <> 0.
      MESSAGE x208(00) WITH 'ERROR'.                        "#EC NOTEXT
    ENDIF.
  ENDMETHOD.                    "register_events
ENDCLASS.                    "lcl_tree IMPLEMENTATION
