*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT z_core_demo2.
TYPES: abap.
INCLUDE z_core_demo2_sel.
INCLUDE z_core_demo2_lcl01.
INCLUDE z_core_demo2_lcl02.
INCLUDE z_core_demo2_lcl03.
INCLUDE z_core_demo2_lcl04.
INCLUDE z_core_demo2_lcl05.
INCLUDE z_core_demo2_lcl06.
INCLUDE z_core_demo2_lcl07.
INCLUDE z_core_demo2_lcl08.
INCLUDE z_core_demo2_lcl09.
INCLUDE z_core_demo2_lcl10.
INCLUDE z_core_demo2_lcl11.
INCLUDE z_core_demo2_lcl12.
INCLUDE z_core_demo2_lcl13.
INCLUDE z_core_demo2_top.

INITIALIZATION.
  TRY.
      /gib/cl_dc_tools=>check_report_authority( if_repid = sy-repid ).
    CATCH /gib/cx_dcv_no_authority INTO DATA(lr_no_auth).
      MESSAGE lr_no_auth TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
      LEAVE PROGRAM.
  ENDTRY.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'AUF'.
        IF pa_a = 'X'.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      WHEN 'PLN'.
        IF pa_p = 'X'.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

START-OF-SELECTION.
  gr_buffer = zcl_order_buffer=>get_instance( ).

  CASE abap_true.
    WHEN pa_a.
      gr_order = gr_buffer->get_order( pa_aufnr ).
    WHEN pa_p.
      gr_order = gr_buffer->get_plannedorder( pa_plnum ).
  ENDCASE.

  CREATE OBJECT gr_flow EXPORTING ir_order = gr_order.
  CREATE OBJECT gr_screen EXPORTING ir_flow = gr_flow.
  gr_screen->call( ).
