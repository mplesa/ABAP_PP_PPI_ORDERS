class ZCL_ORDER_CONF_API definition
  public
  inheriting from ZCL_CONFIRMATION_API
  abstract
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IR_ORDER type ref to ZIF_ORDER .
protected section.

  data MR_ORDER type ref to ZIF_ORDER .
private section.
ENDCLASS.

CLASS ZCL_ORDER_CONF_API IMPLEMENTATION.

METHOD CONSTRUCTOR.
  super->constructor( ir_order->ms_caufvd-rueck ).
  mr_order = ir_order.
ENDMETHOD.
ENDCLASS.
