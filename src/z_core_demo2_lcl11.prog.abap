*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_c_table DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_c.
    METHODS: constructor IMPORTING ir_container TYPE REF TO cl_gui_container
                                   ir_table TYPE REF TO lif_table,
             set_table IMPORTING ir_table TYPE REF TO lif_table.
  PRIVATE SECTION.
    DATA: mr_container TYPE REF TO cl_gui_container,
          mr_table     TYPE REF TO lif_table,
          mr_grid      TYPE REF TO cl_salv_table,
          mr_data      TYPE REF TO data.
    METHODS: create_grid_header.
ENDCLASS.
CLASS lcl_c_table IMPLEMENTATION.
  METHOD create_grid_header.
    DATA: lr_top_of_list TYPE REF TO cl_salv_form_element,
          lr_top_element TYPE REF TO cl_salv_form_layout_grid,
          lr_header      TYPE REF TO cl_salv_form_header_info,
          lr_action      TYPE REF TO cl_salv_form_action_info,
          lr_icon        TYPE REF TO cl_salv_form_icon.

    DATA: lf_table TYPE string,
          lf_description TYPE string.

    lf_table = mr_table->get_name( ).

    CREATE OBJECT lr_header
      EXPORTING
        text    = lf_table
        tooltip = lf_table.

    mr_grid->set_top_of_list( lr_header ).

    DATA: lr_eol TYPE REF TO cl_salv_form_header_info.
    CREATE OBJECT lr_eol
      EXPORTING
        text = 'This is my Footer'.     "#EC NOTEXT

    mr_grid->set_end_of_list( lr_eol ).
  ENDMETHOD.
  METHOD set_table.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
    mr_table = ir_table.

    TRY .
        ASSIGN mr_table->mr_table->* TO <lt_table>.
        mr_grid->set_data( CHANGING t_table = <lt_table> ).
        create_grid_header( ).
        lif_c~refresh( ).
      CATCH cx_salv_no_new_data_allowed.
    ENDTRY.

  ENDMETHOD.
  METHOD constructor.
    DATA: lr_functions TYPE REF TO cl_salv_functions.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.

    mr_table = ir_table.
    mr_container = ir_container.

    ASSIGN mr_table->mr_table->* TO <lt_table>.
    TRY.
        cl_salv_table=>factory(
          EXPORTING
            r_container    = mr_container
          IMPORTING
            r_salv_table   = mr_grid
          CHANGING
            t_table = <lt_table> ).

        lr_functions = mr_grid->get_functions( ).
        lr_functions->set_all( abap_true ).
      CATCH cx_salv_msg .
    ENDTRY.

  ENDMETHOD.
  METHOD lif_c~display.
    create_grid_header( ).
    mr_grid->display( ).
  ENDMETHOD.
  METHOD lif_c~refresh.
    DATA: ls_stbl TYPE lvc_s_stbl.
    ls_stbl-col = abap_true.
    ls_stbl-row = abap_true.
    mr_grid->refresh( ls_stbl ).
  ENDMETHOD.
  METHOD lif_c~destroy.

  ENDMETHOD.
ENDCLASS.
