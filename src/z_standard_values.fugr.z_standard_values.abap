FUNCTION z_standard_values.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"  RAISING
*"----------------------------------------------------------------------
  gr_operation = ir_operation.
  gr_order = gr_operation->mr_order.

  afvgd = gr_operation->ms_afvgd.

  CALL FUNCTION 'CO_CHK_WORKSTATION'
    EXPORTING
      afvgd_imp        = gr_operation->ms_afvgd
      caufvd_imp       = gr_order->ms_caufvd
    IMPORTING
      rcr01_exp        = rcr01
    EXCEPTIONS
      not_found        = 1
      type_not_allowed = 2
      OTHERS           = 3.
  IF sy-subrc = 0.
    CALL SCREEN 100 STARTING AT 20 05.
  ENDIF.

  CLEAR: gr_operation, gr_order, afvgd, rcr01.

ENDFUNCTION.
