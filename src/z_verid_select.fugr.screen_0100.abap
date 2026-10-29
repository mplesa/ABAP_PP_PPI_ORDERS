PROCESS BEFORE OUTPUT.

*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC_MDFQ'
  MODULE tc_mdfq_change_tc_attr.
*&SPWIZARD: MODULE TC_MDFQ_CHANGE_COL_ATTR.
  LOOP AT   gt_mdfq
       INTO gs_mdfq
       WITH CONTROL tc_mdfq
       CURSOR tc_mdfq-current_line.
    MODULE tc_mdfq_get_lines.
*&SPWIZARD:   MODULE TC_MDFQ_CHANGE_FIELD_ATTR
  ENDLOOP.

  MODULE pbo_100.
*
PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC_MDFQ'
  LOOP AT gt_mdfq.
    CHAIN.
      FIELD gs_mdfq-werks.
      FIELD gs_mdfq-verid.
      FIELD gs_mdfq-bdatu.
      FIELD gs_mdfq-adatu.
      FIELD gs_mdfq-stlal.
      FIELD gs_mdfq-stlan.
      FIELD gs_mdfq-verto.
      FIELD gs_mdfq-bstmi.
      FIELD gs_mdfq-bstma.
      FIELD gs_mdfq-alort.
      FIELD gs_mdfq-elpro.
      FIELD gs_mdfq-prvbe.
      FIELD gs_mdfq-matko.
      FIELD gs_mdfq-plnnr.
      FIELD gs_mdfq-alnal.
      FIELD gs_mdfq-mksp.
      FIELD gs_mdfq-preih.
      FIELD gs_mdfq-maxmg.
      FIELD gs_mdfq-text1.
      FIELD gs_mdfq-meins.
    ENDCHAIN.
    FIELD gs_mdfq-marked
      MODULE tc_mdfq_mark ON REQUEST.
  ENDLOOP.
  MODULE tc_mdfq_user_command.
*&SPWIZARD: MODULE TC_MDFQ_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC_MDFQ_CHANGE_COL_ATTR.

  MODULE pai_100.
