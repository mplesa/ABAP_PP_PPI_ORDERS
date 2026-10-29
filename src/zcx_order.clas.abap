class ZCX_ORDER definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  constants:
    begin of ZCX_ORDER,
      msgid type symsgid value 'Z_CORE',
      msgno type symsgno value '910',
      attr1 type scx_attrname value 'PLNID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ORDER .
  data PLNID type Z_PLNID read-only .
  data VORNR type VORNR read-only .
  data SART type Z_SART read-only .
  data AUTYP type AUFTYP read-only .

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


CLASS ZCX_ORDER IMPLEMENTATION.


  method CONSTRUCTOR ##ADT_SUPPRESS_GENERATION.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->PLNID = PLNID .
me->VORNR = VORNR .
me->SART = SART .
me->AUTYP = AUTYP .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_ORDER .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
