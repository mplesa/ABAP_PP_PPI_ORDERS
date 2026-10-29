class ZCX_UNIT_CONVERSION definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_UNIT_CONVERSION,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '500',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_UNIT_CONVERSION .
  constants:
    begin of NO_TIME_UNIT,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '501',
      attr1 type scx_attrname value 'UNIT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_TIME_UNIT .
  data UNIT type MSEHI .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to /GIB/IF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !UNIT type MSEHI optional .
protected section.
private section.
ENDCLASS.

CLASS ZCX_UNIT_CONVERSION IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->UNIT = UNIT .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_UNIT_CONVERSION .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
