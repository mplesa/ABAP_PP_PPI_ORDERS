interface ZIF_ORDER_STACK
  public .

  class-data:
    GT_ORDERS TYPE TABLE OF REF TO zif_order read-only .

  class-methods ADD
    importing
      !IR_ORDER type ref to ZIF_ORDER .
  class-methods REMOVE
    importing
      !IR_ORDER type ref to ZIF_ORDER .
  class-methods IS_PRESENT
    importing
      !IR_ORDER type ref to ZIF_ORDER
    returning
      value(RF_ANSWER) type FLAG .
  class-methods CLEAR .
endinterface.
