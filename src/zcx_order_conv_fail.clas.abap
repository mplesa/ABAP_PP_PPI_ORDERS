class ZCX_ORDER_CONV_FAIL definition
  public
  inheriting from ZCX_ORDERS
  create public .

public section.

  constants:
    begin of ZCX_ORDER_CONV_FAIL,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '539',
      attr1 type scx_attrname value 'PLNUM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ORDER_CONV_FAIL .
  data PLNUM type PLNUM .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !PLNUM type PLNUM optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_ORDER_CONV_FAIL IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->PLNUM = PLNUM .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_ORDER_CONV_FAIL .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
