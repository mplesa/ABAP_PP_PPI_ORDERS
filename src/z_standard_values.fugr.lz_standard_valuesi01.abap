*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'SAVE'.
      TRY.
          DATA(lr_msg) = gr_operation->change_standard_values( if_vgw01 = afvgd-vgw01
                                                if_vge01 = afvgd-vge01
                                                if_vgw02 = afvgd-vgw02
                                                if_vge02 = afvgd-vge02
                                                if_vgw03 = afvgd-vgw03
                                                if_vge03 = afvgd-vge03
                                                if_vgw04 = afvgd-vgw04
                                                if_vge04 = afvgd-vge04
                                                if_vgw05 = afvgd-vgw05
                                                if_vge05 = afvgd-vge05
                                                if_vgw06 = afvgd-vgw06
                                                if_vge06 = afvgd-vge06 ).
          IF lr_msg IS BOUND.
            lr_msg->show( ).
          ENDIF.
          LEAVE TO SCREEN 0.
        CATCH zcx_core INTO DATA(lr_error).
          MESSAGE lr_error TYPE 'S'.
      ENDTRY.

    WHEN 'EXIT'.
      RAISE EXCEPTION TYPE /gib/cx_dcp_ui
        EXPORTING
          textid = /gib/cx_dcp_ui=>operation_canceled.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
MODULE check_unit_0100.

  CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
    EXPORTING
      parid  = rcr01-par01
      vgwdi  = rcr01-vgd01
      vgwei  = afvgd-vge01
      vgwrt  = afvgd-vgw01
      vgwst  = rcr01-vgm01
      vgwnr  = 1
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
    EXPORTING
      parid  = rcr01-par02
      vgwdi  = rcr01-vgd02
      vgwei  = afvgd-vge02
      vgwrt  = afvgd-vgw02
      vgwst  = rcr01-vgm02
      vgwnr  = 2
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
    EXPORTING
      parid  = rcr01-par03
      vgwdi  = rcr01-vgd03
      vgwei  = afvgd-vge03
      vgwrt  = afvgd-vgw03
      vgwst  = rcr01-vgm03
      vgwnr  = 3
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
    EXPORTING
      parid  = rcr01-par04
      vgwdi  = rcr01-vgd04
      vgwei  = afvgd-vge04
      vgwrt  = afvgd-vgw04
      vgwst  = rcr01-vgm04
      vgwnr  = 4
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
    EXPORTING
      parid  = rcr01-par05
      vgwdi  = rcr01-vgd05
      vgwei  = afvgd-vge05
      vgwrt  = afvgd-vgw05
      vgwst  = rcr01-vgm05
      vgwnr  = 5
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
    EXPORTING
      parid  = rcr01-par06
      vgwdi  = rcr01-vgd06
      vgwei  = afvgd-vge06
      vgwrt  = afvgd-vgw06
      vgwst  = rcr01-vgm06
      vgwnr  = 6
    EXCEPTIONS
      OTHERS = 0.

ENDMODULE.
