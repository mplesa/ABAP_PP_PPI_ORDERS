interface ZIF_SCREEN_FLOW
  public .

  type-pools ABAP .

  data MF_SCREEN_TITLE type STRING .
  constants CO_UCOMM_SAVE type SY-UCOMM value 'SAVE' ##NO_TEXT.
  constants CO_UCOMM_BACK type SY-UCOMM value 'BACK' ##NO_TEXT.
  constants CO_UCOMM_CANCEL type SY-UCOMM value 'CANCEL' ##NO_TEXT.
  constants CO_UCOMM_EXIT type SY-UCOMM value 'EXIT' ##NO_TEXT.
  data MR_SCREEN type ref to ZCL_SCREEN .
  data:
    MT_EXCLUDING_FUNCTIONS TYPE TABLE OF char20 read-only .
  constants CO_UCOMM_ENTER type SY-UCOMM value 'ENTR' ##NO_TEXT.

  methods AT_BATCH .
  methods AT_SCREEN_INITIALISATION
    importing
      !IR_CONTAINER type ref to CL_GUI_CONTAINER .
  methods AT_PBO
    importing
      !IR_CONTAINER type ref to CL_GUI_CONTAINER .
  methods AT_PAI
    importing
      !IF_UCOMM type SY-UCOMM
    raising
      CX_STATIC_CHECK .
  methods AT_SCREEN_DESTROY .
endinterface.