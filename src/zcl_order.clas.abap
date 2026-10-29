class ZCL_ORDER definition
  public
  abstract
  create public

  global friends ZIF_OPERATION .

public section.
  type-pools ABAP .
  type-pools COXT .

  interfaces ZIF_AMOUNTS .
  interfaces ZIF_LONG_TEXT .
  interfaces ZIF_JSTATUS .
  interfaces ZIF_ORDER .
  interfaces ZIF_PEGGED_REQUIREMENT .

  aliases CO_AUTHORITY
    for ZIF_ORDER~CO_AUTHORITY .
  aliases CO_AUTYP
    for ZIF_ORDER~CO_AUTYP .
  aliases CO_VBKZ
    for ZIF_ORDER~CO_VBKZ .
  aliases GT_SCHEDULING_TYPE
    for ZIF_ORDER~GT_SCHEDULING_TYPE .
  aliases GT_T457T
    for ZIF_PEGGED_REQUIREMENT~GT_T457T .
  aliases MF_PLNID
    for ZIF_ORDER~MF_PLNID .
  aliases MF_SART
    for ZIF_ORDER~MF_SART .
  aliases MR_MATERIAL
    for ZIF_ORDER~MR_MATERIAL .
  aliases MR_PEGGED_REQUIREMENT
    for ZIF_ORDER~MR_PEGGED_REQUIREMENT .
  aliases MR_ROUTING_MASTER
    for ZIF_ORDER~MR_ROUTING_MASTER .
  aliases MS_AFPOD
    for ZIF_ORDER~MS_AFPOD .
  aliases MS_CAUFVD
    for ZIF_ORDER~MS_CAUFVD .
  aliases MS_KBKO
    for ZIF_ORDER~MS_KBKO .
  aliases MS_TCX00
    for ZIF_ORDER~MS_TCX00 .
  aliases MT_AFFL
    for ZIF_ORDER~MT_AFFL .
  aliases MT_AFVGD
    for ZIF_ORDER~MT_AFVGD .
  aliases MT_AFVGD_SUB
    for ZIF_ORDER~MT_AFVGD_SUB .
  aliases MT_OPERATIONS
    for ZIF_ORDER~MT_OPERATIONS .
  aliases MT_OPERATION_SEQUANCES
    for ZIF_ORDER~MT_OPERATION_SEQUANCES .
  aliases MT_STATUSES
    for ZIF_ORDER~MT_STATUSES .
  aliases CHANGE_PRODUCTION_VERSION
    for ZIF_ORDER~CHANGE_PRODUCTION_VERSION .
  aliases CHANGE_PROD_VERSION_DIALOG
    for ZIF_ORDER~CHANGE_PROD_VERSION_DIALOG .
  aliases CHANGE_SEQUENCE_NUMBER
    for ZIF_ORDER~CHANGE_SEQUENCE_NUMBER .
  aliases CHANGE_TEMP_AUFNR
    for ZIF_ORDER~CHANGE_TEMP_AUFNR .
  aliases CHANGE_TOTAL_QUANTITY
    for ZIF_ORDER~CHANGE_TOTAL_QUANTITY .
  aliases CHANGE_TOTAL_QUAN_DIALOG
    for ZIF_ORDER~CHANGE_TOTAL_QUAN_DIALOG .
  aliases CHECK_CAPACITY_AVAILABILITY
    for ZIF_ORDER~CHECK_CAPACITY_AVAILABILITY .
  aliases CHECK_MATERIAL_AVAILABILITY
    for ZIF_ORDER~CHECK_MATERIAL_AVAILABILITY .
  aliases DIALOG
    for ZIF_ORDER~DIALOG .
  aliases DISPLAY_LONG_TEXT
    for ZIF_ORDER~DISPLAY_LONG_TEXT .
  aliases DISPLAY_PEGGED_REQUIREMENT
    for ZIF_PEGGED_REQUIREMENT~DISPLAY .
  aliases EDIT_LONG_TEXT
    for ZIF_ORDER~EDIT_LONG_TEXT .
  aliases GET_BASIC_END
    for ZIF_ORDER~GET_BASIC_END .
  aliases GET_BASIC_START
    for ZIF_ORDER~GET_BASIC_START .
  aliases GET_COMPRESSION_TABLE
    for ZIF_ORDER~GET_COMPRESSION_TABLE .
  aliases GET_DELIVERY_OPERATION
    for ZIF_ORDER~GET_DELIVERY_OPERATION .
  aliases GET_FIRST_OPERATION
    for ZIF_ORDER~GET_FIRST_OPERATION .
  aliases GET_GRANTED_AUTHORITY
    for ZIF_ORDER~GET_GRANTED_AUTHORITY .
  aliases GET_LAST_OPERATION
    for ZIF_ORDER~GET_LAST_OPERATION .
  aliases GET_LEAD_PLNID
    for ZIF_ORDER~GET_LEAD_PLNID .
  aliases GET_OPERATION
    for ZIF_ORDER~GET_OPERATION .
  aliases GET_OPERATIONS
    for ZIF_ORDER~GET_OPERATIONS .
  aliases GET_ORDER_AMOUNT
    for ZIF_ORDER~GET_ORDER_AMOUNT .
  aliases GET_PEGGED_REQUIREMENT
    for ZIF_PEGGED_REQUIREMENT~GET .
  aliases GET_PREDECESSOR_OPERATION
    for ZIF_ORDER~GET_PREDECESSOR_OPERATION .
  aliases GET_PRODUCTION_AIDS
    for ZIF_ORDER~GET_PRODUCTION_AIDS .
  aliases GET_PRODUCTION_VERSIONS
    for ZIF_ORDER~GET_PRODUCTION_VERSIONS .
  aliases GET_ROUTING_MASTER
    for ZIF_ORDER~GET_ROUTING_MASTER .
  aliases GET_SUCCESSOR_OPERATION
    for ZIF_ORDER~GET_SUCCESSOR_OPERATION .
  aliases GET_UPDATE_KEY
    for ZIF_ORDER~GET_UPDATE_KEY .
  aliases HAS_LONG_TEXT
    for ZIF_ORDER~HAS_LONG_TEXT .
  aliases HAS_STATUS
    for ZIF_ORDER~HAS_STATUS .
  aliases REFRESH
    for ZIF_ORDER~REFRESH .
  aliases RELEASE
    for ZIF_ORDER~RELEASE .
  aliases REMOVE_STATUS
    for ZIF_ORDER~REMOVE_STATUS .
  aliases SCHEDULE
    for ZIF_ORDER~SCHEDULE .
  aliases SCHEDULE_BASIC_DATES
    for ZIF_ORDER~SCHEDULE_BASIC_DATES .
  aliases SCHEDULE_BASIC_DATES_DIALOG
    for ZIF_ORDER~SCHEDULE_BASIC_DATES_DIALOG .
  aliases SET_STATUS
    for ZIF_ORDER~SET_STATUS .
  aliases START_UPDATE
    for ZIF_ORDER~START_UPDATE .
  aliases TEMP_AUFNR_CHANGED
    for ZIF_ORDER~TEMP_AUFNR_CHANGED .
  aliases TT_FEHL_KAP
    for ZIF_ORDER~TT_FEHL_KAP .
  aliases TT_OPERATIONS
    for ZIF_ORDER~TT_OPERATIONS .
  aliases TT_T457T
    for ZIF_PEGGED_REQUIREMENT~TT_T457T .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR .
protected section.

  types:
    BEGIN OF ts_pegged_requirement_head,
        delkz TYPE mdps-delkz,
        delnr TYPE mdps-del12,
        delps TYPE mdps-delps,
        plwrk TYPE plaf-plwrk,
        werks TYPE werks_d,
        matnr TYPE matnr,
      END OF ts_pegged_requirement_head .

  data MF_FHM_BUFFERED type XFELD .
  data MT_FHM type ZIF_ORDER=>TT_FHM .
  data:
    mt_aob TYPE TABLE OF pre_dec .
  data MF_AUFNR type AUFNR .
  data MS_PEGGED_REQUIREMENT_HEAD type TS_PEGGED_REQUIREMENT_HEAD .
  data MF_PARALLEL_SEQUENCES type FLAG .
  data MR_COMPRESSION type ref to Z_OP_COMPRESSION_T .
  data MT_ALL_OPERATIONS type TT_OPERATIONS .
  data MT_ALTERNATIVE_SEQ_OPERATIONS type TT_OPERATIONS .
  data MT_PARALLEL_SEQ_OPERATIONS type TT_OPERATIONS .
  data MT_STANDARD_SEQ_OPERATIONS type TT_OPERATIONS .
  data MT_SUB_OPERATIONS type TT_OPERATIONS .

  methods SET_STATUS_AT_SCHEDULE .
  methods UPDATE_ORDER
    importing
      !IF_VBKZ type ABAP_BOOLEAN default ABAP_TRUE
    raising
      ZCX_CORE .
  methods DO_AFTER_RELEASE .
  methods BUILD_OPERATION_SEQUANCES .
  methods READ_AFFL .
  methods READ_PRODUCTION_AIDS
  abstract .
  methods BUILD_OPERATIONS .
  methods READ_STATUSES .
  methods READ_HEADER_AND_POSITION .
  methods READ_TCX00
    raising
      ZCX_TCX_NOTFOUND .
  methods BUILD_PEGGED_REQUIREMENT_HEAD
  abstract .
  methods READ_AOB .
  methods GET_MAT_AV_PROTOCOL
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG .
  methods GET_SCHEDULING_PROTOCOL
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG .
  methods READ_DEMAND_HEADER .
  methods RESET_MAT_AV_PROTOCOL .
  methods RESET_SCHEDULING_PROTOCOL .
private section.

  data MF_ENQUEUE type XFELD .
  data MF_PEGGED_REQUIREMENT_NAME type CHAR40 .
  data MF_PEGGED_REQUIREMENT_DATE type SY-DATUM .
  data MF_PEGGED_REQUIREMENT_BUFFERED type FLAG .
  class-data GF_AVAIL_FIX_PLANNEDORDER type ABAP_BOOL .

  methods GET_FAILED_WORKCENTERS
    importing
      !IT_FEHL_KAP type TT_FEHL_KAP
    returning
      value(RF_VALUE) type STRING .
ENDCLASS.

CLASS ZCL_ORDER IMPLEMENTATION.

  METHOD zif_amounts~get.
    rf_amount = ms_caufvd-gamng.
  ENDMETHOD.

  METHOD zif_amounts~get_gross.
    rf_amount = ms_caufvd-gamng.
  ENDMETHOD.

  METHOD zif_amounts~get_net.
*#  Gesamtmenge - Ausschuß
    rf_amount = ms_caufvd-gamng - ms_caufvd-gasmg.
  ENDMETHOD.

  METHOD zif_amounts~get_open.
    IF ms_caufvd-gwemg GT ms_caufvd-igmng.
*# Gesamtmenge Auftrag - gelieferte Menge zum Auftrag - Rückgemeldeter Ausschuß aus Rückmeldung zum Auftrag
      rf_amount = ms_caufvd-gamng - ms_caufvd-gwemg - ms_caufvd-iasmg.
    ELSE.
*# Gesamtmenge Auftrag - Rückgemeldete Gutmenge aus Rückmeldung zum Auftrag - Rückgemeldeter Ausschuß aus Rückmeldung zum Auftrag
      rf_amount = ms_caufvd-gamng - ms_caufvd-igmng - ms_caufvd-iasmg.
    ENDIF.
  ENDMETHOD.

  METHOD zif_amounts~get_unit.
    rf_unit = ms_caufvd-gmein.
  ENDMETHOD.

  METHOD zif_jstatus~get_status_text.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        flg_user_stat = 'X'
        objnr         = ms_caufvd-objnr
        spras         = sy-langu
        bypass_buffer = ' '
      IMPORTING
        line          = ef_sttxt
        user_line     = ef_ustxt
      EXCEPTIONS
        OTHERS        = 0.

  ENDMETHOD.

  METHOD zif_jstatus~has_status.
    READ TABLE mt_statuses WITH KEY stat = if_status
      TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      rf_answer = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_jstatus~remove_status.
    start_update( ).
*#remove the Order Status
    CALL FUNCTION 'STATUS_RESET_INTERN'
      EXPORTING
        iv_objnr            = ms_caufvd-objnr
        iv_status           = if_status
      EXCEPTIONS
        object_not_found    = 1
        status_inconsistent = 2
        status_not_allowed  = 3
        OTHERS              = 4.
    IF sy-subrc = 0.
      read_statuses( ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_jstatus~set_status.
    start_update( ).
*#set the Order Status
    CALL FUNCTION 'STATUS_SET_INTERN'
      EXPORTING
        iv_objnr            = ms_caufvd-objnr
        iv_status           = if_status
      EXCEPTIONS
        object_not_found    = 1
        status_inconsistent = 2
        status_not_allowed  = 3
        OTHERS              = 4.
    IF sy-subrc = 0.
      read_statuses( ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_long_text~display.
    DATA: ls_rc27i_sav TYPE rc27i,
          ls_rc27i     TYPE rc27i,
          lf_action.

*#implementation Required
    CHECK sy-batch IS INITIAL.

    CALL FUNCTION 'CO_TX_PROCESSING'
      EXPORTING
        aktyp      = 'A'
        autyp      = ms_caufvd-autyp
        object     = 'K'
        rc27i_old  = ls_rc27i_sav
        rc27i_new  = ls_rc27i
      IMPORTING
        action     = lf_action
        caufvd_exp = ms_caufvd.

  ENDMETHOD.

  METHOD zif_long_text~edit.
    DATA: ls_rc27i_sav TYPE rc27i,
          ls_rc27i     TYPE rc27i,
          lf_action.

*#implementation Required
    CHECK sy-batch IS INITIAL.

    start_update( ).

    CALL FUNCTION 'CO_TX_PROCESSING'
      EXPORTING
        aktyp      = 'V'
        autyp      = ms_caufvd-autyp
        object     = 'K'
        rc27i_old  = ls_rc27i_sav
        rc27i_new  = ls_rc27i
      IMPORTING
        action     = lf_action
        caufvd_exp = ms_caufvd.

    IF ms_caufvd-ltext IS NOT INITIAL.
      ms_caufvd-txtkz = abap_true.
    ENDIF.
    IF lf_action NE space.
      ms_caufvd-txchg = abap_true.
      update_order( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_long_text~has_long_text.
    rf_answer = ms_caufvd-ltext.
  ENDMETHOD.

  METHOD zif_order~change_batch.
    start_update( ).

    ms_afpod-charg = if_charg.

    CALL FUNCTION 'CO_BI_AFPO_UPD'
      EXPORTING
        afpowa          = ms_afpod
      IMPORTING
        afpod_exp       = ms_afpod
      EXCEPTIONS
        error_read_afpo = 1
        OTHERS          = 2.
    IF sy-subrc = 0.
      refresh( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_order~change_production_version.
    DATA: lt_return          TYPE coxt_t_bapireturn,
          ls_bapireturn      TYPE coxt_bapireturn,          "#EC NEEDED
          lf_error           TYPE c,
          ls_total_quantity  TYPE coxt_s_quantity,
          ls_total_quantityx TYPE coxt_s_quantityx,
          ls_yield           TYPE coxt_s_quantity,
          ls_yieldx          TYPE coxt_s_quantityx,
          ls_explosion_date  TYPE coxt_s_date,
          ls_explosion_datex TYPE coxt_s_datex,
          ls_bom             TYPE coxt_s_bom,
          ls_bomx            TYPE coxt_s_bomx,
          ls_routing         TYPE coxt_s_routing,
          ls_routingx        TYPE coxt_s_routingx,
          ls_basic_dates     TYPE coxt_s_date_pair,
          ls_basic_datesx    TYPE coxt_s_date_pairx.

    FIELD-SYMBOLS: <ls_return> TYPE coxt_bapireturn.

*#first things first! create the returning protocol object
    CREATE OBJECT rr_protocol.

    CHECK if_new_verid IS NOT INITIAL.

*#check the version existance for the material
    READ TABLE mr_material->mt_mkal WITH KEY verid = if_new_verid TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0 .
      rr_protocol->set( mid = 'Z_CORE'
                        num = 106"Fertigungsversion '&' ist nicht vorhanden.
                        pa1 = if_new_verid
                        typ = 'E' ).
      RETURN.
    ENDIF.

*#Confirmed/Partialy Confirmed Orders can not have their version changed
*#this check will also be made by SAP but there is no sense in locking
*#the order for this check...
    IF has_status( zif_jstatus=>co_cnf )  IS NOT INITIAL OR
       has_status( zif_jstatus=>co_pcnf ) IS NOT INITIAL.
      rr_protocol->set( mid = 'Z_CORE'
                        num = 105"Auftrag '&1' ist schon Rückgemeldet oder Teilrückgemeldet.
                        pa1 = mf_plnid
                        typ = 'E' ).
      RETURN.
    ENDIF.

*# If an order has system status APG, the production version must not be changed.
    IF has_status( zif_jstatus=>co_apg ) = abap_true.
      rr_protocol->set( mid = 'Z_CORE'
                        num = 117"Auftrag '&1' hat Systemstatus "Genehmigung erteilt"
                        pa1 = mf_plnid
                        typ = 'E' ).
      RETURN.
    ENDIF.

    start_update( ).

    ls_total_quantity-quantity  = ms_caufvd-gamng.
    ls_total_quantity-uom       = ms_caufvd-gmein.
    ls_total_quantityx-quantity = ms_caufvd-gamng.
    ls_total_quantityx-uom      = ms_caufvd-gmein.

    ls_yield-quantity           = ms_caufvd-gamng - ms_caufvd-gasmg.
    ls_yield-uom                = ms_caufvd-gmein.
    ls_yieldx-quantity          = ms_caufvd-gamng - ms_caufvd-gasmg.
    ls_yieldx-uom               = ms_caufvd-gmein.

    IF if_target_date IS INITIAL.
      ls_explosion_date-date      = ms_caufvd-gstrp.
      ls_explosion_datex-date     = ms_caufvd-gstrp.
    ELSE.
      ls_explosion_date-date      = if_target_date.
      ls_explosion_datex-date     = abap_true.
      READ TABLE gt_scheduling_type INTO DATA(ls_scheduling_type) "#EC CI_SORTSEQ
                                    WITH KEY  vorwt  = abap_true
                                              ruekt  = abap_false
                                              nterm  = abap_false
                                              tagdt  = abap_false
                                              eck_uhrzt = abap_false.
      schedule_basic_dates( if_pit = zcl_pit=>convert_date_time( if_date = if_target_date )
                            is_scheduling_type = ls_scheduling_type ).
    ENDIF.
    ls_bom-stlty                = ms_caufvd-stlty.
    ls_bom-stlnr                = ms_caufvd-stlnr.
    ls_bom-stlal                = ms_caufvd-stlal.
    ls_bomx-stlty               = ms_caufvd-stlty.
    ls_bomx-stlnr               = ms_caufvd-stlnr.
    ls_bomx-stlal               = ms_caufvd-stlal.

    ls_routing-plnty            = ms_caufvd-plnty.
    ls_routing-plnnr            = ms_caufvd-plnnr.
    ls_routing-plnal            = ms_caufvd-plnal.
    ls_routingx-plnty           = ms_caufvd-plnty.
    ls_routingx-plnnr           = ms_caufvd-plnnr.
    ls_routingx-plnal           = ms_caufvd-plnal.

    ls_basic_dates-start_date   = ms_caufvd-gstrp.
    ls_basic_dates-start_time   = ms_caufvd-gsuzp.
    ls_basic_dates-end_date     = ms_caufvd-gltrp.
    ls_basic_dates-end_time     = ms_caufvd-gluzp.

    ls_basic_datesx-start_date  = abap_true.
    ls_basic_datesx-start_time  = abap_true.
    ls_basic_datesx-end_date    = abap_true.
    ls_basic_datesx-end_time    = abap_true.

    CALL FUNCTION 'CO_XT_ORDER_CHANGE'
      EXPORTING
        i_order_key           = ms_caufvd-aufnr
        i_priority            = ms_caufvd-aprio
        i_priorityx           = 'X'
        is_mi_total_quantity  = ls_total_quantity
        is_mi_total_quantityx = ls_total_quantityx
        is_mi_yield           = ls_yield
        is_mi_yieldx          = ls_yieldx
        is_basic_dates        = ls_basic_dates
        is_basic_datesx       = ls_basic_datesx
        is_explosion_date     = ls_explosion_date
        is_explosion_datex    = ls_explosion_datex
        i_production_version  = if_new_verid
        i_production_versionx = abap_true
        is_bom                = ls_bom
        is_bomx               = ls_bomx
        is_routing            = ls_routing
        is_routingx           = ls_routingx
        i_explode_new         = abap_true
        i_explode_newx        = abap_true
      IMPORTING
        es_bapireturn         = ls_bapireturn
        e_error_occurred      = lf_error
      TABLES
        ct_return             = lt_return.
    IF lf_error IS NOT INITIAL.
      rr_protocol->set( mid = ls_bapireturn-id
                        num = ls_bapireturn-number
                        pa1 = ls_bapireturn-message_v1
                        pa2 = ls_bapireturn-message_v2
                        pa3 = ls_bapireturn-message_v3
                        pa4 = ls_bapireturn-message_v4
                        typ = ls_bapireturn-type ).
    ENDIF.

    refresh( ).
    read_affl( ).
    build_operations( ).

    LOOP AT lt_return ASSIGNING <ls_return>.
      rr_protocol->set( mid = <ls_return>-id
                        num = <ls_return>-number
                        pa1 = <ls_return>-message_v1
                        pa2 = <ls_return>-message_v2
                        pa3 = <ls_return>-message_v3
                        pa4 = <ls_return>-message_v4
                        typ = <ls_return>-type ).

    ENDLOOP.
  ENDMETHOD.

  METHOD zif_order~change_prod_version_dialog.
    DATA: lf_verid TYPE verid.

    start_update( ).

    CALL FUNCTION 'CO_SD_GET_PROD_VERS'
      EXPORTING
        imp_werks        = mr_material->ms_marc-werks
        imp_matnr        = mr_material->ms_marc-matnr
        imp_gamng        = ms_caufvd-gamng
        imp_date         = ms_caufvd-gstrs
        kz_f4_help       = 'X'
      IMPORTING
        exp_verid        = lf_verid
      EXCEPTIONS
        no_version_found = 1
        OTHERS           = 2.
    IF sy-subrc <> 0 OR lf_verid IS INITIAL.
      CREATE OBJECT rr_protocol.
      IF sy-subrc = 1.
        rr_protocol->set( mid = 'CFV'
                          num = 068"Fertigungsversionen nicht gefunden; prüfen Sie Ihre Selektionsbedingungen
                          typ = 'E' ).
        RETURN.
      ELSE.
        RAISE EXCEPTION TYPE zcx_ui
          EXPORTING
            textid = zcx_ui=>operation_canceled.
      ENDIF.
      RETURN.
    ENDIF.

    rr_protocol = change_production_version( if_new_verid =  lf_verid ).
  ENDMETHOD.

  METHOD zif_order~change_sequence_number.
    start_update( ).
    ms_caufvd-cy_seqnr = if_sequence_number.

    update_order( ).
* always update header information in COKO/COKO1, because this might be
* necessary for order changes working with screens (e.g. adding of
* components)
    IF ms_caufvd-autyp = co_autyp-process.
      CALL FUNCTION 'CO_KO_SET_HEADER' " Process order
        EXPORTING
          caufvd_imp = ms_caufvd.
    ELSE.
      CALL FUNCTION 'CO_KO1_SET_HEADER' " Production order
        EXPORTING
          caufvd_imp = ms_caufvd.
    ENDIF.
    refresh( ).
  ENDMETHOD.

  METHOD zif_order~change_temp_aufnr.
    CHECK mf_aufnr(1) = '%'.

    mf_aufnr = mf_plnid = ms_caufvd-aufnr = if_new_aufnr.
    refresh( ).
    RAISE EVENT temp_aufnr_changed EXPORTING ef_aufnr = mf_aufnr.
  ENDMETHOD.

  METHOD zif_order~change_total_quantity.

  ENDMETHOD.

  METHOD zif_order~change_total_quan_dialog.
  ENDMETHOD.

  METHOD zif_order~check_material_availability.
    DATA: lf_return_code TYPE sy-subrc,
          lf_plnid       TYPE symsgv.

    start_update( ).

    reset_mat_av_protocol( ).

    CALL FUNCTION 'CO_ZA_AVAILABILITY_CHK_ORDER'
      EXPORTING
        caufvd_imp       = ms_caufvd
        flg_mess_obj_dep = 'X'
        i_memo_tp        = ' '
      IMPORTING
        retcode_exp      = lf_return_code.

    IF ir_missing_parts IS BOUND.
      FIELD-SYMBOLS: <lt_mdvax>         TYPE ANY TABLE,
                     <lt_missing_parts> TYPE zif_order=>tt_missing_parts.
*#we assume that the ir_missing_parts ref is a Table of type TT_MISSING_PARTS
      ASSIGN ('(SAPLCOZA)MDVAX[]') TO <lt_mdvax>.
      IF sy-subrc = 0 AND <lt_mdvax> IS ASSIGNED AND ir_missing_parts IS BOUND.
        ASSIGN ir_missing_parts->* TO <lt_missing_parts>.
        <lt_missing_parts> = <lt_mdvax>.     "#EC CI_FLDEXT_OK[2215424]
        DELETE <lt_missing_parts> WHERE xfehl = abap_false.
        DELETE <lt_missing_parts> WHERE aufnr <> ms_caufvd-aufnr.
      ENDIF.
    ENDIF.

    rr_protocol = get_mat_av_protocol( ).

    refresh( ).

    IF lf_return_code = 0.
      set_status( zif_jstatus=>co_macm )."Material bestätigt
    ENDIF.
*                 sollte nicht geprüft werden (Customizingeinstellung)
*
*                 1 auch wenn einer der untergeordneten Aufträge
*                 Fehlmaterial hat
*
*                 da Customizingeinstellungen für die Auftragsart
*                 fehlen oder falsch sind
*
*                 da Auftragskomponenten nicht zu prüfen waren
  ENDMETHOD.

  METHOD zif_order~dialog.
    DATA: ls_ordpar TYPE ordpar,
          lr_exc    TYPE REF TO zcx_order_locked.

    CHECK sy-batch IS INITIAL.

    TRY .
        start_update( ).
        ls_ordpar-trtyp = 'V'."change order
      CATCH zcx_order_locked INTO lr_exc.
        MESSAGE lr_exc TYPE 'S'.
        ls_ordpar-trtyp = 'A'."display order
    ENDTRY.

    ls_ordpar-aufnr = mf_aufnr.
    ls_ordpar-fcode = 'ENT1'.

    CALL FUNCTION 'CO_EXT_ORDER_ENTRY'
      EXPORTING
        ordpar_imp       = ls_ordpar
      EXCEPTIONS
        enqueue_failed   = 01
        not_found        = 02
        dialog_chanceled = 03.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*#refresh the order
    refresh( ).

*#in order to update the order
    schedule( ).
  ENDMETHOD.

  METHOD zif_order~get_basic_end.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_caufvd-gltrp
                                             if_time = ms_caufvd-gluzp ).
  ENDMETHOD.

  METHOD zif_order~get_basic_start.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_caufvd-gstrp
                                             if_time = ms_caufvd-gsuzp ).
  ENDMETHOD.

  METHOD zif_order~get_compression_table.
*#this method will build a table with all the opeatation that can be compressed
*#COMPRESSION = Successive operations that have the same area
*#the compression will not take into cosideration Phases!!!
    DATA: ls_compression TYPE z_op_compression_s.

    IF mr_compression IS NOT BOUND.
      CREATE DATA mr_compression.
    ELSE.
      CLEAR mr_compression->*.
    ENDIF.

    LOOP AT mt_operation_sequances INTO DATA(lr_sequence).
      TRY .
          DATA(lr_operation) = lr_sequence->get_first_operation( ).
          ls_compression-arbid           = lr_operation->mr_workcenter.
          ls_compression-first_operation =
          ls_compression-last_operation  = lr_operation.
          DO.
            TRY .
                DATA(lr_successor) = lr_operation->get_successor( ).
                "never thake phases into consideration at compression
                IF lr_successor->ms_afvgd-phflg = abap_true.
                  lr_operation = lr_successor.
                  CONTINUE.
                ENDIF.

                IF lr_successor->mr_workcenter = lr_operation->mr_workcenter.
                  ls_compression-last_operation = lr_successor.
                ELSE.
                  "Only add a compression line if the first and last operations are not the same
                  IF ls_compression-first_operation <> ls_compression-last_operation.
                    APPEND ls_compression TO mr_compression->*.
                  ENDIF.
                  "build a new compression line
                  ls_compression-arbid           = lr_successor->mr_workcenter.
                  ls_compression-first_operation =
                  ls_compression-last_operation  = lr_successor.
                ENDIF.
                lr_operation = lr_successor.
              CATCH zcx_no_successor.
                "if the operation has no successor then just append the last ls_compression but only if
                "the first and last operations are not the same
                IF ls_compression-first_operation <> ls_compression-last_operation.
                  APPEND ls_compression TO mr_compression->*.
                ENDIF.
                EXIT.
            ENDTRY.
          ENDDO.
        CATCH zcx_operation_notfound.
          "the order does not have any opeations so no compression
      ENDTRY.
    ENDLOOP.
    rr_compression = mr_compression.

  ENDMETHOD.

  METHOD zif_order~get_delivery_operation.

*# First try to find the operation which has a STEUS which does goods movement
    LOOP AT mt_operations ASSIGNING FIELD-SYMBOL(<lr_operation>).
      IF <lr_operation>->is_delivery_operation( ) = abap_true.
        rr_operation = <lr_operation>.
        RETURN.
      ENDIF.
    ENDLOOP.

*# If no operation found, the delivery operation is the last operation of this order
    rr_operation = get_last_operation( ).

  ENDMETHOD.

  METHOD zif_order~get_enqueue_status.
    ef_enqueue = mf_enqueue.

  ENDMETHOD.

  METHOD zif_order~get_first_operation.
    DATA: ls_aob TYPE pre_dec.

*#the first operation should not have a predecessor in AOB
    LOOP AT mt_aob INTO ls_aob WHERE aufnr_v IS INITIAL
                                 AND flgnr_v IS INITIAL
                                 AND vornr_v IS INITIAL.
      EXIT.
    ENDLOOP.

    CASE sy-subrc.
      WHEN 0.
        READ TABLE mt_all_operations INTO rr_operation WITH KEY table_line->ms_afvgd-vornr = ls_aob-vornr_b
                                                                table_line->ms_afvgd-aplfl = ls_aob-flgnr_b.
      WHEN OTHERS.
*#if no match found over AOB then just try to find the first sequnace operation
        LOOP AT mt_all_operations INTO rr_operation WHERE table_line->ms_afvgd-aplfl = if_sequence.
          EXIT.
        ENDLOOP.
    ENDCASE.

    IF rr_operation IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_operation_notfound
        EXPORTING
          plnid = mf_plnid.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~get_granted_authority.
    DATA: lf_tcode   TYPE sytcode,
          lf_tcode_a TYPE sytcode.

    CASE mf_sart.
      WHEN zif_core_constants=>co_sart-plano.
        lf_tcode   = 'MD12'.
        lf_tcode_a = 'MD13'.
      WHEN zif_core_constants=>co_sart-prodo.
        lf_tcode   = 'CO02'.
        lf_tcode_a = 'CO03'.
      WHEN zif_core_constants=>co_sart-process.
        lf_tcode   = 'COR2'.
        lf_tcode_a = 'COR3'.
      WHEN zif_core_constants=>co_sart-iho.
        lf_tcode   = 'IW32'.
        lf_tcode_a = 'IW33'.
      WHEN zif_core_constants=>co_sart-network.
        lf_tcode   = 'CN22'.
        lf_tcode_a = 'CN23'.
    ENDCASE.

    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode  = lf_tcode
      EXCEPTIONS
        ok     = 1
        not_ok = 2
        OTHERS = 3.
    IF sy-subrc <> 1.
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
        EXPORTING
          tcode  = lf_tcode_a
        EXCEPTIONS
          ok     = 1
          not_ok = 2
          OTHERS = 3.
      IF sy-subrc <> 1.
        rf_authority = co_authority-none.
      ELSE.
        rf_authority = co_authority-display.
      ENDIF.
    ELSE.
      rf_authority = co_authority-edit.
    ENDIF.

  ENDMETHOD.

  METHOD zif_order~get_last_operation.
    DATA: ls_aob TYPE pre_dec.

*#the first operation should not have a successor in AOB
    LOOP AT mt_aob INTO ls_aob WHERE aufnr_b IS INITIAL
                                 AND flgnr_b IS INITIAL
                                 AND vornr_b IS INITIAL.
      EXIT.
    ENDLOOP.

    CASE sy-subrc.
      WHEN 0.
        READ TABLE mt_all_operations INTO rr_operation WITH KEY table_line->ms_afvgd-vornr = ls_aob-vornr_v
                                                                table_line->ms_afvgd-aplfl = ls_aob-flgnr_v.
      WHEN OTHERS.
*#if no match found over AOB then just try to find the las operation of the sequance
        LOOP AT mt_all_operations INTO rr_operation WHERE table_line->ms_afvgd-aplfl = if_sequence.
        ENDLOOP.
    ENDCASE.

    IF rr_operation IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_operation_notfound
        EXPORTING
          plnid = mf_plnid.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~get_lead_plnid.
    rf_plnid = ms_caufvd-lead_aufnr.
  ENDMETHOD.

  METHOD zif_order~get_operation.

    IF if_aplzl IS NOT SUPPLIED.
      READ TABLE mt_all_operations INTO rr_operation WITH KEY table_line->mf_vornr = if_vornr
                                                              table_line->ms_afvgd-aplfl = if_sequence.

      CHECK sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_operation_notfound
        EXPORTING
          plnid = mf_plnid
          vornr = if_vornr.
    ELSE.
      READ TABLE mt_all_operations INTO rr_operation WITH KEY table_line->ms_afvgd-aplzl = if_aplzl.
      IF sy-subrc <> 0.
        READ TABLE mt_sub_operations INTO rr_operation
          WITH KEY table_line->ms_afvgd-aplzl = if_aplzl.
      ENDIF.
      CHECK sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_operation_notfound
        EXPORTING
          plnid = mf_plnid
          vornr = if_vornr.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~get_operations.
    CLEAR et_operations.
    LOOP AT mt_all_operations INTO DATA(lr_operation) WHERE table_line->ms_afvgd-aplfl = if_sequence.
      APPEND lr_operation TO et_operations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_order~get_order_amount.
    IF ms_caufvd-gmein <> ms_caufvd-sbmeh.
      ef_gamng = ms_caufvd-gamng * ms_afpod-umrez / ms_afpod-umren.
    ELSE.
      ef_gamng = ms_caufvd-gamng.
    ENDIF.

  ENDMETHOD.

  METHOD zif_order~get_predecessor_operation.
    DATA: ls_aob TYPE pre_dec.

*#fisrt try to fing the predecessor over the AOB table
    READ TABLE mt_aob INTO ls_aob WITH KEY aufnr_b = ir_operation->mr_order->ms_caufvd-aufnr
                                           flgnr_b = ir_operation->ms_afvgd-aplfl
                                           vornr_b = ir_operation->ms_afvgd-vornr.
    CASE sy-subrc.
      WHEN 0.
        READ TABLE mt_all_operations INTO rr_predecessor WITH KEY table_line->ms_afvgd-vornr = ls_aob-vornr_v
                                                                  table_line->ms_afvgd-aplfl = ls_aob-flgnr_v.
      WHEN OTHERS.
*#if no match found over AOB then just try to find the normal predecessor
        CLEAR rr_predecessor.
        LOOP AT mt_all_operations INTO DATA(lr_predecessor) WHERE table_line->mf_vornr LT ir_operation->mf_vornr
                                                          AND table_line->ms_afvgd-aplfl = ir_operation->ms_afvgd-aplfl.
          IF lr_predecessor->has_status( zif_jstatus=>co_dlt ) = abap_false.
            rr_predecessor = lr_predecessor.
          ENDIF.
        ENDLOOP.
    ENDCASE.

    IF rr_predecessor IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_no_predecessor
        EXPORTING
          plnid = mf_plnid
          vornr = ir_operation->mf_vornr.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~get_production_aids.
    IF mf_fhm_buffered = abap_false.
      read_production_aids( ).
    ENDIF.
    et_fhm = mt_fhm.

  ENDMETHOD.

  METHOD zif_order~get_production_versions.
    DATA: ls_mkal  TYPE mkal.

    DATA(lf_gamng) = get_order_amount( ).
    et_mkal = mr_material->mt_mkal.

    DATA(lf_date) = if_date.
    IF lf_date IS INITIAL.
      lf_date = sy-datum.
    ENDIF.
    DELETE et_mkal
      WHERE adatu > lf_date.
*#-entries that are no longer valid
    DELETE et_mkal
      WHERE bdatu < if_date.
*#-entries that have the lock of the production version set
    DELETE et_mkal WHERE mksp NE space.

*#only versions do not have min and max amount and verisons that
*#include the order amount
    LOOP AT et_mkal INTO ls_mkal.
      IF ls_mkal-bstmi IS INITIAL AND ls_mkal-bstma IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lf_gamng NOT BETWEEN ls_mkal-bstmi AND ls_mkal-bstma.
        DELETE et_mkal.
        CONTINUE.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_order~get_routing_master.
    IF zif_order~mr_routing_master IS INITIAL.
      zif_order~mr_routing_master =
        zcl_routing_master=>get_instance( if_plnty = ms_caufvd-plnty
                                                  if_plnnr = ms_caufvd-plnnr
                                                  if_plnal = ms_caufvd-plnal ).
    ENDIF.

    rr_routing_master = zif_order~mr_routing_master.

  ENDMETHOD.

  METHOD zif_order~get_successor_operation.
    DATA: ls_aob TYPE pre_dec.

*#fisrt try to fing the successor over the AOB table
    READ TABLE mt_aob INTO ls_aob WITH KEY aufnr_v = ir_operation->mr_order->ms_caufvd-aufnr
                                           flgnr_v = ir_operation->ms_afvgd-aplfl
                                           vornr_v = ir_operation->ms_afvgd-vornr.
    CASE sy-subrc.
      WHEN 0.
        READ TABLE mt_all_operations INTO rr_successor WITH KEY table_line->ms_afvgd-vornr = ls_aob-vornr_b
                                                                table_line->ms_afvgd-aplfl = ls_aob-flgnr_b.
      WHEN OTHERS.
*#if no match found over AOB then just try to find the normal successor
        CLEAR: rr_successor.
        LOOP AT mt_all_operations INTO DATA(lr_successor) WHERE table_line->mf_vornr GT ir_operation->mf_vornr
                                                            AND table_line->ms_afvgd-aplfl = ir_operation->ms_afvgd-aplfl.
          IF lr_successor->has_status( zif_jstatus=>co_dlt ) = abap_false.
            rr_successor = lr_successor.
            EXIT.
          ENDIF.
        ENDLOOP.
    ENDCASE.

    IF rr_successor IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_no_successor
        EXPORTING
          plnid = mf_plnid
          vornr = ir_operation->mf_vornr.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~get_update_key.
    CALL FUNCTION 'CO_BT_CAUFV_READ_WITH_KEY' "#EC CI_SUBRC
      EXPORTING
        aufnr_act = mf_aufnr
      IMPORTING
        vbkz_exp  = rf_vbkz
      EXCEPTIONS
        OTHERS    = 0.

  ENDMETHOD.

  METHOD zif_order~refresh.
    DATA: lr_operation TYPE REF TO zif_operation.

    read_header_and_position( ).
    read_demand_header( ).
    read_statuses( ).
    TRY.
        read_tcx00( ).
      CATCH zcx_tcx_notfound.
    ENDTRY.
    read_aob( ).

    LOOP AT mt_all_operations INTO lr_operation.
      lr_operation->refresh( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_order~release.
    DATA: lt_msgprot TYPE TABLE OF cmfmsg,
          lf_num     TYPE sy-msgno.

    start_update( ).

    CREATE OBJECT rr_protocol.

*#only free if the status is not present
    CHECK has_status( zif_jstatus=>co_free ) IS INITIAL.

*#this function also sets the status free for all operations
    CALL FUNCTION 'CO_COM_RELEASE_ORDER'
      EXPORTING
        caufvd_imp = ms_caufvd
      IMPORTING
        caufvd_exp = ms_caufvd
      CHANGING
        afpod_c    = ms_afpod.

*#get the protocol
    CALL FUNCTION 'CM_F_MESSAGES_GET'
      EXPORTING
        aplid      = 'PPFR'
      TABLES
        e_msgprot  = lt_msgprot
      EXCEPTIONS
        not_active = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES'
      EXPORTING
        aplid      = 'PPFR'
        number     = '999'
      EXCEPTIONS
        not_active = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_msgprot ASSIGNING FIELD-SYMBOL(<ls_msgprot>).
      lf_num = <ls_msgprot>-msgnr.
      rr_protocol->set( mid = <ls_msgprot>-arbgb
                        num = lf_num
                        pa1 = <ls_msgprot>-msgv1
                        pa2 = <ls_msgprot>-msgv2
                        pa3 = <ls_msgprot>-msgv3
                        pa4 = <ls_msgprot>-msgv4
                        typ = <ls_msgprot>-msgty ).
    ENDLOOP.

    do_after_release( ).
**#refresh the order information
  ENDMETHOD.

  METHOD zif_order~schedule.

    start_update( ).

    reset_scheduling_protocol( ).

    set_status_at_schedule( ).

    CALL FUNCTION 'CX_ORDER_SCHEDULE' "#EC CI_SUBRC
      EXPORTING
        caufvd_imp            = ms_caufvd
        tcx00_imp             = ms_tcx00
        i_flg_protocol        = 'X'
        i_flg_overall_network = 'X'
        i_autyp_to_schedule   = ms_caufvd-autyp
      EXCEPTIONS

        cycle_found           = 01
        no_operations         = 02
        no_sched_parameters   = 03
        program_error         = 04
        no_start_date         = 05
        no_end_date           = 06
        tca01_entry_not_valid = 07.
    IF sy-subrc <> 0.
    ENDIF.

    rr_protocol = get_scheduling_protocol( ).

*#refresh the order
    refresh( ).
  ENDMETHOD.

  METHOD zif_order~schedule_basic_dates.

    start_update( ).
    reset_scheduling_protocol( ).
*  "we remove the status "EIGP" to be sure that no operation is fixed
    LOOP AT mt_all_operations INTO DATA(lr_operation).
      lr_operation->remove_status( zif_jstatus=>co_dspt ).
    ENDLOOP.
    DATA(lf_pit) = if_pit.
    IF lf_pit IS INITIAL.
      lf_pit = zcl_pit=>get_sy_pit( ).
    ENDIF.
    zcl_pit=>convert_pit( EXPORTING if_pit  = if_pit
                              IMPORTING ef_date = DATA(lf_date)
                                        ef_time = DATA(lf_time) ).
    DATA(ls_caufvd)  = ms_caufvd.

*#set the scheduling type
    ls_caufvd-terkz = is_scheduling_type-termkz.
    IF ls_caufvd-terkz IS INITIAL.
      ls_caufvd-terkz = 2.""Rückwärts
    ENDIF.
*#Network frame dates will be recalculated
    CLEAR: ls_caufvd-pnetstartd,
           ls_caufvd-pnetstartt,
           ls_caufvd-pnetendd,
           ls_caufvd-pnetendt.
    CASE abap_true.
      WHEN is_scheduling_type-ruekt.
        IF ls_caufvd-upter = abap_true.
          ls_caufvd-gltrs = lf_date."Scheduled End
          ls_caufvd-gluzs = lf_time."Scheduled End (Uhrzeit)
        ELSE.
          ls_caufvd-gltrp = lf_date."Eckendtermin
          ls_caufvd-gluzp = lf_time."Eckendtermin (Uhrzeit)
        ENDIF.
      WHEN is_scheduling_type-vorwt.
        IF ls_caufvd-upter = abap_true.
          ls_caufvd-gstrs = lf_date."Scheduled Start
          ls_caufvd-gsuzs = lf_time."Scheduled Start (Uhrzeit)
        ELSE.
          ls_caufvd-gstrp = lf_date."Eckstarttermin
          ls_caufvd-gsuzp = lf_time."Eckstarttermin (Uhrzeit)
        ENDIF.
    ENDCASE.

    "Ecktermine ohne Uhrzeiten.
    IF is_scheduling_type-eck_uhrzt IS INITIAL.
      CLEAR ls_caufvd-gluzp."Eckendtermin (Uhrzeit)
      CLEAR ls_caufvd-gsuzp."Eckstarttermin (Uhrzeit)
    ENDIF.

    set_status_at_schedule( ).

    CALL FUNCTION 'CX_ORDER_SCHEDULE' "#EC CI_SUBRC
      EXPORTING
        caufvd_imp            = ls_caufvd
        tcx00_imp             = ms_tcx00
        i_flg_protocol        = 'X'
        i_flg_overall_network = 'X'
        i_autyp_to_schedule   = ls_caufvd-autyp
      IMPORTING
        caufvd_exp            = ls_caufvd
      EXCEPTIONS
        OTHERS                = 0.

    rr_protocol = get_scheduling_protocol( ).
*#refresh the order
    refresh( ).
  ENDMETHOD.

  METHOD zif_order~schedule_basic_dates_dialog.
    start_update( ).

    DATA(lf_pit) = if_pit.
    DATA(ls_scheduling_type) = is_scheduling_type.

    CALL FUNCTION 'Z_BASIC_DATES'
      CHANGING
        cf_pit             = lf_pit
        cf_scheduling_type = ls_scheduling_type-termkz.

    READ TABLE gt_scheduling_type INTO ls_scheduling_type WITH TABLE KEY termkz = ls_scheduling_type-termkz.

    rr_protocol = schedule_basic_dates( if_pit = lf_pit is_scheduling_type = ls_scheduling_type ).

  ENDMETHOD.

  METHOD zif_order~start_update.
    DATA: lt_ord   TYPE TABLE OF ord_pre,
          lf_enque TYPE flag.
    FIELD-SYMBOLS: <ls_ord> TYPE ord_pre.

    IF zcl_order_buffer=>is_present_in_stack( me ) IS INITIAL.
*#The internal index tables must be rebuild at the Enque of the Order in order to not have
*#any conflicts when POSTing the changes to the Orders.
*#this ITAB_FLAG is only relevant if before this action PLANED ORDERS where buffered
      CALL FUNCTION 'CO_IT_SET_FLG_ITAB_NEW'.

      APPEND INITIAL LINE TO lt_ord ASSIGNING <ls_ord>.
      <ls_ord>-aufnr = mf_aufnr.

      CLEAR: mf_enqueue.
      CALL FUNCTION 'CO_ZF_ORDER_READ'
        EXPORTING
          flg_dialog        = ' '
          flg_enqueue       = 'X'
        IMPORTING
          flg_enqueue_ok    = lf_enque
        TABLES
          aufnr_tab_imp     = lt_ord
        EXCEPTIONS
          order_not_found   = 1
          release_no_change = 2
          OTHERS            = 3.
      IF sy-subrc = 0 AND lf_enque IS NOT INITIAL.
        CALL FUNCTION 'CO_BH_ORDER_FLG_ENQUEUE_SET'
          TABLES
            ord_tab = lt_ord.
      ELSE.
        RAISE EXCEPTION TYPE zcx_order_locked
          EXPORTING
            aufnr = mf_aufnr.
      ENDIF.
      mf_enqueue = lf_enque.

      zcl_order_buffer=>add_to_stack( me ).
      refresh( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_pegged_requirement~display.
*#build the pegged reuirement JIT
    IF ms_pegged_requirement_head IS INITIAL.
      build_pegged_requirement_head( ).
    ENDIF.
    CALL FUNCTION 'MD_PEGGING'
      EXPORTING
        edelkz                = ms_pegged_requirement_head-delkz
        edelnr                = ms_pegged_requirement_head-delnr
        edelps                = ms_pegged_requirement_head-delps
        ematnr                = ms_pegged_requirement_head-matnr
        ewerks                = ms_pegged_requirement_head-werks
        eplwrk                = ms_pegged_requirement_head-plwrk
      EXCEPTIONS
        error                 = 1
        no_requirements_found = 2
        order_not_found       = 3
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD zif_pegged_requirement~get.
    DATA: lt_mdrqx TYPE TABLE OF mdrq,
          ls_mdrqx TYPE mdrq,
          ls_t457t TYPE t457t.

    DATA: BEGIN OF ls_bedvu,
            delb1(10),
            extra(30),
          END OF ls_bedvu.
*#if the pegged requirement was aleray read there is no sense in reading it again
    IF mf_pegged_requirement_buffered IS NOT INITIAL.
      ef_date = mf_pegged_requirement_date.
      ef_name = mf_pegged_requirement_name.
      RETURN.
    ENDIF.
*#build the pegged reuirement JIT
    IF ms_pegged_requirement_head IS INITIAL.
      build_pegged_requirement_head( ).
    ENDIF.

    CALL FUNCTION 'MD_PEGGING_NODIALOG'
      EXPORTING
        edelkz                = ms_pegged_requirement_head-delkz
        edelnr                = ms_pegged_requirement_head-delnr
        edelps                = ms_pegged_requirement_head-delps
        ematnr                = ms_pegged_requirement_head-matnr
        ewerks                = ms_pegged_requirement_head-werks
        eplwrk                = ms_pegged_requirement_head-plwrk
      TABLES
        imdrqx                = lt_mdrqx
      EXCEPTIONS
        error                 = 1
        no_requirements_found = 2
        order_not_found       = 3
        OTHERS                = 4.
    IF sy-subrc <> 0.
*# remeber the results so they must not be read again
      mf_pegged_requirement_buffered = abap_true.
      EXIT.
    ENDIF.

    DELETE lt_mdrqx WHERE delnr <> ms_caufvd-aufnr.

*#give the first pegged reqirement back
    SORT lt_mdrqx BY dat00.

    READ TABLE lt_mdrqx INTO ls_mdrqx INDEX 1.
    IF sy-subrc = 0.
      ls_bedvu-extra = ls_mdrqx-extra.
      mf_pegged_requirement_date = ls_mdrqx-dat00.
      IF ls_mdrqx-delkz = '1S'.
        ls_mdrqx-delkz = 'SH'.
        mf_pegged_requirement_date = sy-datum.
      ENDIF.
      READ TABLE gt_t457t INTO ls_t457t WITH KEY delkz = ls_mdrqx-delkz.
      IF sy-subrc = 0.
        ls_bedvu-delb1 = ls_t457t-delb1.
      ENDIF.
      mf_pegged_requirement_name = ls_bedvu.

*#if there are more then one pegged requirements then add the '++' sign
      IF lines( lt_mdrqx ) > 1.
        CONCATENATE '++'
                    mf_pegged_requirement_name
               INTO mf_pegged_requirement_name
       SEPARATED BY space.
      ENDIF.
    ENDIF.
*# remeber the results so they must not be read again
    mf_pegged_requirement_buffered = abap_true.

    ef_name = mf_pegged_requirement_name.
    ef_date = mf_pegged_requirement_date.
  ENDMETHOD.

  METHOD build_operations.
*#This method is used to create the MT_OPERATIONS Tabele
*#when calling the method the MT_OPERATIONS is first cleard
*#and the operations are read from the SAP buffer tables if
*#present(only the active ones, not deleted) and if this is
*#unssucesfull then they method tries to read them from the
*#database.
*#The method is designed to work also in update task and if
*#the operations are not found in the normal buffer tables
*#with the help of a dirty assign the operations are read
*#from the update task buffer tables.

*#with the help of an Enhancement one can activate parallel sequences
*#simply by setting the MF_PARALLEL_SEQUENCES flag to 'X'

    DATA: lr_operation TYPE REF TO zif_operation,
          lt_afvgb     TYPE SORTED TABLE OF afvgb WITH NON-UNIQUE KEY aufpl aplzl,
          lt_afvgd     TYPE TABLE OF afvgd,
          ls_afvgd     TYPE afvgd,
          ls_afvgb     TYPE afvgb.
    FIELD-SYMBOLS: <ls_afvgd>     TYPE afvgd,
                   <ls_afvgb>     TYPE afvgb,
                   <lt_table>     TYPE ANY TABLE,
                   <ls_structure> TYPE any.

*#read operations
*#CO_BO_AFVGB_GET is very unperformant and will also give the deleted operations back!!!
*#never use this function here.

*#Try to read the active operations from the Buffer tables. With this
*#function only the active(not with VBKZ='D'elete) will be read.

*#in order to use the CO_BT_AFVG_GET one must first set the correct
*#index with the help of the CO_BT_AFVG_SET function
    CALL FUNCTION 'CO_BT_AFVG_SET' "#EC CI_SUBRC
      EXPORTING
        aufnr_act       = ms_caufvd-aufnr
        aufpl_act       = ms_caufvd-aufpl
      EXCEPTIONS
        entry_not_found = 1
        table_empty     = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
    ENDIF.

    WHILE sy-subrc = 0.
      CALL FUNCTION 'CO_BT_AFVG_GET' "#EC CI_SUBRC
        EXPORTING
          aufnr_act   = ms_caufvd-aufnr
          aufpl_act   = ms_caufvd-aufpl
          flg_work    = 'X'
          flg_deleted = space
        IMPORTING
          afvgd_exp   = ls_afvgd
        EXCEPTIONS
          eof         = 1.
      IF sy-subrc = 0.
        IF ls_afvgd-bedid IS INITIAL.
          TRY.
              DATA(lr_plannedorder) = CAST zcl_order_plano( me ).
              ls_afvgd-bedid = lr_plannedorder->get_bedid_from_plaf( lr_plannedorder->ms_plaf ).
            CATCH cx_sy_move_cast_error.
          ENDTRY.
        ENDIF.
        APPEND ls_afvgd TO lt_afvgd.
        CLEAR ls_afvgd.
      ENDIF.
    ENDWHILE.

*#special handlif if in update task
*#read the operations from the db
    IF lt_afvgd IS INITIAL .
      SELECT COUNT(*) FROM afvc
       WHERE aufpl = ms_caufvd-aufpl.
      IF sy-subrc = 0.
        CALL FUNCTION 'CO_DB_AFVGD_ARRAY_READ' "#EC CI_SUBRC
          EXPORTING
            afvg_nummer = ms_caufvd-aufpl
          TABLES
            afvdb_tab   = lt_afvgd
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.
        IF sy-subrc <> 0.
        ENDIF.
      ENDIF.

*#read the operations from the SAP buffer tables
      ASSIGN ('(SAPLCOBT)AFVG_BT[]') TO <lt_table>.
      IF sy-subrc = 0 AND <lt_table> IS ASSIGNED.
*#build AFVGB
        LOOP AT <lt_table> ASSIGNING <ls_structure>.
          MOVE-CORRESPONDING <ls_structure> TO ls_afvgb. "#EC CI_FLDEXT_OK[2215424]
          CHECK ls_afvgb-aufpl = ms_caufvd-aufpl.

          INSERT ls_afvgb INTO TABLE lt_afvgb.
        ENDLOOP.
*#update from the buffer table
        LOOP AT lt_afvgd ASSIGNING <ls_afvgd>.

          READ TABLE lt_afvgb ASSIGNING <ls_afvgb> WITH TABLE KEY aufpl = <ls_afvgd>-aufpl
                                                                  aplzl = <ls_afvgd>-aplzl.
          CHECK sy-subrc = 0.
*#if the operation is found in the buffer then update the AFVGD
          IF <ls_afvgb>-vbkz <> 'D'."delete.
            MOVE-CORRESPONDING <ls_afvgb> TO <ls_afvgd>.
          ELSE.
*#if the operation is with VBKZ in buffer then remove it also from the AFVGD
            DELETE lt_afvgd.
          ENDIF.

          DELETE lt_afvgb USING KEY primary_key
                          WHERE aufpl = <ls_afvgb>-aufpl
                            AND aplzl = <ls_afvgb>-aplzl.
        ENDLOOP.
*#maybe there are newly created operations...
        IF lt_afvgb IS NOT INITIAL.
          LOOP AT lt_afvgb ASSIGNING <ls_afvgb>.
            APPEND INITIAL LINE TO lt_afvgd ASSIGNING <ls_afvgd>.
            MOVE-CORRESPONDING <ls_afvgb> TO <ls_afvgd>.
          ENDLOOP.
        ENDIF.
      ENDIF."IF <lt_table> IS ASSIGNED.
    ENDIF."IF lt_afvgd IS INITIAL AND sy-batch IS NOT INITIAL.

    SORT lt_afvgd BY vornr.

    DATA: lt_alternative_seq_afvgd TYPE TABLE OF afvgd,
          lt_parallel_seq_afvgd    TYPE TABLE OF afvgd,
          lt_standard_seq_afvgd    TYPE TABLE OF afvgd.
    DATA: lt_sub_afvgd TYPE TABLE OF afvgd.

*#create the operations
    "Here we collect all operations, for the case that a lock was set for a
    "operation that is not relevant for dcp! In this case we need them all ;)
    "to get rid of all locks...
    CLEAR: mt_afvgd.
    MOVE-CORRESPONDING lt_afvgd TO mt_afvgd.

*# Make a special indexed table for suboperations
    MOVE-CORRESPONDING lt_afvgd TO mt_afvgd_sub.
    DELETE mt_afvgd_sub USING KEY primary_key WHERE sumnr = '00000000'.
    lt_sub_afvgd = lt_afvgd.
    DELETE lt_sub_afvgd
      WHERE sumnr IS INITIAL.

*#if SUMNR is not initial we are talking about a SUBOPERATION...
    DELETE lt_afvgd WHERE sumnr <> '00000000'.

    build_operation_sequances( ).

    "separate the sequances
    SORT mt_affl BY aufpl plnfl.
    LOOP AT lt_afvgd ASSIGNING <ls_afvgd>.
      READ TABLE mt_affl ASSIGNING FIELD-SYMBOL(<ls_affl>) WITH KEY aufpl = <ls_afvgd>-aufpl "#EC CI_STDSEQ
                                                                    plnfl = <ls_afvgd>-aplfl
                                                                    BINARY SEARCH.
      IF sy-subrc <> 0.
        APPEND <ls_afvgd> TO lt_standard_seq_afvgd.
      ELSE.
        CASE <ls_affl>-flgat.
          WHEN zif_operation_sequance=>co_type-parallel.
            APPEND <ls_afvgd> TO lt_parallel_seq_afvgd.
          WHEN zif_operation_sequance=>co_type-alternative.
            APPEND <ls_afvgd> TO lt_alternative_seq_afvgd.
            DELETE lt_afvgd."alternative sequnaces should not be used in DCP
            CONTINUE.
          WHEN zif_operation_sequance=>co_type-standard.
            APPEND <ls_afvgd> TO lt_standard_seq_afvgd.
          WHEN OTHERS.
            APPEND <ls_afvgd> TO lt_standard_seq_afvgd.
        ENDCASE.
      ENDIF.
    ENDLOOP.

    IF mf_parallel_sequences = space."standard DCP customizing to allow parallel sequances
      DELETE lt_afvgd WHERE aplfl <> zif_operation_sequance=>co_standard_sequance.
    ENDIF.

    CLEAR: mt_operations,
           mt_alternative_seq_operations,
           mt_parallel_seq_operations,
           mt_standard_seq_operations,
           mt_all_operations.

    LOOP AT lt_standard_seq_afvgd ASSIGNING <ls_afvgd>.
      lr_operation = zcl_operation=>factory( ir_order = me
                                                     is_afvgd = <ls_afvgd> ).
      APPEND lr_operation TO mt_standard_seq_operations.
    ENDLOOP.

    LOOP AT lt_alternative_seq_afvgd ASSIGNING <ls_afvgd>.
      lr_operation = zcl_operation=>factory( ir_order = me
                                                     is_afvgd = <ls_afvgd> ).
      APPEND lr_operation TO mt_alternative_seq_operations.
    ENDLOOP.
    LOOP AT lt_parallel_seq_afvgd ASSIGNING <ls_afvgd>.
      lr_operation = zcl_operation=>factory( ir_order = me
                                                     is_afvgd = <ls_afvgd> ).
      APPEND lr_operation TO mt_parallel_seq_operations.
    ENDLOOP.
    LOOP AT lt_sub_afvgd ASSIGNING <ls_afvgd>.
      lr_operation = zcl_operation=>factory( ir_order = me
                                                     is_afvgd = <ls_afvgd> ).
      APPEND lr_operation TO mt_sub_operations.
    ENDLOOP.
*#build the public operations list(alternative sequances are never included)
    LOOP AT lt_afvgd ASSIGNING <ls_afvgd>.
      READ TABLE mt_standard_seq_operations INTO lr_operation WITH KEY table_line->ms_afvgd-aplzl = <ls_afvgd>-aplzl.
      IF sy-subrc = 0.
        APPEND lr_operation TO mt_operations.
        CONTINUE.
      ENDIF.
      READ TABLE mt_parallel_seq_operations INTO lr_operation WITH KEY table_line->ms_afvgd-aplzl = <ls_afvgd>-aplzl.
      IF sy-subrc = 0.
        APPEND lr_operation TO mt_operations.
        CONTINUE.
      ENDIF.
    ENDLOOP.
    SORT mt_operations BY table_line->ms_afvgd-vornr table_line->ms_afvgd-aplfl.

    APPEND LINES OF mt_alternative_seq_operations TO mt_all_operations.
    APPEND LINES OF mt_parallel_seq_operations TO mt_all_operations.
    APPEND LINES OF mt_standard_seq_operations TO mt_all_operations.

  ENDMETHOD.

  METHOD build_operation_sequances.
    CLEAR mt_operation_sequances.
    LOOP AT mt_affl INTO DATA(ls_affl).
      APPEND zcl_operation_sequance=>factory( ir_order = me
                                                      is_affl  = ls_affl ) TO mt_operation_sequances.
    ENDLOOP.
  ENDMETHOD.

  METHOD class_constructor.
*#read MRP elements Designation
    SELECT * FROM t457t INTO TABLE gt_t457t             "#EC CI_NOORDER
      WHERE spras = sy-langu.
    IF sy-subrc <> 0.
      SELECT * FROM t457t INTO TABLE gt_t457t           "#EC CI_NOORDER
        WHERE spras = 'E'.                                "#EC CI_SUBRC
    ENDIF.

    SELECT * FROM t482 INTO CORRESPONDING FIELDS OF TABLE gt_scheduling_type. "#EC CI_SUBRC
  ENDMETHOD.

  METHOD constructor.
    mr_pegged_requirement = me.
  ENDMETHOD.

  METHOD do_after_release.
*#refresh the order information
    refresh( ).

  ENDMETHOD.

  METHOD get_mat_av_protocol.
    DATA: lt_msgprot TYPE TABLE OF cmfmsg,
          lf_num     TYPE sy-msgno.

    rr_protocol = NEW #( mid = space ).

    CALL FUNCTION 'CM_F_MESSAGES_GET' "#EC CI_SUBRC
      EXPORTING
        aplid     = 'CX1'
      TABLES
        e_msgprot = lt_msgprot
      EXCEPTIONS
        OTHERS    = 0.

    LOOP AT lt_msgprot ASSIGNING FIELD-SYMBOL(<ls_msgprot>).
      lf_num = <ls_msgprot>-msgnr.
      rr_protocol->set( mid = <ls_msgprot>-arbgb
                        num = lf_num
                        pa1 = <ls_msgprot>-msgv1
                        pa2 = <ls_msgprot>-msgv2
                        pa3 = <ls_msgprot>-msgv3
                        pa4 = <ls_msgprot>-msgv4
                        typ = <ls_msgprot>-msgty ).
    ENDLOOP.
    CLEAR lt_msgprot.
    CALL FUNCTION 'CM_F_MESSAGES_GET' "#EC CI_SUBRC
      EXPORTING
        aplid     = 'PPCS'
      TABLES
        e_msgprot = lt_msgprot
      EXCEPTIONS
        OTHERS    = 0.

    LOOP AT lt_msgprot ASSIGNING <ls_msgprot>.
      lf_num = <ls_msgprot>-msgnr.
      rr_protocol->set( mid = <ls_msgprot>-arbgb
                        num = lf_num
                        pa1 = <ls_msgprot>-msgv1
                        pa2 = <ls_msgprot>-msgv2
                        pa3 = <ls_msgprot>-msgv3
                        pa4 = <ls_msgprot>-msgv4
                        typ = <ls_msgprot>-msgty ).
    ENDLOOP.
    CLEAR lt_msgprot.

    reset_mat_av_protocol( ).
  ENDMETHOD.

  METHOD get_scheduling_protocol.
    DATA: lt_msgprot TYPE TABLE OF cmfmsg,
          lf_num     TYPE sy-msgno.
    FIELD-SYMBOLS: <ls_msgprot> TYPE cmfmsg.

    CREATE OBJECT rr_protocol
      EXPORTING
        mid = space.

*# only collect errors
    CALL FUNCTION 'CM_F_MESSAGES_GET' "#EC CI_SUBRC
      EXPORTING
        aplid     = 'PPCP'
      TABLES
        e_msgprot = lt_msgprot
      EXCEPTIONS
        OTHERS    = 0.

    LOOP AT lt_msgprot ASSIGNING <ls_msgprot> WHERE msgty <> 'I'.
      lf_num = <ls_msgprot>-msgnr.
      rr_protocol->set( mid = <ls_msgprot>-arbgb
                        num = lf_num
                        pa1 = <ls_msgprot>-msgv1
                        pa2 = <ls_msgprot>-msgv2
                        pa3 = <ls_msgprot>-msgv3
                        pa4 = <ls_msgprot>-msgv4
                        typ = <ls_msgprot>-msgty ).
    ENDLOOP.

    CALL FUNCTION 'CM_F_MESSAGES_GET' "#EC CI_SUBRC
      EXPORTING
        aplid     = 'PPCX'
      TABLES
        e_msgprot = lt_msgprot
      EXCEPTIONS
        OTHERS    = 0.

    LOOP AT lt_msgprot ASSIGNING <ls_msgprot> WHERE msgty <> 'I'.
*# Error-Message C7(022) is thrown, if an initial date is set internally (19791231, 240000).
*# This error has no effect in function, so we degrade it to a warning message.
*# Appears at most by maintenance orders
      IF <ls_msgprot>-arbgb = 'C7' AND
         <ls_msgprot>-msgnr = '022'.
        <ls_msgprot>-msgty = zcl_msg=>co_warning.
      ENDIF.
      lf_num = <ls_msgprot>-msgnr.
      rr_protocol->set( mid = <ls_msgprot>-arbgb
                        num = lf_num
                        pa1 = <ls_msgprot>-msgv1
                        pa2 = <ls_msgprot>-msgv2
                        pa3 = <ls_msgprot>-msgv3
                        pa4 = <ls_msgprot>-msgv4
                        typ = <ls_msgprot>-msgty ).
    ENDLOOP.

    reset_scheduling_protocol( ).
  ENDMETHOD.

  METHOD read_affl.
    CLEAR zif_order~mt_affl.
    CALL FUNCTION 'CO_BO_AFFLBT_GET'
      EXPORTING
        aufnr_imp  = ms_caufvd-aufnr
      TABLES
        afflbt_exp = zif_order~mt_affl.

*#In update task the AFFL is in another Function group
    IF zif_order~mt_affl IS INITIAL.
      FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
      DATA: lt_afflb TYPE TABLE OF afflb,
            ls_affld TYPE affld.

*#read the operation Sequances from the SAP buffer tables
      ASSIGN ('(SAPLCOBT)AFFL_BT[]') TO <lt_table>.
      IF sy-subrc = 0 AND <lt_table> IS ASSIGNED.
        lt_afflb = <lt_table>.
        LOOP AT lt_afflb INTO DATA(ls_afflb).
          MOVE-CORRESPONDING ls_afflb TO ls_affld.
          APPEND ls_affld TO zif_order~mt_affl.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD read_aob.
    DELETE mt_aob WHERE flgnr_b NE '000000'.
    DELETE mt_aob WHERE flgnr_v NE '000000'.
  ENDMETHOD.

  METHOD read_demand_header.
    CALL FUNCTION 'CY_BT_KBKO_READ_WITH_KEY' "#EC CI_SUBRC
      EXPORTING
        i_bedid  = ms_caufvd-bedid
      IMPORTING
        kbko_exp = ms_kbko
      EXCEPTIONS
        no_entry = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
    ENDIF.
  ENDMETHOD.

  METHOD read_header_and_position.
    CALL FUNCTION 'CO_BT_CAUFV_READ_WITH_KEY'
      EXPORTING
        aufnr_act  = mf_aufnr
      IMPORTING
        afpod_exp  = ms_afpod
        caufvd_exp = ms_caufvd
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
*#if the order was not pre buffered(CO_DB_ORDER_PRE_READ) then read it from the DB
      SELECT SINGLE * FROM caufv INTO CORRESPONDING FIELDS OF ms_caufvd WHERE aufnr = mf_aufnr. "#EC CI_NOORDER "#EC CI_SUBRC
      SELECT SINGLE * FROM afpo INTO CORRESPONDING FIELDS OF ms_afpod WHERE aufnr = mf_aufnr. "#EC CI_NOORDER "#EC CI_SUBRC
    ENDIF.
  ENDMETHOD.

  METHOD read_statuses.
*#read order statuses
*#all needed status constants are here---->LCOKOSTA
    CLEAR mt_statuses.
    CALL FUNCTION 'STATUS_READ' "#EC CI_SUBRC
      EXPORTING
        objnr            = ms_caufvd-objnr
        only_active      = abap_true
      TABLES
        status           = mt_statuses
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
    ENDIF.

  ENDMETHOD.

  METHOD read_tcx00.
    CALL FUNCTION 'TCX00_READ'
      EXPORTING
        i_werks           = ms_caufvd-werks
        i_aufta           = ms_caufvd-auart
        i_autyp           = ms_caufvd-autyp
        i_vagrp           = ms_caufvd-fevor
      IMPORTING
        tcx00_exp         = ms_tcx00
      EXCEPTIONS
        no_entry          = 1
        missing_parameter = 2
        OTHERS            = 3.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE zcx_tcx_notfound.
    ENDIF.
  ENDMETHOD.

  METHOD reset_mat_av_protocol.
    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES' "#EC CI_SUBRC
      EXPORTING
        aplid  = 'CX1'
        number = '999'
      EXCEPTIONS
        OTHERS = 0.

    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES' "#EC CI_SUBRC
      EXPORTING
        aplid  = 'PPCS'
        number = '999'
      EXCEPTIONS
        OTHERS = 0.

  ENDMETHOD.

  METHOD reset_scheduling_protocol.
    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES' "#EC CI_SUBRC
      EXPORTING
        aplid  = 'PPCX'
        number = '999'
      EXCEPTIONS
        OTHERS = 0.

    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES' "#EC CI_SUBRC
      EXPORTING
        aplid  = 'PPCP'
        number = '999'
      EXCEPTIONS
        OTHERS = 0.

  ENDMETHOD.

METHOD zif_order~check_capacity_availability.
  DATA: lf_return_code TYPE sy-subrc,
        ls_tco11       TYPE tco11.

  FIELD-SYMBOLS: <lt_kapid_fail> TYPE tt_fehl_kap.

  schedule( ).

  IF if_profile_id IS SUPPLIED AND
     if_profile_id IS NOT INITIAL.

    CALL FUNCTION 'CO_TA_TCO11_READ'
      EXPORTING
        auart     = ms_caufvd-auart
        vorgang   = '1' "EROF
        werks     = ms_caufvd-werks
      IMPORTING
        tco11wa   = ls_tco11
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      ls_tco11-vpkapprof = if_profile_id.
      CALL FUNCTION 'CO_TA_TCO11_SET'
        EXPORTING
          tco11_imp = ls_tco11.
    ENDIF.
    CALL FUNCTION 'CO_TA_TCO11_READ'
      EXPORTING
        auart     = ms_caufvd-auart
        vorgang   = '2' "FREI
        werks     = ms_caufvd-werks
      IMPORTING
        tco11wa   = ls_tco11
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      ls_tco11-vpkapprof = if_profile_id.
      CALL FUNCTION 'CO_TA_TCO11_SET'
        EXPORTING
          tco11_imp = ls_tco11.
    ENDIF.

  ENDIF.

  CALL FUNCTION 'CO_ZA_AVAILABILITY_CAP_CHECK'
    EXPORTING
      i_caufvd    = ms_caufvd
      i_no_dialog = if_no_dialog
    IMPORTING
      retcode_exp = lf_return_code.
*#the only way to get all the workcenters with overload is by accessing the FUBA attribute...
  ASSIGN ('(SAPLCY23)FEHL_KAP[]') TO <lt_kapid_fail>.
  IF sy-subrc = 0.
    rt_fehl_kap = <lt_kapid_fail>.
  ENDIF.

  refresh( ).

  CASE lf_return_code.
    WHEN 0."Kein Arbeitsplatz mit Überlast
      ir_msg->set( mid = 'C2'
                   num = 75 "Kapazitätsverfügbarkeit: Kapazität auf allen Arbeitsplätzen verfügbar
                   typ = zcl_msg=>co_success ).
    WHEN 1."Arbeitsplatz mit Überlast
      ir_msg->set( mid = 'Z_CORE'
                   num = '005' "Kapazitätsverfügbarkeit: Arbeitsplätze mit Überlast vorhand.
                   typ = zcl_msg=>co_error ).
      ir_msg->set( mid = 'Z_CORE'
                   num = '006' "Arbeitsplätze mit Überlast: &1.
                   pa1 = CONV symsgv( get_failed_workcenters( rt_fehl_kap ) )
                   typ = zcl_msg=>co_error ).
  ENDCASE.

ENDMETHOD.

METHOD get_failed_workcenters.
  DATA: lt_kapid TYPE TABLE OF kapid.

  LOOP AT it_fehl_kap ASSIGNING FIELD-SYMBOL(<ls_kapid_fail>).
    COLLECT <ls_kapid_fail>-kapid INTO lt_kapid.
  ENDLOOP.

  CHECK lt_kapid IS NOT INITIAL.

  SELECT DISTINCT objid FROM crca INTO TABLE @DATA(lt_arbid)
        FOR ALL ENTRIES IN @lt_kapid
          WHERE kapid = @lt_kapid-table_line
            AND objty = @zcl_arbid=>co_objty_workcenter.

  LOOP AT lt_arbid INTO DATA(lf_arbid).
    DATA(lr_arbid) = zcl_arbid=>get_instance( CONV #( lf_arbid  ) ).
    IF rf_value IS INITIAL.
      rf_value = lr_arbid->mf_arbpl.
    ELSE.
      rf_value = rf_value && '/' && |{ lr_arbid->mf_arbpl }|.
    ENDIF.
  ENDLOOP.
ENDMETHOD.

  METHOD set_status_at_schedule.
    DATA lt_set_status TYPE /gib/dcp_jest_t.
    CHECK ms_caufvd-objnr IS NOT INITIAL.

    IF ms_caufvd-tmbas = '2'. "Forecastdates
      APPEND VALUE #( stat = zif_jstatus=>co_nsch ) TO lt_set_status.
    ELSE.
      APPEND VALUE #( stat = zif_jstatus=>co_ntup ) TO lt_set_status.
    ENDIF.

    " Remove the commited status (MABS)
    APPEND VALUE #( stat = zif_jstatus=>co_macm
                    inact = abap_true ) TO lt_set_status.
    " Set not checked to material components (NVMP)
    APPEND VALUE #( stat = zif_jstatus=>co_manc ) TO lt_set_status.

    CALL FUNCTION 'STATUS_CHANGE_INTERN'
      EXPORTING
        objnr  = ms_caufvd-objnr
      TABLES
        status = lt_set_status
      EXCEPTIONS
        OTHERS = 0.
  ENDMETHOD.

  METHOD update_order.
    IF if_vbkz = abap_false.
      DATA(lf_no_vbkz) = abap_true.
    ENDIF.
    CALL FUNCTION 'CO_BT_CAUFV_UPD'
      EXPORTING
        caufvd_upd  = ms_caufvd
        flg_no_vbkz = lf_no_vbkz
      .

  ENDMETHOD.
ENDCLASS.
