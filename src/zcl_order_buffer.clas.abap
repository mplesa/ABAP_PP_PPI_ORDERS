class ZCL_ORDER_BUFFER definition
  public
  create protected .

public section.
  type-pools ABAP .

  interfaces ZIF_ORDER_BUFFER .
  interfaces ZIF_ORDER_STACK .

  aliases GT_STACKED_ORDERS
    for ZIF_ORDER_STACK~GT_ORDERS .
  aliases MF_COMMIT_LOCK
    for ZIF_ORDER_BUFFER~MF_COMMIT_LOCK .
  aliases MT_ORDERS
    for ZIF_ORDER_BUFFER~MT_ORDERS .
  aliases ADD_ORDERS
    for ZIF_ORDER_BUFFER~ADD_ORDERS .
  aliases ADD_PLANNEDORDERS
    for ZIF_ORDER_BUFFER~ADD_PLANNEDORDERS .
  aliases ADD_TO_STACK
    for ZIF_ORDER_STACK~ADD .
  aliases CLEAR_STACK
    for ZIF_ORDER_STACK~CLEAR .
  aliases CREATE_PLANNEDORDER
    for ZIF_ORDER_BUFFER~CREATE_PLANNEDORDER .
  aliases GET_BY_ID
    for ZIF_ORDER_BUFFER~GET_BY_ID .
  aliases GET_ORDER
    for ZIF_ORDER_BUFFER~GET_ORDER .
  aliases GET_PLANNEDORDER
    for ZIF_ORDER_BUFFER~GET_PLANNEDORDER .
  aliases IS_PRESENT_IN_STACK
    for ZIF_ORDER_STACK~IS_PRESENT .
  aliases POST
    for ZIF_ORDER_BUFFER~POST .
  aliases REFRESH
    for ZIF_ORDER_BUFFER~REFRESH .
  aliases REMOVE_FROM_STACK
    for ZIF_ORDER_STACK~REMOVE .
  aliases SET_COMMIT_LOCK
    for ZIF_ORDER_BUFFER~SET_COMMIT_LOCK .
  aliases WAS_POST_CALLED
    for ZIF_ORDER_BUFFER~WAS_POST_CALLED .
  aliases TT_AUFNR
    for ZIF_ORDER_BUFFER~TT_AUFNR .
  aliases TT_ORDERS
    for ZIF_ORDER_BUFFER~TT_ORDERS .
  aliases TT_PLNUM
    for ZIF_ORDER_BUFFER~TT_PLNUM .

  class-data GF_PARALLEL_SEQUENCES type FLAG read-only .
  class-data GF_AVAIL_FIX_PLANNEDORDERS type ABAP_BOOL read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_INSTANCE
    returning
      value(RR_BUFFER) type ref to ZIF_ORDER_BUFFER .
  class-methods USE_PARALLEL_SEQUENCES
    importing
      !IF_ACTIVE type ABAP_BOOL default ABAP_TRUE .
  class-methods USE_AVAIL_FIX_PLANNEDORDERS
    importing
      !IF_ACTIVE type ABAP_BOOL default ABAP_TRUE .
  PROTECTED SECTION.
private section.

  class-data GS_TCA11 type TCA11 .
  class-data GR_ME type ref to ZIF_ORDER_BUFFER .
  class-data GF_NUMBER_OF_TASKS type SY-DBCNT value '1' ##NO_TEXT.
  class-data GF_POST_CALLED type FLAG .

  methods BUFFER_SALES_DOCUMENTS
    importing
      !IT_ORDERS type ZIF_ORDER_BUFFER~TT_ORDERS .
ENDCLASS.

CLASS ZCL_ORDER_BUFFER IMPLEMENTATION.

  METHOD use_parallel_sequences.
* Activate / deactivate parallel sequences for all orders read afterwards
    gf_parallel_sequences = if_active.
  ENDMETHOD.

  METHOD use_avail_fix_plannedorders.
* Activate / deactivate availability check for fixed planned orders
    gf_avail_fix_plannedorders = if_active.
  ENDMETHOD.

  METHOD add_orders.
    DATA: lf_max         TYPE sytabix,
          lr_prodo       TYPE REF TO zif_order,
          lf_aufnr       TYPE aufnr,
          lt_ord_pre     TYPE TABLE OF ord_pre,
          lt_ord_pre_new TYPE TABLE OF ord_pre,
          ls_ord_pre     TYPE ord_pre,
          lf_order_class TYPE classname.
    DATA: lt_plnum TYPE tt_plnum.

    LOOP AT it_aufnr INTO lf_aufnr.
      READ TABLE mt_orders WITH KEY table_line->mf_plnid = lf_aufnr INTO lr_prodo.
      IF sy-subrc <> 0.
        IF lf_aufnr+10(2) IS INITIAL.
          COLLECT lf_aufnr(10) INTO lt_plnum.
          CONTINUE.
        ENDIF.
        ls_ord_pre-aufnr = lf_aufnr.
        APPEND ls_ord_pre TO lt_ord_pre.
      ELSE.
        APPEND lr_prodo TO et_orders.
      ENDIF.
    ENDLOOP.

    IF lt_plnum IS NOT INITIAL.
      add_plannedorders( EXPORTING it_plnum = lt_plnum
                         IMPORTING et_plannedorders = DATA(lt_plannedorders) ).
      LOOP AT lt_plannedorders ASSIGNING FIELD-SYMBOL(<ls_plannedorder>).
        IF CAST zcl_order_plano( <ls_plannedorder> )->ms_plaf IS INITIAL.
          ls_ord_pre-aufnr = <ls_plannedorder>->mf_plnid.
          APPEND ls_ord_pre TO lt_ord_pre.
          DELETE mt_orders WHERE table_line = <ls_plannedorder>.
          DELETE lt_plannedorders.
        ENDIF.
      ENDLOOP.
      APPEND LINES OF lt_plannedorders TO et_orders.

    ENDIF.

    CHECK lt_ord_pre IS NOT INITIAL.
    lf_max = lines( lt_ord_pre ).
    zcl_services=>show_progress_bar( if_text  = 'Auftragsinformationen werden gelesen.'(001)
                                          if_max   = 1
                                          if_count = 1
                                          if_reset = abap_false ).
    lt_ord_pre_new = lt_ord_pre.
    CALL FUNCTION 'CO_DB_ORDER_PRE_READ' "#EC CI_USAGE_OK[2267333]
      EXPORTING
        explode_ord_net = space
        objects         = gs_tca11
        number_of_tasks = gf_number_of_tasks
        flg_no_banf     = abap_false
      TABLES
        ord_pre_imp     = lt_ord_pre
      EXCEPTIONS
        OTHERS          = 1.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.

    LOOP AT lt_ord_pre_new INTO ls_ord_pre.
      zcl_services=>show_progress_bar( if_text  = 'Auftragsinformationen werden gelesen.'(001)
                                           if_max   = lf_max
                                           if_count = sy-tabix
                                           if_reset = abap_false ).

      lr_prodo = zcl_order_prodo=>factory( ls_ord_pre-aufnr ).

      APPEND lr_prodo TO mt_orders.
      APPEND lr_prodo TO et_orders.
    ENDLOOP.

    buffer_sales_documents( et_orders ).
  ENDMETHOD.

METHOD add_plannedorders.
  DATA: lr_plano      TYPE REF TO zif_order,
        lt_plnum      TYPE TABLE OF plnum,
        lt_plafx      TYPE STANDARD TABLE OF plaf,
        lt_plaf       TYPE TABLE OF plaf,
        lt_kbedd      TYPE TABLE OF kbedd,
        lt_rsnum_head TYPE TABLE OF rsnum_pre,
        lt_bedid_head TYPE TABLE OF bedid_pre,
        lt_marc_head  TYPE  zif_werks_material=>tt_marc_head.

  LOOP AT it_plnum INTO DATA(lf_plnum).
    READ TABLE mt_orders WITH KEY table_line->mf_plnid = lf_plnum INTO lr_plano.
    IF sy-subrc <> 0.
      APPEND lf_plnum TO lt_plnum.
    ELSE.
      APPEND lr_plano TO et_plannedorders.
    ENDIF.
  ENDLOOP.

  CHECK lt_plnum IS NOT INITIAL.

  SELECT * FROM plaf INTO TABLE lt_plaf                   "#EC CI_SUBRC
    FOR ALL ENTRIES IN lt_plnum "#DC_NEEDED
    WHERE plnum = lt_plnum-table_line.        "#EC CI_ALL_FIELDS_NEEDED

*#get all entries from PLAFX buffer
  CALL FUNCTION 'PLAFX_ALL_GET'
    EXPORTING
      x_include_del = space
    TABLES
      plafx_exp     = lt_plafx.

  LOOP AT lt_plaf ASSIGNING FIELD-SYMBOL(<ls_plaf>).
*#if an entry exists in the PLAFX then overwrite the DB
    READ TABLE lt_plafx INTO DATA(ls_plaf) WITH KEY plnum = <ls_plaf>-plnum.
    IF sy-subrc = 0.
      <ls_plaf> = ls_plaf.
    ENDIF.
*#buffer for KBED
    APPEND INITIAL LINE TO lt_bedid_head ASSIGNING FIELD-SYMBOL(<ls_bedid_head>).
    <ls_bedid_head>-aufnr = <ls_plaf>-plnum.
    <ls_bedid_head>-bedid = zcl_order_plano=>get_bedid_from_plaf( <ls_plaf> ).
*#buffer for MARC
    APPEND INITIAL LINE TO lt_marc_head ASSIGNING FIELD-SYMBOL(<ls_marc_head>).
    <ls_marc_head>-werks = <ls_plaf>-plwrk.
    <ls_marc_head>-matnr = <ls_plaf>-matnr.

  ENDLOOP.

  DATA(lf_max) = lines( lt_plaf ).
  IF if_show_progress = abap_true.
    zcl_services=>show_progress_bar( if_text = 'Planauftragsinformationen werden gelesen.'(002) if_max = lf_max if_count = 0 if_reset = abap_false ).
  ENDIF.

  CALL FUNCTION 'CY_BT_KBED_PRE_READ'
    TABLES
      bedid_pre_tab = lt_bedid_head.

  LOOP AT lt_plaf ASSIGNING <ls_plaf>.

    CALL FUNCTION 'ENQUEUE_EMPLAFE'
      EXPORTING
        plnum          = <ls_plaf>-plnum
      EXCEPTIONS
        foreign_lock   = 2
        system_failure = 3.
    CHECK sy-subrc = 0.

    DATA(lf_typkz) = zcl_order_plano=>get_kbed_typkz_from_plaf( <ls_plaf> ).
    DATA(lf_bedid) = zcl_order_plano=>get_bedid_from_plaf( <ls_plaf> ).

    CALL FUNCTION 'CY_BT_KBED_TAB_GET' "#EC CI_SUBRC
      EXPORTING
        i_bedid      = lf_bedid
        i_flg_conv   = 'X'
        i_flg_work   = 'X'
        i_kbed_typkz = lf_typkz
      TABLES
        t_kbedd      = lt_kbedd
      EXCEPTIONS
        no_entry     = 01.
    IF sy-subrc <> 0.
      "no problem if the planned order has no requirement...
      "it usualy happens when the order is not fine schedueld/is a Preliminary planning order
    ENDIF.

    SORT lt_kbedd BY bedid vornr.                      "#EC CI_SORTLOOP

*#check KBED lines for inconsistent STATUS OBJECTS and remove them from KBED
    DELETE lt_kbedd WHERE obsta IS INITIAL.

    LOOP AT lt_kbedd INTO DATA(ls_kbedd).
      CALL FUNCTION 'STATUS_READ'
        EXPORTING
          objnr            = ls_kbedd-obsta
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
        CLEAR ls_kbedd-obsta.
        DATA lt_kbedd_temp TYPE TABLE OF kbedd.
        "This Functions replace the Delete of the KBED
        CALL FUNCTION 'CY_BT_KBED_ASSIGN'
          EXPORTING
            kbedd_imp = ls_kbedd
          TABLES
            t_kbedd   = lt_kbedd_temp.

        DATA: lf_tablename   TYPE  dd02l-tabname VALUE 'KBED',
              lt_kbed_update TYPE STANDARD TABLE OF kbed, "#EC CI_USAGE_OK[2380568]
              ls_kbed        TYPE kbed.       "#EC CI_USAGE_OK[2380568]
        CLEAR: ls_kbed.
        MOVE-CORRESPONDING ls_kbedd TO ls_kbed.
        APPEND ls_kbed TO lt_kbed_update.

      ENDIF.
    ENDLOOP."@LT_KBEDD

*#we manualy remove the OBSTA from the KBED entry in order to not have further buffering problems
    IF lt_kbed_update IS NOT INITIAL.
      CALL FUNCTION 'DB_UPDATE_TABLE'
        EXPORTING
          tablename = lf_tablename
        TABLES
          inttab    = lt_kbed_update
        EXCEPTIONS
          OTHERS    = 0.

      CLEAR lt_kbed_update.
    ENDIF.
    CALL FUNCTION 'DEQUEUE_EMPLAFE'
      EXPORTING
        plnum = <ls_plaf>-plnum.
  ENDLOOP."@LT_PLAF

  zcl_werks_material=>add_to_buffer( lt_marc_head ).

*#perfortmance win when creating an enhancement in Fuba CO_IT_ITAB_CREATE
  zcl_order_plano=>gf_stop = 'X'.

  LOOP AT lt_plnum INTO lf_plnum.
    READ TABLE lt_plaf INTO ls_plaf WITH KEY plnum = lf_plnum.
    IF sy-subrc <> 0.
      ls_plaf-plnum = lf_plnum.
    ENDIF.
    IF if_show_progress = abap_true.
      zcl_services=>show_progress_bar( if_text = 'Planauftragsinformationen werden gelesen.'(002) if_max = lf_max if_count = sy-tabix if_reset = abap_false ).
    ENDIF.

    DATA(lr_planned_order) = NEW zcl_order_plano( ls_plaf ).
    READ TABLE lt_plaf TRANSPORTING NO FIELDS
      WITH KEY plnum = lr_planned_order->ms_plaf-plnum.
    IF sy-subrc <> 0.
      CLEAR: lr_planned_order->ms_plaf.
    ENDIF.
    lr_plano ?= lr_planned_order.
    APPEND lr_plano TO mt_orders.
    APPEND lr_plano TO et_plannedorders.
  ENDLOOP.

*#perfortmance win when creating an enhancement in Fuba CO_IT_ITAB_CREATE
  zcl_order_plano=>gf_stop = space.
  buffer_sales_documents( et_plannedorders ).
ENDMETHOD.

METHOD zif_order_buffer~create_plannedorder.
  DATA: ls_createdheaderdata TYPE bapiplaf_e1,
        lf_plnum             TYPE plnum,
        ls_plaf              TYPE plaf,
        lf_return            TYPE bapireturn1.

  CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'      "#EC CI_USAGE_OK[2438131]
    EXPORTING
      headerdata        = is_headerdata
    IMPORTING
      return            = lf_return
      plannedorder      = lf_plnum
      createdheaderdata = ls_createdheaderdata.

*#SAP does not have a MAPPING from BAPIPLAF_E1 to PLAF (Mapping made from FUBA: MAP2E_PLAF_TO_BAPIPLAF_E1_SL)
  MOVE ls_createdheaderdata-rough_schedindexlt_index TO ls_plaf-groid.
  MOVE ls_createdheaderdata-sched_rate_index         TO ls_plaf-ratid.
  MOVE ls_createdheaderdata-reduced_qty              TO ls_plaf-abmng.
  MOVE ls_createdheaderdata-revision_level           TO ls_plaf-revlv.
  MOVE ls_createdheaderdata-configuration            TO ls_plaf-cuobj.
  MOVE ls_createdheaderdata-backflush_ind            TO ls_plaf-rgekz.
  MOVE ls_createdheaderdata-kanban_indicator         TO ls_plaf-kbnkz.
  MOVE ls_createdheaderdata-sim_req_no               TO ls_plaf-sbnum.
  MOVE ls_createdheaderdata-plng_scenario_lt         TO ls_plaf-plscn.
  MOVE ls_createdheaderdata-object_type              TO ls_plaf-obart.
  MOVE ls_createdheaderdata-sched_error_rs           TO ls_plaf-groer.
  MOVE ls_createdheaderdata-sched_error_pr           TO ls_plaf-rater.
  MOVE ls_createdheaderdata-scheduling_error         TO ls_plaf-trmer.
  MOVE ls_createdheaderdata-scheduling_ind           TO ls_plaf-trmkz.
  MOVE ls_createdheaderdata-cap_req_recordid         TO ls_plaf-bedid.
  MOVE ls_createdheaderdata-prod_finish_date         TO ls_plaf-tered.
  MOVE ls_createdheaderdata-prod_start_date          TO ls_plaf-terst.
  MOVE ls_createdheaderdata-production_note          TO ls_plaf-frthw.
  MOVE ls_createdheaderdata-numerator                TO ls_plaf-umrez.
  MOVE ls_createdheaderdata-req_totaling             TO ls_plaf-agreq.
  MOVE ls_createdheaderdata-req_plan_no              TO ls_plaf-pbdnr.
  MOVE ls_createdheaderdata-pln_wo_assembly          TO ls_plaf-vrpla.
  MOVE ls_createdheaderdata-atp_check_type           TO ls_plaf-kzavc.
  MOVE ls_createdheaderdata-lead_sched_level         TO ls_plaf-lvsch.
  MOVE ls_createdheaderdata-withdr_qty               TO ls_plaf-wamng.
  MOVE ls_createdheaderdata-deliv_qty                TO ls_plaf-wemng.
  MOVE ls_createdheaderdata-spec_stval_ind           TO ls_plaf-kzbws.
  MOVE ls_createdheaderdata-req_record_no            TO ls_plaf-rqnum.
  MOVE ls_createdheaderdata-entry_qnt                TO ls_plaf-erfmg.
  MOVE ls_createdheaderdata-denominatr               TO ls_plaf-umren.
  MOVE ls_createdheaderdata-commit_qty               TO ls_plaf-vfmng.
  MOVE ls_createdheaderdata-available_conf           TO ls_plaf-mdpbv.
  MOVE ls_createdheaderdata-collord_lead_ind         TO ls_plaf-prnkz.
  MOVE ls_createdheaderdata-ass_ord_ind              TO ls_plaf-monkz.
  MOVE ls_createdheaderdata-seq_number_order         TO ls_plaf-seqnr.
  MOVE ls_createdheaderdata-disp_cap_ind             TO ls_plaf-kapfx.
  MOVE ls_createdheaderdata-sched_prod_dates         TO ls_plaf-prsch.
  MOVE ls_createdheaderdata-total_commit_dat         TO ls_plaf-gsbtr.
  MOVE ls_createdheaderdata-time_of_action           TO ls_plaf-mdact.
  MOVE ls_createdheaderdata-date_of_action           TO ls_plaf-mdacd.
  MOVE ls_createdheaderdata-action_plnd_ord          TO ls_plaf-mdacc.
  MOVE ls_createdheaderdata-plord_ctrl               TO ls_plaf-mdach.
  MOVE ls_createdheaderdata-firming_ind              TO ls_plaf-auffx.
  MOVE ls_createdheaderdata-conversion_ind           TO ls_plaf-umskz.
  MOVE ls_createdheaderdata-mrp_controller           TO ls_plaf-dispo.
  MOVE ls_createdheaderdata-gr_proc_time             TO ls_plaf-webaz.
  MOVE ls_createdheaderdata-plan_open_date           TO ls_plaf-pertr.
  MOVE ls_createdheaderdata-order_fin_date           TO ls_plaf-pedtr.
  MOVE ls_createdheaderdata-reserv_no                TO ls_plaf-rsnum.
  MOVE ls_createdheaderdata-sched_line               TO ls_plaf-kdein.
  MOVE ls_createdheaderdata-s_ord_item               TO ls_plaf-kdpos.
  MOVE ls_createdheaderdata-sales_ord                TO ls_plaf-kdauf.
  MOVE ls_createdheaderdata-acctasscat               TO ls_plaf-knttp.
  MOVE ls_createdheaderdata-bom_exp_fix_ind          TO ls_plaf-stlfx.
  MOVE ls_createdheaderdata-procurement_type         TO ls_plaf-beskz.
  MOVE ls_createdheaderdata-order_type               TO ls_plaf-paart.
  MOVE ls_createdheaderdata-prod_plant               TO ls_plaf-pwwrk.
  MOVE ls_createdheaderdata-plan_plant               TO ls_plaf-plwrk.
  MOVE ls_createdheaderdata-material_long            TO ls_plaf-matnr.
  MOVE ls_createdheaderdata-plannedorder_num         TO ls_plaf-plnum.
  MOVE ls_createdheaderdata-order_start_date         TO ls_plaf-psttr.
  MOVE ls_createdheaderdata-req_quan                 TO ls_plaf-bdmng.
  MOVE ls_createdheaderdata-fixed_scrap_qty          TO ls_plaf-avmng.
  MOVE ls_createdheaderdata-total_plord_qty          TO ls_plaf-gsmng.
  MOVE ls_createdheaderdata-specialproc_type         TO ls_plaf-sobes.
  MOVE ls_createdheaderdata-setreserno               TO ls_plaf-arsnr.
  MOVE ls_createdheaderdata-change_number            TO ls_plaf-aennr.
  MOVE ls_createdheaderdata-bom_status               TO ls_plaf-ststa.
  MOVE ls_createdheaderdata-alternative_bom          TO ls_plaf-stalt.
  MOVE ls_createdheaderdata-bom_usage                TO ls_plaf-stlan.
  MOVE ls_createdheaderdata-validity_object          TO ls_plaf-techs.
  MOVE ls_createdheaderdata-prod_scheduler           TO ls_plaf-plgrp.
  MOVE ls_createdheaderdata-runschd_hd               TO ls_plaf-aufnr.
  MOVE ls_createdheaderdata-version                  TO ls_plaf-verid.
  MOVE ls_createdheaderdata-dist_key                 TO ls_plaf-verto.
  MOVE ls_createdheaderdata-settlitmno               TO ls_plaf-arsps.
  MOVE ls_createdheaderdata-purch_org                TO ls_plaf-ekorg.
  MOVE ls_createdheaderdata-agmt_item                TO ls_plaf-ktpnr.
  MOVE ls_createdheaderdata-agreement                TO ls_plaf-konnr.
  MOVE ls_createdheaderdata-fixed_vend               TO ls_plaf-flief.
  MOVE ls_createdheaderdata-quotarritm               TO ls_plaf-qupos.
  MOVE ls_createdheaderdata-quota_arr                TO ls_plaf-qunum.
  MOVE ls_createdheaderdata-bomexpl_date             TO ls_plaf-paltr.
  MOVE ls_createdheaderdata-bomexpl_no               TO ls_plaf-sernr.
  MOVE ls_createdheaderdata-int_proj_item            TO ls_plaf-pspel.
  MOVE ls_createdheaderdata-stge_loc                 TO ls_plaf-lgort.
  MOVE ls_createdheaderdata-consumpt                 TO ls_plaf-kzvbr.
  MOVE ls_createdheaderdata-spec_stock               TO ls_plaf-sobkz.
  MOVE ls_createdheaderdata-order_str_time           TO ls_plaf-pstti.
  MOVE ls_createdheaderdata-order_fin_time           TO ls_plaf-pedti.
  MOVE ls_createdheaderdata-sc_vendor                TO ls_plaf-lblkz.
  MOVE ls_createdheaderdata-deliv_rec_vendor         TO ls_plaf-emlif.
  MOVE ls_createdheaderdata-mrp_area                 TO ls_plaf-berid.
  MOVE ls_createdheaderdata-issue_mrp_area           TO ls_plaf-uberi.
  MOVE ls_createdheaderdata-repetitive_ind           TO ls_plaf-remfl.
  MOVE ls_createdheaderdata-mpn_material_long        TO ls_plaf-ematn.
  MOVE ls_createdheaderdata-base_uom                 TO ls_plaf-meins.
  MOVE ls_createdheaderdata-unit_of_entry            TO ls_plaf-erfme.
  MOVE ls_createdheaderdata-suppl_stloc              TO ls_plaf-reslo.
  MOVE ls_createdheaderdata-stk_seg_long             TO ls_plaf-sgt_scat.

  CALL FUNCTION 'UPD_PLAF_SINGLE'
    EXPORTING
      iplaf                    = ls_plaf
      changed_flag             = abap_true
      new_scheduling_flg       = abap_true
    EXCEPTIONS
      object_logically_deleted = 1
      OTHERS                   = 2.
  IF sy-subrc = 0.
*#the PLANNEDORDER is already in update_task waiting to be created
*#so we only need to modify it from this poin onwards
    CALL FUNCTION 'PLAFX_STATUS_SET'
      EXPORTING
        statu          = 'U'
        plnum          = ls_plaf-plnum
      EXCEPTIONS
        plaf_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
  ENDIF.

  rr_order ?= NEW zcl_order_plano( ls_plaf ).
  APPEND rr_order TO mt_orders.
ENDMETHOD.

  METHOD zif_order_buffer~get_by_id.
    DATA: lf_plnum TYPE plnum.
    CASE if_sart.
      WHEN zif_core_constants=>co_sart-plano.
        lf_plnum = if_plnid.
        rr_order = get_plannedorder( lf_plnum ).
      WHEN OTHERS.
        rr_order = get_order( if_plnid ).
    ENDCASE.
  ENDMETHOD.

  METHOD get_order.
    DATA: lt_aufnr TYPE tt_aufnr,
          lt_order TYPE tt_orders.

    APPEND if_aufnr TO lt_aufnr.
    add_orders( EXPORTING it_aufnr = lt_aufnr
                IMPORTING et_orders = lt_order ).
    READ TABLE lt_order INTO rr_order INDEX 1.
  ENDMETHOD.

  METHOD get_plannedorder.
    DATA: lt_plnum        TYPE tt_plnum,
          lt_plannedorder TYPE tt_orders.
    APPEND if_plnum TO lt_plnum.
    add_plannedorders( EXPORTING it_plnum = lt_plnum
                                 if_show_progress = abap_false
                       IMPORTING et_plannedorders = lt_plannedorder ).
    READ TABLE lt_plannedorder INTO rr_plannedorder INDEX 1.
  ENDMETHOD.

METHOD zif_order_buffer~post.
  er_msg = NEW zcl_msg( ).
  DATA: lf_dummy TYPE c.
  CHECK zcl_order_buffer=>get_instance( )->mf_commit_lock = abap_false.

  DATA lt_kbedb TYPE TABLE OF kbedb.
  DATA: lf_gui TYPE c.

  CALL FUNCTION 'GUI_IS_AVAILABLE'
    IMPORTING
      return = lf_gui.
  IF lf_gui IS INITIAL.
    DATA(lf_no_dialog) = abap_true.
  ENDIF.

  CALL FUNCTION 'CY_BT_APO_KBED_BT_GET'
    TABLES
      et_kbedbt = lt_kbedb.

  CALL FUNCTION 'MD_POST_PLANNED_ORDERS' "#EC CI_SUBRC
    EXPORTING
      ncomm  = 'X'
    EXCEPTIONS
      OTHERS = 0.

  DATA: lt_objn_tab TYPE TABLE OF objn_tab.
  CALL FUNCTION 'CO_ZV_ORDER_POST'
    EXPORTING
      commit_flag    = ' '
      ext_flg        = 'X'
      trans_typ      = 'V'
      no_dialog      = lf_no_dialog
    TABLES
      caufvd_num_exp = et_changed_orders
      objn_tab_exp   = lt_objn_tab
    EXCEPTIONS
      no_change      = 01
      update_reject  = 02.
  DATA(lf_subrc) = sy-subrc.
  IF lf_subrc = 0.
    "update the TEMP orders numbers for the newly created orders
    LOOP AT et_changed_orders INTO DATA(ls_changed_order) WHERE aufnr_tmp(1) = '%'.
      gr_me->get_order( ls_changed_order-aufnr_tmp )->change_temp_aufnr( ls_changed_order-aufnr_neu ).
    ENDLOOP.
  ENDIF.

  CASE lf_subrc.
    WHEN 0
      OR 1.
      IF if_no_commit_work IS INITIAL.
        IF if_wait IS NOT INITIAL.
          COMMIT WORK AND WAIT.
        ELSE.
          COMMIT WORK.
        ENDIF.
      ENDIF.

    WHEN 2.
      er_msg->add_symsg( ).
      IF if_no_commit_work = abap_false.
        MESSAGE s630(z_core) INTO lf_dummy.
        er_msg->add_symsg( ).
        ROLLBACK WORK.
      ENDIF.

  ENDCASE.
*#remove all the stacked orders
  IF if_no_commit_work = abap_false.
    gr_me->refresh( )."the refresh will also clear the stack
  ENDIF.

  gf_post_called = 'X'.

ENDMETHOD.

  METHOD zif_order_buffer~refresh.
    IF if_ignore_commit_lock = abap_false.
      CHECK mf_commit_lock = abap_false.
    ENDIF.

*#clear everything from the SAP Buffers
    clear_stack( ).

    FREE mt_orders.
  ENDMETHOD.

METHOD zif_order_buffer~set_commit_lock.
  mf_commit_lock = if_value.
ENDMETHOD.

  METHOD zif_order_buffer~was_post_called.
    rf_answer = gf_post_called.
  ENDMETHOD.

  METHOD zif_order_stack~add.
    IF is_present_in_stack( ir_order ) IS INITIAL.

      APPEND ir_order TO gt_stacked_orders.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order_stack~clear.
    DATA: lr_plano TYPE REF TO zcl_order_plano,
          lr_order TYPE REF TO zif_order.
    DATA: lr_library TYPE REF TO   if_cmx_xs_library,
          ls_context TYPE cocr_cmx_s_cr_data,
          lt_nid     TYPE  cmx_xs_t_node_guid,
          lr_session TYPE REF TO if_cmx_xs_session.

    CHECK zcl_order_buffer=>get_instance( )->mf_commit_lock = abap_false.

    LOOP AT gt_stacked_orders INTO lr_order.
      TRY .
          lr_plano ?= lr_order.
          CALL FUNCTION 'DEQUEUE_EMPLAFE'
            EXPORTING
              plnum = lr_plano->ms_plaf-plnum.

        CATCH cx_sy_move_cast_error.

          CALL FUNCTION 'CO_ZF_ORDER_DELOCK'
            EXPORTING
              aufnr = lr_order->ms_caufvd-aufnr.
          CALL FUNCTION 'DEQUEUE_EMRKPF'
            EXPORTING
              rsnum = lr_order->ms_caufvd-rsnum.

          IF lr_order->ms_caufvd-prueflos IS NOT INITIAL.
            CALL FUNCTION 'DEQUEUE_EQQALS1'
              EXPORTING
                prueflos = lr_order->ms_caufvd-prueflos.
          ENDIF.
      ENDTRY.
      LOOP AT lr_order->mt_afvgd INTO DATA(ls_afvgd).
        IF ls_afvgd-banfn IS NOT INITIAL.
          CALL FUNCTION 'DEQUEUE_EMEBANE'
            EXPORTING
              banfn = ls_afvgd-banfn.
        ENDIF.
      ENDLOOP.
      CLEAR lt_nid.

      TRY.

          lr_library = cl_cmx_xs_system=>get_library( ).

          lr_session = cl_cmx_xs_system=>get_session( ).
          ls_context-aufnr = lr_order->mf_plnid.
          ls_context-aufpl = lr_order->ms_caufvd-aufpl.
          TRY .
              lt_nid = lr_library->get_nids_by_context(
                                     application  = cl_cocr_cmx_top=>con_app_order
                                     skip_initial = cl_cocr_cmx_top=>con_x
                                     data         = ls_context ).

            CATCH cx_cmx_xs_exception.

          ENDTRY.
        CATCH cx_cmx_xs_exception.

      ENDTRY.
      LOOP AT lt_nid INTO DATA(lf_nid).

        TRY .
            lr_session->dequeue_persistent( lf_nid  ).
          CATCH cx_cmx_xs_exception.
        ENDTRY.

        CALL FUNCTION 'DEQUEUE_ECMX_XS'
          EXPORTING
            nid          = lf_nid "'051MXrxC7kggoAdIAhfMCG'
            enqueue_type = ''.

        CALL FUNCTION 'DEQUEUE_ECMX_XS'
          EXPORTING
            nid          = lf_nid "'051MXrxC7kggoAdIAhfMCG'
            enqueue_type = ''.

      ENDLOOP.
    ENDLOOP.

    CLEAR: gt_stacked_orders.

    CALL FUNCTION 'CO_DB_DATA_RESET'.
    CALL FUNCTION 'CO_ZF_DATA_RESET_COMPLETE'.
    CALL FUNCTION 'REFRESH_PLAFX_TABLES'.
*#Temporäre Nummerierung Zurücksetzen.
    CALL FUNCTION 'CO_BT_ZAEHLTAB_REFRESH'.
    CALL FUNCTION 'CO_EXT_ORDER_RESET'.
    CALL FUNCTION 'CP_EX_DATA_REFRESH_NEW'.
    CALL FUNCTION 'CO_BO_DATA_RESET'.
*#WM Puffer initialisieren für PP
*#The function Module does not exist for EHP lower then 7
    CALL FUNCTION 'OM_FUNC_MODULE_EXIST'
      EXPORTING
        function_module = 'L_WMPP_INITIALIZATION'
      EXCEPTIONS
        not_existent    = 1
        OTHERS          = 2.
    IF sy-subrc = 0.
      CALL FUNCTION 'L_WMPP_INITIALIZATION'.
    ENDIF.

  ENDMETHOD.

  METHOD zif_order_stack~is_present.

    READ TABLE gt_stacked_orders WITH KEY table_line = ir_order TRANSPORTING NO FIELDS.
    CHECK sy-subrc = 0.
    rf_answer = abap_true.
  ENDMETHOD.

  METHOD zif_order_stack~remove.
    CHECK zcl_order_buffer=>get_instance( )->mf_commit_lock = abap_false.

*#clear everything from the SAP Buffers
    clear_stack( ).

*#remove the order object from the buffer
    DATA: lr_buffer TYPE REF TO zcl_order_buffer.
    TRY .
        lr_buffer ?= gr_me.
        DELETE lr_buffer->zif_order_buffer~mt_orders WHERE table_line = ir_order.
      CATCH cx_sy_move_cast_error.

    ENDTRY.
  ENDMETHOD.

  METHOD buffer_sales_documents.
    DATA: lr_order          TYPE REF TO zif_order,
          lt_sales_key      TYPE TABLE OF sales_key,
          lt_sales_item_key TYPE TABLE OF sales_item_key.
    FIELD-SYMBOLS: <ls_sales_key>      TYPE sales_key,
                   <ls_sales_item_key> TYPE sales_item_key.

*#not yet implemented
    RETURN.

*#Hear we have more posibilities from where to get the KDAUF and KDPOS:
*#        AFPOD-KDPOS
*#        CAUFVD-VBELP
*#        CAUFVD-KDOIS_AFKO

    LOOP AT it_orders INTO lr_order WHERE table_line->ms_caufvd-vbeln IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_sales_key ASSIGNING <ls_sales_key>.
      <ls_sales_key>-vbeln = lr_order->ms_caufvd-vbeln.
      IF lr_order->ms_caufvd-vbelp IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_sales_item_key ASSIGNING <ls_sales_item_key>.
        <ls_sales_item_key>-vbeln = lr_order->ms_caufvd-vbeln.
        <ls_sales_item_key>-posnr = lr_order->ms_caufvd-vbelp.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'SD_VBAK_ARRAY_READ'
      TABLES
        it_vbak_key           = lt_sales_key
      EXCEPTIONS
        records_not_found     = 1
        records_not_requested = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

    CALL FUNCTION 'SD_VBAP_ARRAY_READ'
      TABLES
        it_vbap_key           = lt_sales_item_key
      EXCEPTIONS
        records_not_found     = 1
        records_not_requested = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

    CALL FUNCTION 'SD_VBEP_ARRAY_READ_VBELN'
      TABLES
        it_vbak_key           = lt_sales_key
      EXCEPTIONS
        records_not_found     = 1
        records_not_requested = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.
  ENDMETHOD.

  METHOD class_constructor.
    gs_tca11-flg_alt  = abap_true. "Kennzeichen: Pläne
    gs_tca11-flg_seq  = abap_true. "Kennzeichen: Folgen
    gs_tca11-flg_opr  = abap_true. "Kennzeichen: Vorgänge
    gs_tca11-flg_sop  = abap_false."Kennzeichen: Untervorgänge X
    gs_tca11-flg_mat  = abap_false."Kennzeichen: Materialkomponente  "at big selections can come to short dump
    gs_tca11-flg_fhm  = abap_true. "Kennzeichen: Fertigungshilfsmittel
    gs_tca11-flg_qmk  = abap_false."Kennzeichen: Prüfmerkmale X
    gs_tca11-flg_qmw  = abap_false."Kennzeichen: Prüfmerkmalswerte X
    gs_tca11-flg_aob  = abap_true. "Schlüssel: Sicht auf die Anordnungsbeziehungen
    gs_tca11-flg_txt  = abap_false."Kennzeichen: PS-Texte X
    gs_tca11-flg_pms  = abap_false."Flag für Wartungspaketzuordnung
    gs_tca11-flg_aps  = abap_true. "Kennzeichen: Auftragspositionen
    gs_tca11-flg_bed  = abap_true. "Kennzeichen: Kapazitätsbedarfe
    gs_tca11-flg_phas = abap_true. "Kennzeichen: CAP/Teiloperationen aktiv
    gs_tca11-flg_mst  = abap_false."Kennzeichen: Meilenstein X
    gs_tca11-flg_snt  = abap_false."Kennzeichen: Teilnetz X
    gs_tca11-flg_feat = abap_true. "Kennzeichen: Rezept/Prozeßvorgabe aktiv
    gs_tca11-flg_feav = abap_true. "Kennzeichen: Prozeßvorgabemerkmal/Parameterwert

    gf_number_of_tasks = 6.
  ENDMETHOD.

  METHOD get_instance.
    IF gr_me IS NOT BOUND.
      CREATE OBJECT gr_me TYPE zcl_order_buffer.
    ENDIF.
    rr_buffer = gr_me.
  ENDMETHOD.
ENDCLASS.
