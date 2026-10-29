class ZCL_OPERATION_SEQUANCE definition
  public
  create private

  global friends ZCL_ORDER .

public section.

  interfaces ZIF_OPERATION_SEQUANCE .

  aliases CO_ALIGNMENT
    for ZIF_OPERATION_SEQUANCE~CO_ALIGNMENT .
  aliases CO_RELATIONSHIP
    for ZIF_OPERATION_SEQUANCE~CO_RELATIONSHIP .
  aliases CO_STANDARD_SEQUANCE
    for ZIF_OPERATION_SEQUANCE~CO_STANDARD_SEQUANCE .
  aliases CO_TYPE
    for ZIF_OPERATION_SEQUANCE~CO_TYPE .
  aliases MR_ORDER
    for ZIF_OPERATION_SEQUANCE~MR_ORDER .
  aliases MS_AFFL
    for ZIF_OPERATION_SEQUANCE~MS_AFFL .
  aliases GET_FIRST_OPERATION
    for ZIF_OPERATION_SEQUANCE~GET_FIRST_OPERATION .
  aliases GET_LAST_OPERATION
    for ZIF_OPERATION_SEQUANCE~GET_LAST_OPERATION .
  aliases GET_OPERATION
    for ZIF_OPERATION_SEQUANCE~GET_OPERATION .
  aliases GET_OPERATIONS
    for ZIF_OPERATION_SEQUANCE~GET_OPERATIONS .
  aliases GET_PREDECESSOR_OPERATION
    for ZIF_OPERATION_SEQUANCE~GET_PREDECESSOR_OPERATION .
  aliases GET_SUCCESSOR_OPERATION
    for ZIF_OPERATION_SEQUANCE~GET_SUCCESSOR_OPERATION .

  methods CONSTRUCTOR
    importing
      !IR_ORDER type ref to ZIF_ORDER
      !IS_AFFL type AFFLD .
  class-methods FACTORY
    importing
      !IR_ORDER type ref to ZIF_ORDER
      !IS_AFFL type AFFLD
    returning
      value(RR_SEQUANCE) type ref to ZIF_OPERATION_SEQUANCE .
protected section.
private section.
ENDCLASS.

CLASS ZCL_OPERATION_SEQUANCE IMPLEMENTATION.

  METHOD zif_operation_sequance~get_first_operation.
    rr_operation = mr_order->get_first_operation( if_sequence = ms_affl-plnfl ).
  ENDMETHOD.

  METHOD zif_operation_sequance~get_last_operation.
    rr_operation = mr_order->get_last_operation( if_sequence = ms_affl-plnfl ).
  ENDMETHOD.

  METHOD zif_operation_sequance~get_operation.
    IF if_aplzl IS NOT SUPPLIED.
      rr_operation = mr_order->get_operation( if_vornr = if_vornr
                                              if_sequence = ms_affl-plnfl ).
    ELSE.
      rr_operation = mr_order->get_operation( if_vornr = if_vornr
                                              if_aplzl = if_aplzl ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation_sequance~get_operations.
    CLEAR et_operations.
    mr_order->get_operations( EXPORTING if_sequence   = ms_affl-plnfl
                              IMPORTING et_operations = et_operations ).
  ENDMETHOD.

  METHOD zif_operation_sequance~get_predecessor_operation.
    IF ir_operation->ms_afvgd-aplfl <> ms_affl-plnfl.
      RAISE EXCEPTION TYPE zcx_no_predecessor
        EXPORTING
          plnid = mr_order->mf_plnid
          vornr = ir_operation->mf_vornr.
    ENDIF.
    mr_order->get_predecessor_operation( ir_operation ).
  ENDMETHOD.

  METHOD zif_operation_sequance~get_successor_operation.
    IF ir_operation->ms_afvgd-aplfl <> ms_affl-plnfl.
      RAISE EXCEPTION TYPE zcx_no_successor
        EXPORTING
          plnid = mr_order->mf_plnid
          vornr = ir_operation->mf_vornr.
    ENDIF.
    mr_order->get_successor_operation( ir_operation ).
  ENDMETHOD.

  METHOD constructor.
    mr_order = ir_order.
    ms_affl = is_affl.
  ENDMETHOD.

  METHOD factory.
    rr_sequance ?= NEW zcl_operation_sequance( ir_order = ir_order
                                                       is_affl  = is_affl ).
  ENDMETHOD.
ENDCLASS.
