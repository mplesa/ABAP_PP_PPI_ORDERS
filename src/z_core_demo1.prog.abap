*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT z_core_demo1.

*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

TABLES: /gib/dcp_areas.
SELECT-OPTIONS: so_werks FOR /gib/dcp_areas-werks MEMORY ID wrk.

SELECT-OPTIONS: so_area FOR /gib/dcp_areas-area MEMORY ID /gib/dcp_area .

DATA: lr_buffer TYPE REF TO zif_order_buffer.
DATA: lt_main TYPE TABLE OF /gib/dcp_main,
      ls_main TYPE /gib/dcp_main.
DATA: lt_plnum TYPE TABLE OF plnum,
      lt_aufnr TYPE TABLE OF aufnr.

DATA: lr_order            TYPE REF TO zif_order,
      lr_operation        TYPE REF TO zif_operation,
      lt_operations       TYPE TABLE OF REF TO zif_operation,
      lt_total_operations TYPE TABLE OF REF TO zif_operation,
      ls_area             TYPE /gib/dcp_areas,
      ls_kbed             TYPE kbedd.

DATA: mf_start   TYPE syuzeit,
      mf_seconds TYPE char10.
DATA: lf_lines TYPE sy-tabix.

INITIALIZATION.

  TRY.
      /gib/cl_dc_tools=>check_report_authority( if_repid = zif_core_constants=>co_repid_dcp ).
    CATCH /gib/cx_dcv_no_authority INTO DATA(lr_auth_msg).
      MESSAGE lr_auth_msg TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
      LEAVE PROGRAM.
  ENDTRY.
START-OF-SELECTION.

  mf_start = sy-uzeit.

  SELECT sart plnid plzeit vornr pldat werks area kzpla FROM /gib/dcp_main
      INTO CORRESPONDING FIELDS OF TABLE lt_main
    WHERE werks IN so_werks
      AND area  IN so_area
      AND kzpla = zif_core_constants=>co_planned.
  CHECK lt_main IS NOT INITIAL.
  LOOP AT lt_main INTO ls_main.
    CASE ls_main-sart.
      WHEN zif_core_constants=>co_sart-plano.
        APPEND ls_main-plnid TO lt_plnum.
      WHEN zif_core_constants=>co_sart-prodo
        OR zif_core_constants=>co_sart-network
        OR zif_core_constants=>co_sart-iho
        OR zif_core_constants=>co_sart-process.
        APPEND ls_main-plnid TO lt_aufnr.
      WHEN OTHERS.

    ENDCASE.
  ENDLOOP.

  DATA: lr_msg     TYPE REF TO zcl_msg,
        lr_msg_tmp TYPE REF TO zcl_msg.

  lr_buffer = zcl_order_buffer=>get_instance( ).

  lr_buffer->add_orders( lt_aufnr ).
  lr_buffer->add_plannedorders( lt_plnum ).

  LOOP AT lt_main INTO ls_main.

    DATA: lf_pit TYPE z_pit.

    CALL FUNCTION 'DATE_TIME_CONVERT'
      EXPORTING
        date                 = ls_main-pldat
        time                 = ls_main-plzeit
      IMPORTING
        point_in_time        = lf_pit
      EXCEPTIONS
        date_before_rel_date = 1
        date_to_big          = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

    TRY .
        lr_order ?= lr_buffer->get_by_id( if_plnid = ls_main-plnid
                                          if_sart  = ls_main-sart ).

        lr_operation ?= lr_order->get_operation( if_vornr = ls_main-vornr if_aplzl = ls_main-aplzl ).

        lr_msg_tmp = lr_operation->midpoint_schedule( lf_pit ).
        IF lr_msg IS INITIAL.
          lr_msg = lr_msg_tmp.
        ELSE.
          lr_msg->append( lr_msg_tmp ).
        ENDIF.
      CATCH zcx_core.

    ENDTRY.

  ENDLOOP.
  lr_buffer->post( ).
  lr_msg->show( ).
