class ZCX_OPERATION_NOTFOUND definition
  public
  inheriting from ZCX_OPERATIONS
  create public .

public section.

  constants:
    begin of ZCX_OPERATION_NOTFOUND,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '045',
      attr1 type scx_attrname value 'PLNID',
      attr2 type scx_attrname value 'VORNR',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_OPERATION_NOTFOUND .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to /GIB/IF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !PLNID type Z_PLNID optional
      !VORNR type VORNR optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_OPERATION_NOTFOUND IMPLEMENTATION.

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
  IF_T100_MESSAGE~T100KEY = ZCX_OPERATION_NOTFOUND .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
