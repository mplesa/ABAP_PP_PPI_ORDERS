class ZCX_OPERATION definition
  public
  inheriting from ZCX_CORE
  create public .

public section.

  data PLNID type Z_PLNID .
  data VORNR type VORNR .

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

CLASS ZCX_OPERATION IMPLEMENTATION.

  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MSG = MSG
TCODE = TCODE
.
me->PLNID = PLNID .
me->VORNR = VORNR .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
