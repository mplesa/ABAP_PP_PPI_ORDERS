*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.
  CASE gr_data->mf_user_command.
    WHEN 'save'.
      LEAVE TO SCREEN 0.
    WHEN 'exit'.
      CLEAR: caufvd,
             gr_data.
      RAISE EXCEPTION TYPE zcx_ui
        EXPORTING
          textid = zcx_ui=>operation_canceled.
  ENDCASE.
ENDMODULE.
