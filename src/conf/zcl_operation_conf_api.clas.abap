class ZCL_OPERATION_CONF_API definition
  public
  inheriting from ZCL_CONFIRMATION_API
  abstract
  create public .

public section.

  aliases CANCEL_LAST
    for ZIF_CONFIRMATION_API~CANCEL_LAST .
  aliases CREATE_TIME_EVENT
    for ZIF_CONFIRMATION_API~CREATE_TIME_EVENT .
  aliases CREATE_TIME_TICKET
    for ZIF_CONFIRMATION_API~CREATE_TIME_TICKET .
  aliases GET_ACTIVE_PERNR_TABLE
    for ZIF_CONFIRMATION_API~GET_ACTIVE_PERNR_TABLE .
  aliases GET_AFRUD_TABLE
    for ZIF_CONFIRMATION_API~GET_AFRUD_TABLE .
  aliases GET_GOODS_MOVEMENT_TABLE
    for ZIF_CONFIRMATION_API~GET_GOODS_MOVEMENT_TABLE .
  aliases GET_LAST
    for ZIF_CONFIRMATION_API~GET_LAST .
  aliases TS_PI_OPERATION_KEY
    for ZIF_CONFIRMATION_API~TS_PI_OPERATON_KEY .
  aliases TS_PP_OPERATION_KEY
    for ZIF_CONFIRMATION_API~TS_PP_OPERATION_KEY .

  methods CONSTRUCTOR
    importing
      !IR_OPERATION type ref to ZIF_OPERATION .

  methods ZIF_CONFIRMATION_API~GET_GOODS_MOVEMENT_TABLE
    redefinition .
protected section.

  data MR_OPERATION type ref to ZIF_OPERATION .
private section.
ENDCLASS.

CLASS ZCL_OPERATION_CONF_API IMPLEMENTATION.

  METHOD zif_confirmation_api~get_goods_movement_table.
    get_afrud_table( IMPORTING et_afrud = DATA(lt_afrud) ).

  ENDMETHOD.

METHOD constructor.
  super->constructor( ir_operation->ms_afvgd-rueck ).
  mr_operation = ir_operation.

ENDMETHOD.
ENDCLASS.
