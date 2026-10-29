class ZCX_PLANO_CONV_FAILED definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_PLANO_CONV_FAILED,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '907',
      attr1 type scx_attrname value 'PLNUM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_PLANO_CONV_FAILED .
  constants:
    begin of NO_CONVERSION_INDICATOR,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '908',
      attr1 type scx_attrname value 'PLNUM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_CONVERSION_INDICATOR .
  constants:
    begin of NO_PRODUCTION_VERSION,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '909',
      attr1 type scx_attrname value 'PLNUM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_PRODUCTION_VERSION .
  data PLNUM type PLNUM read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional
      !PLNUM type PLNUM optional .
protected section.
private section.
ENDCLASS.


CLASS ZCX_PLANO_CONV_FAILED IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->PLNUM = PLNUM .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_PLANO_CONV_FAILED .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
