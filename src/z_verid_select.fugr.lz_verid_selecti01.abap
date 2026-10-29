*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_100 INPUT.
  CASE ok_code.
    WHEN co_uc-save.
      READ TABLE gt_mdfq INTO gs_mdfq WITH KEY marked = 'X'.
      LEAVE TO SCREEN 0.
    WHEN co_uc-exit.
      RAISE EXCEPTION TYPE zcx_ui
        EXPORTING
          textid = zcx_ui=>operation_canceled.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " PAI_100  INPUT
