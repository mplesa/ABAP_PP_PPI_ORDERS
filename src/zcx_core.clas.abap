class ZCX_CORE definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_CORE,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '999',
      attr1 type scx_attrname value 'IF_T100_DYN_MSG~MSGV1',
      attr2 type scx_attrname value 'IF_T100_DYN_MSG~MSGV2',
      attr3 type scx_attrname value 'IF_T100_DYN_MSG~MSGV3',
      attr4 type scx_attrname value 'IF_T100_DYN_MSG~MSGV4',
    end of ZCX_CORE .
  constants:
    begin of NOT_FOUND,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '900',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOT_FOUND .
  data MSG type ref to ZIF_MSG_QUEUE read-only .
  data TCODE type TCODE read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MSG type ref to ZIF_MSG_QUEUE optional
      !TCODE type TCODE optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CORE IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MSG = MSG .
me->TCODE = TCODE .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_CORE .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
