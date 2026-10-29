class ZCX_ORDERS definition
  public
  inheriting from /GIB/CX_DCP
  create public .

public section.

  constants:
    begin of ZCX_ORDERS,
      msgid type symsgid value '/GIB/DCP',
      msgno type symsgno value '997',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ORDERS .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to /GIB/IF_MSG_QUEUE optional
      !TCODE type TCODE optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_ORDERS IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_ORDERS .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
