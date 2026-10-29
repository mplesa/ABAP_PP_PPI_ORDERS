FUNCTION z_verid_select.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IT_MKAL) TYPE  CURTO_MKAL_T
*"  EXPORTING
*"     REFERENCE(ES_MKAL) TYPE  MKAL
*"  RAISING
*"----------------------------------------------------------------------
  CHECK it_mkal IS NOT INITIAL.

*#if only one MKAL entry is present then just return it as selection
  READ TABLE it_mkal INTO es_mkal INDEX 1.
  IF lines( it_mkal ) = 1.
    RETURN.
  ENDIF.

  PERFORM initialize_fuba.
  gr_order = ir_order.
  gt_mkal  = it_mkal.
  PERFORM build_mdfq.

  TRY .
      CALL SCREEN 0100 STARTING AT 06 01
                       ENDING AT 76 11.

      READ TABLE it_mkal INTO es_mkal WITH KEY verid = gs_mdfq-verid.
      PERFORM initialize_fuba.
    CLEANUP.
      "if the dialog was canceled then initialize everything
      PERFORM initialize_fuba.
      CLEAR es_mkal.
  ENDTRY.

ENDFUNCTION.
