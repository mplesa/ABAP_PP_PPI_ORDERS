class ZCL_OP_PCESS_CONF_API definition
  public
  inheriting from ZCL_OPERATION_CONF_API
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IR_OPERATION type ref to ZIF_OPERATION .

  methods ZIF_CONFIRMATION_API~POST
    redefinition .
protected section.

  data MS_KEY type TS_PI_OPERATION_KEY .

  methods POST_TIME_EVENTS
    redefinition .
  methods POST_TIME_TICKETS
    redefinition .
private section.
ENDCLASS.

CLASS ZCL_OP_PCESS_CONF_API IMPLEMENTATION.

METHOD zif_confirmation_api~post.
  rr_msg = NEW #( ).

  rr_msg->append( super->zif_confirmation_api~post( if_wait = if_wait if_commit_work = if_commit_work ) ).
ENDMETHOD.

METHOD constructor.
  super->constructor( ir_operation ).
  ms_key-conf_no      = ir_operation->ms_afvgd-rueck.
  ms_key-orderid      = ir_operation->mr_order->ms_caufvd-aufnr.
  ms_key-resource     = ir_operation->ms_afvgd-arbpl.
  ms_key-phase        = ir_operation->ms_afvgd-vornr.
  ms_key-sec_resource = ir_operation->ms_afvgd-uvorn.
ENDMETHOD.

  METHOD post_time_events.
  ENDMETHOD.

  method POST_TIME_TICKETS.
  endmethod.
ENDCLASS.
