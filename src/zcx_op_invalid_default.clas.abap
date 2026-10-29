class ZCX_OP_INVALID_DEFAULT definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_OP_INVALID_DEFAULT,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '911',
      attr1 type scx_attrname value 'VALUE_DESCRIPTION',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_OP_INVALID_DEFAULT .
  data VALUE_DESCRIPTION type STRING read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !VALUE_DESCRIPTION type STRING optional .
protected section.
private section.
ENDCLASS.


CLASS ZCX_OP_INVALID_DEFAULT IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->VALUE_DESCRIPTION = VALUE_DESCRIPTION .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_OP_INVALID_DEFAULT .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
