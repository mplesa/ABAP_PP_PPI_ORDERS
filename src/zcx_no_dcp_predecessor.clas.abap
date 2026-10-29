class ZCX_NO_DCP_PREDECESSOR definition
  public
  inheriting from ZCX_OPERATIONS
  create public .

public section.

  constants:
    begin of ZCX_NO_DCP_PREDECESSOR,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '535',
      attr1 type scx_attrname value 'PLNID',
      attr2 type scx_attrname value 'VORNR',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_NO_DCP_PREDECESSOR .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !PLNID type Z_PLNID optional
      !VORNR type VORNR optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_NO_DCP_PREDECESSOR IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
PLNID = PLNID
VORNR = VORNR
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_NO_DCP_PREDECESSOR .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
