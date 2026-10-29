*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT z_core_demo.
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
      lt_areas            TYPE TABLE OF /gib/dcp_areas,
      ls_area             TYPE /gib/dcp_areas,
      ls_kbed             TYPE kbedd.

DATA: mf_start   TYPE syuzeit,
      mf_seconds TYPE char10.
DATA: lf_lines TYPE sy-tabix.

INITIALIZATION.

  TRY.
      /gib/cl_dc_tools=>check_report_authority( if_repid = /gib/cl_dcp_tyco=>co_repid_dcp ).
    CATCH /gib/cx_dcv_no_authority INTO DATA(lr_auth_msg).
      MESSAGE lr_auth_msg TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
      LEAVE PROGRAM.
  ENDTRY.
START-OF-SELECTION.
  WRITE: 'Start Selection:', sy-uzeit.                      "#EC NOTEXT

  mf_start = sy-uzeit.
  SELECT werks area kapart FROM /gib/dcp_areas INTO CORRESPONDING FIELDS OF TABLE lt_areas "#EC CI_GENBUFF
                               WHERE werks IN so_werks    "#EC CI_SUBRC
                               AND area IN so_area.

  SELECT werks area sart plnid FROM /gib/dcp_main         "#EC CI_SUBRC
      INTO CORRESPONDING FIELDS OF TABLE lt_main        "#EC CI_GENBUFF
      WHERE werks IN so_werks
      AND area  IN so_area.

  CHECK lt_main IS NOT INITIAL.
  LOOP AT lt_main INTO ls_main.
    CASE ls_main-sart.
      WHEN /gib/cl_dcp_sart=>co_plano.
        APPEND ls_main-plnid TO lt_plnum.
      WHEN /gib/cl_dcp_sart=>co_prodo
        OR /gib/cl_dcp_sart=>co_network
        OR /gib/cl_dcp_sart=>co_iho
        OR /gib/cl_dcp_sart=>co_process.
        APPEND ls_main-plnid TO lt_aufnr.
      WHEN OTHERS.

    ENDCASE.
  ENDLOOP.

  CLEAR lt_plnum.
  SELECT plnum FROM plaf INTO TABLE lt_plnum            "#EC CI_NOWHERE
            .                                             "#EC CI_SUBRC
  lr_buffer = zcl_order_buffer=>get_instance( ).

  lr_buffer->add_orders( lt_aufnr ).
  lr_buffer->add_plannedorders( lt_plnum ).

  WRITE:/ 'End Selection:', sy-uzeit.                       "#EC NOTEXT
  mf_seconds = sy-uzeit - mf_start.
  WRITE: 'run-time:',  mf_seconds ,'S'.                     "#EC NOTEXT

  lf_lines =  lines( lr_buffer->mt_orders ).
  WRITE:/ 'Number of Orders:',lf_lines.                     "#EC NOTEXT

  LOOP AT lr_buffer->mt_orders INTO lr_order.
    LOOP AT lr_order->mt_operations INTO lr_operation.
      READ TABLE lt_areas WITH KEY werks = lr_operation->mr_workcenter->ms_crhd-werks
                                   area  = lr_operation->mr_workcenter->ms_crhd-arbpl TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        APPEND lr_operation TO lt_operations.
        TRY .
            lr_operation = lr_operation->get_predecessor( ).
            lr_operation = lr_operation->get_successor( ).
          CATCH zcx_operations.

        ENDTRY.
      ENDIF.

    ENDLOOP.
    APPEND LINES OF lr_order->mt_operations TO lt_total_operations.
  ENDLOOP.
  lf_lines =  lines( lt_operations ).
  WRITE:/ 'Number DCP Operations:', lf_lines.               "#EC NOTEXT

  lf_lines =  lines( lt_total_operations ).
  WRITE:/ 'Total number of Operations:', lf_lines.          "#EC NOTEXT

  WRITE:/ 'Operation List:'.                                "#EC NOTEXT
  LOOP AT lt_operations INTO lr_operation.
    NEW-LINE.
    WRITE: 'Werks', lr_operation->mr_workcenter->ms_crhd-werks. "#EC NOTEXT
    WRITE: 'Area' , lr_operation->mr_workcenter->ms_crhd-arbpl. "#EC NOTEXT
    WRITE: 'Order:', lr_operation->mr_order->mf_plnid.      "#EC NOTEXT
    WRITE: 'VIRTUAL:', lr_operation->mr_order->ms_caufvd-aufnr.
    WRITE: 'Sart:' , lr_operation->mr_order->mf_sart.       "#EC NOTEXT
    WRITE: 'Operation:' , lr_operation->mf_vornr.           "#EC NOTEXT
    WRITE: 'Material:',                                     "#EC NOTEXT
    lr_operation->mr_order->mr_material->mr_matnr->ms_mara-matnr. "#EC CI_FLDEXT_OK[2215424]
    READ TABLE lt_areas INTO ls_area WITH KEY werks = lr_operation->mr_workcenter->ms_crhd-werks
                                              area  = lr_operation->mr_workcenter->ms_crhd-arbpl.
    CHECK sy-subrc = 0.
    WRITE:  'KBED--->'.                                     "#EC NOTEXT
    READ TABLE lr_operation->mt_kbed INTO ls_kbed WITH KEY kapar = ls_area-kapart.
    CHECK sy-subrc = 0.
    WRITE: 'latest start-',                                 "#EC NOTEXT
           'Date:',                                         "#EC NOTEXT
           ls_kbed-sstad,
           'Time:',                                         "#EC NOTEXT
           ls_kbed-sstau.                                   "#EC NOTEXT
    WRITE: 'AFVGD---->'.
    WRITE: 'AUFPL:',
            lr_operation->ms_afvgd-aufpl,
           'APLZL:',
           lr_operation->ms_afvgd-aplzl.

  ENDLOOP.
