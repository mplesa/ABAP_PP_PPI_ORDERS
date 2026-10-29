class ZCX_ORDER_LOCKED definition
  public
  inheriting from ZCX_ORDERS
  create public .

public section.

  constants:
    begin of ZCX_ORDER_LOCKED,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '107',
      attr1 type scx_attrname value 'AUFNR',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ORDER_LOCKED .
  data AUFNR type AUFNR .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to /GIB/IF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !AUFNR type AUFNR optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_ORDER_LOCKED IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->AUFNR = AUFNR .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_ORDER_LOCKED .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
