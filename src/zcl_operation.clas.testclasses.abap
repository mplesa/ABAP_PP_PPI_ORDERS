*"* use this source file for your ABAP unit test classes

*# TEST DOUBLES
CLASS ltd_order DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_order PARTIALLY IMPLEMENTED.

ENDCLASS.

CLASS ltd_order IMPLEMENTATION.
ENDCLASS.

*# TEST CLASSES

CLASS ltc_amounts DEFINITION FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS amount FOR TESTING.
    METHODS gross FOR TESTING.
    METHODS net FOR TESTING.
    METHODS open_amount FOR TESTING.

    METHODS amount_check
      IMPORTING
        if_operation_amount TYPE mgvrg
        if_result TYPE z_amount.

    METHODS gross_check
      IMPORTING
        if_operation_amount TYPE mgvrg
        if_result TYPE z_amount.

    METHODS open_amount_check
      IMPORTING
        if_operation_amount TYPE mgvrg
        if_yield_amount TYPE lmnga
        if_scrap_amount TYPE xmnga
        if_result TYPE z_amount.

    METHODS net_check
      IMPORTING
        if_operation_amount TYPE mgvrg
        if_yield_amount TYPE lmnga
        if_result TYPE z_amount.

    DATA: mr_order type ref to zif_order.
ENDCLASS.

CLASS ltc_amounts IMPLEMENTATION.
  METHOD setup.
    mr_order = NEW ltd_order( ).
  ENDMETHOD.

  METHOD amount.
    amount_check( if_operation_amount = 100 if_result = 100 ).
    amount_check( if_operation_amount = '100.53' if_result = '100.53' ).
    amount_check( if_operation_amount = -1 if_result = -1 ).
    amount_check( if_operation_amount = 0 if_result = 0 ).
  ENDMETHOD.

  METHOD open_amount.
    open_amount_check( if_operation_amount = 100 if_yield_amount = 10 if_scrap_amount = 5  if_result = 85 ).
    open_amount_check( if_operation_amount = 100 if_yield_amount = 0  if_scrap_amount = 6  if_result = 94 ).
    open_amount_check( if_operation_amount = 100 if_yield_amount = 2  if_scrap_amount = 0  if_result = 98 ).
    open_amount_check( if_operation_amount = 100 if_yield_amount = 50 if_scrap_amount = 50 if_result = 0 ).
*# TODO: What if good amount is higher than overall amount?
    open_amount_check( if_operation_amount = 100 if_yield_amount = 102 if_scrap_amount = 0 if_result = 0 ).
  ENDMETHOD.

  METHOD gross.
    gross_check( if_operation_amount = 100 if_result = 100 ).
    gross_check( if_operation_amount = '100.53' if_result = '100.53' ).
    gross_check( if_operation_amount = -1 if_result = -1 ).
    gross_check( if_operation_amount = 0 if_result = 0 ).
  ENDMETHOD.

  METHOD net.
    net_check( if_operation_amount = 100      if_yield_amount = 10 if_result = 90 ).
    net_check( if_operation_amount = '100.53' if_yield_amount = 5 if_result = '95.53' ).
*# TODO: What if good amount is higher than overall amount?
    net_check( if_operation_amount = 5       if_yield_amount = 6 if_result = 0 ).
    net_check( if_operation_amount = 0        if_yield_amount = 0 if_result = 0 ).
  ENDMETHOD.

  METHOD open_amount_check.
    DATA(lr_cut) = zcl_operation=>factory(
      EXPORTING
        ir_order = mr_order
        is_afvgd = VALUE afvgd(
                     mgvrg = if_operation_amount
                     lmnga = if_yield_amount
                     xmnga = if_scrap_amount
                   )
    ).

    DATA(lf_open_amount) = lr_cut->zif_amounts~get_open( ).

    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = lf_open_amount
        exp = if_result ).
  ENDMETHOD.

  METHOD amount_check.
    DATA(lr_cut) = zcl_operation=>factory(
      EXPORTING
        ir_order = mr_order
        is_afvgd = VALUE afvgd(
                     mgvrg = if_operation_amount
                   )
    ).
    DATA(lf_amount) = lr_cut->zif_amounts~get( ).
    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = lf_amount
        exp = if_result ).
  ENDMETHOD.

  METHOD gross_check.
    DATA(lr_cut) = zcl_operation=>factory(
      EXPORTING
        ir_order = mr_order
        is_afvgd = VALUE afvgd(
                     mgvrg = if_operation_amount
                   )
    ).
    DATA(lf_gross_amount) = lr_cut->zif_amounts~get_gross( ).
    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = lf_gross_amount
        exp = if_result ).
  ENDMETHOD.
  METHOD net_check.
    DATA(lr_cut) = zcl_operation=>factory(
      EXPORTING
        ir_order = mr_order
        is_afvgd = VALUE afvgd(
                     mgvrg = if_operation_amount
                     lmnga = if_yield_amount
                   )
    ).

    DATA(lf_net_amount) = lr_cut->zif_amounts~get_net( ).

    cl_abap_unit_assert=>assert_equals(
      EXPORTING
        act = lf_net_amount
        exp = if_result ).
  ENDMETHOD.
ENDCLASS.
