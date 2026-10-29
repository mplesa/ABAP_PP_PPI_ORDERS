class ZCX_CAPACITY definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_CAPACITY,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '904',
      attr1 type scx_attrname value 'KAPID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_CAPACITY .
  constants:
    begin of INVALID_CAPA_ID,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '905',
      attr1 type scx_attrname value 'KAPID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_CAPA_ID .
  constants:
    begin of NO_SINGLE_CAPA_AVAILABLE,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '906',
      attr1 type scx_attrname value 'KAPID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_SINGLE_CAPA_AVAILABLE .
  data KAPID type KAPID read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !KAPID type KAPID optional .
protected section.
private section.
ENDCLASS.


CLASS ZCX_CAPACITY IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->KAPID = KAPID .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_CAPACITY .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
