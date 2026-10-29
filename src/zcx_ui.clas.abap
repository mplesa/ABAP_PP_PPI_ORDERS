class ZCX_UI definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_UI,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '902',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_UI .
  constants:
    begin of OPERATION_CANCELED,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '903',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of OPERATION_CANCELED .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional .
protected section.
private section.
ENDCLASS.


CLASS ZCX_UI IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_UI .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
