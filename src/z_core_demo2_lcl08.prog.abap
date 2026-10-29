*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
INTERFACE lif_m.

  TYPES:
    BEGIN OF ts_function,
      fcode TYPE ui_func,
      text  TYPE gui_text,
    END OF ts_function.
  TYPES: tt_functions TYPE TABLE OF ts_function.
  METHODS: double_click,
    get_functions EXPORTING et_functions TYPE tt_functions,
    handle_function IMPORTING if_func TYPE sy-ucomm.
ENDINTERFACE.
