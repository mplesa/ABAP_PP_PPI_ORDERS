class ZCL_OPERATION_IH definition
  public
  inheriting from ZCL_OPERATION
  create public .

public section.

  methods ZIF_OPERATION~SCHEDULE
    redefinition .
protected section.
private section.
ENDCLASS.

CLASS ZCL_OPERATION_IH IMPLEMENTATION.

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
