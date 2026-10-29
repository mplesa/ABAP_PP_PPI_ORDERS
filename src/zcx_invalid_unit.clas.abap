class ZCX_INVALID_UNIT definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_INVALID_UNIT,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '901',
      attr1 type scx_attrname value 'UNIT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_INVALID_UNIT .
  data UNIT type MSEHI read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !UNIT type MSEHI optional .
protected section.
private section.
ENDCLASS.


CLASS ZCX_INVALID_UNIT IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->UNIT = UNIT .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_INVALID_UNIT .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
