class ZCX_TCX_NOTFOUND definition
  public
  inheriting from ZCX_ORDER
  create public .

public section.

  constants:
    begin of ZCX_TCX_NOTFOUND,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '541',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_TCX_NOTFOUND .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !PLNID type Z_PLNID optional
      !VORNR type VORNR optional
      !SART type Z_SART optional
      !AUTYP type AUFTYP optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_TCX_NOTFOUND IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
PLNID = PLNID
VORNR = VORNR
SART = SART
AUTYP = AUTYP
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_TCX_NOTFOUND .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
