class ZCL_OPERATION_NETWK definition
  public
  inheriting from ZCL_OPERATION
  create public .

public section.

  methods ZIF_OPERATION~SCHEDULE
    redefinition .
  methods ZIF_OPERATION~UPDATE_SUBOBJECTS
    redefinition .
protected section.
private section.
ENDCLASS.

CLASS ZCL_OPERATION_NETWK IMPLEMENTATION.

  METHOD zif_operation~update_subobjects.

  ENDMETHOD.

METHOD zif_operation~schedule.
  DATA: ls_cxzeit TYPE cxzeit,
        ls_cxafvg TYPE cxafvg_v2,
        lf_error  TYPE sy-subrc.
*#the CX data (scheduling data) must be refreshed
  CALL FUNCTION 'CX_DATA_RESET'.

  IF if_forward IS NOT INITIAL.
*#forward scheduling from PIT
    ls_cxzeit-ssav = if_pit.
  ELSE.
*#backward scheduling from PIT
    ls_cxzeit-ssed = if_pit.
  ENDIF.

*#Reset DISPATCHED dates
  CLEAR cs_afvgd-epanf.
  CLEAR cs_afvgd-epanz.
  CLEAR cs_afvgd-epend.
  CLEAR cs_afvgd-epenz.
*#Reset CONSTRAINT FOR ACTIVITY dates
  CLEAR cs_afvgd-ntanf.
  CLEAR cs_afvgd-ntanz.
  CLEAR cs_afvgd-ntend.
  CLEAR cs_afvgd-ntenz.
*#Reset ACTUAL EXECUTION dates
  CLEAR cs_afvgd-isdd.
  CLEAR cs_afvgd-isdz.
  CLEAR cs_afvgd-iedd.
  CLEAR cs_afvgd-iedz.

  MOVE-CORRESPONDING cs_afvgd TO ls_cxafvg.

*#schedule the operation with results in ls_cxzeit
  CALL FUNCTION 'CX_OPR_SCHEDULE'
    EXPORTING
      afvg_v2_imp          = ls_cxafvg "Proccess/IH/Network Orders
      cxzeit_imp           = ls_cxzeit
      i_flg_shift_order    = 'X' "for TRÜCK
      i_overlapped         = 'X'
      i_flg_no_calendar    = ' '
      i_flg_cap_scheduling = ' '
      i_flg_forward        = if_forward
      i_flg_protocol       = ' '
      i_flg_exact_breaks   = mr_order->ms_caufvd-breaks
      i_point_in_time      = if_pit
    IMPORTING
      cxzeit_exp           = ls_cxzeit
      e_error_code         = lf_error.

  IF ls_cxzeit-ssav IS INITIAL.
    ls_cxzeit-ssav = ls_cxzeit-fsav.
  ENDIF.
  IF ls_cxzeit-sssb IS INITIAL.
    ls_cxzeit-sssb = ls_cxzeit-fssb.
  ENDIF.
  IF ls_cxzeit-sssa IS INITIAL.
    ls_cxzeit-sssa = ls_cxzeit-fssa.
  ENDIF.
  IF ls_cxzeit-ssed IS INITIAL.
    ls_cxzeit-ssed = ls_cxzeit-fsed.
  ENDIF.
  IF ls_cxzeit-sssl IS INITIAL.
    ls_cxzeit-sssl = ls_cxzeit-fssl.
  ENDIF.
  IF ls_cxzeit-ssel IS INITIAL.
    ls_cxzeit-ssel = ls_cxzeit-fsel.
  ENDIF.
  IF ls_cxzeit-fsav IS INITIAL.
    ls_cxzeit-fsav = ls_cxzeit-ssav.
  ENDIF.
  IF ls_cxzeit-fssb IS INITIAL.
    ls_cxzeit-fssb = ls_cxzeit-sssb.
  ENDIF.
  IF ls_cxzeit-fssa IS INITIAL.
    ls_cxzeit-fssa = ls_cxzeit-sssa.
  ENDIF.
  IF ls_cxzeit-fsed IS INITIAL.
    ls_cxzeit-fsed = ls_cxzeit-ssed.
  ENDIF.
  IF ls_cxzeit-fssl IS INITIAL.
    ls_cxzeit-fssl = ls_cxzeit-sssl.
  ENDIF.
  IF ls_cxzeit-fsel IS INITIAL.
    ls_cxzeit-fsel = ls_cxzeit-ssel.
  ENDIF.

*#modify AFVGD from the scheduling results
  CALL FUNCTION 'CX_OPR_FILL_FROM_CXZEIT'
    EXPORTING
      afvgd_imp        = cs_afvgd
      cxzeit_imp       = ls_cxzeit
      i_flg_arbei      = ' '
      i_flg_forward    = 'X'
      i_flg_dates_only = ' ' "Vorgabewerte Ändern wenn status EIGP
    IMPORTING
      afvgd_exp        = cs_afvgd.
ENDMETHOD.
ENDCLASS.
