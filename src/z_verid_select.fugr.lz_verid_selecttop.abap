FUNCTION-POOL z_verid_select.        "MESSAGE-ID ..

TABLES: mdfq, mara.
CONSTANTS: BEGIN OF co_uc,
              save TYPE syucomm VALUE 'SAVE',
              exit TYPE syucomm VALUE 'EXIT',
           END OF co_uc.
TYPES: BEGIN OF ts_mdfq.
        INCLUDE TYPE mdfq.
TYPES: meins  TYPE meins.
TYPES: marked TYPE flag.
TYPES: END OF ts_mdfq.

DATA: gt_mdfq TYPE STANDARD TABLE OF ts_mdfq,
      gs_mdfq TYPE ts_mdfq,
      gt_mkal TYPE TABLE OF mkal,
      gs_mkal TYPE mkal.

DATA: gr_order TYPE REF TO zif_order.

FORM initialize_fuba.
  CLEAR: gt_mdfq, gs_mdfq, gt_mkal, gs_mkal, gr_order.
ENDFORM.

FORM build_mdfq.
  DATA: ls_mkal TYPE mkal,
        ls_mdfq TYPE ts_mdfq,
        ls_mdfq_template TYPE ts_mdfq.

  LOOP AT gt_mkal INTO ls_mkal.
    MOVE-CORRESPONDING ls_mkal TO ls_mdfq.
    ls_mdfq-meins = gr_order->mr_material->mr_matnr->ms_mara-meins.
    APPEND ls_mdfq TO gt_mdfq.
  ENDLOOP.

ENDFORM.
