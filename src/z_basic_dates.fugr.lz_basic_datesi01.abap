*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.
  CASE gr_data->mf_user_command.
    WHEN /gib/if_dc_screen_flow=>co_ucomm_save.
      LEAVE TO SCREEN 0.
    WHEN /gib/if_dc_screen_flow=>co_ucomm_exit.
      CLEAR: caufvd,
             gr_data.
      RAISE EXCEPTION TYPE /gib/cx_dcp_ui
        EXPORTING
          textid = /gib/cx_dcp_ui=>operation_canceled.
  ENDCASE.
ENDMODULE.
