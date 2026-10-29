class ZCL_ORDER_PLANO definition
  public
  inheriting from ZCL_ORDER
  create public

  global friends ZCL_ORDER_BUFFER .

public section.

  data MS_PLAF type PLAF read-only .
  class-data GF_STOP type FLAG .
  constants:
    BEGIN OF co_vstat,
        add(1)          TYPE c VALUE 'H',"Hinzufuegen
        update(1)       TYPE c VALUE 'V',"Veraendern
        delete(1)       TYPE c VALUE 'L',"Loeschen
        new_opened(1)   TYPE c VALUE 'N',"Neu aufloesen
        insert(1)       TYPE c VALUE 'I',"Einfuegen
        activate(1)     TYPE c VALUE 'A',"Anzeigen/Aktivieren
        deactivate(1)   TYPE c VALUE 'D',"Deaktivieren
        part_dismantling(1) TYPE c VALUE 'T',"Teilabbau
        correcting(1)   TYPE c VALUE 'K',"Komplettabbau/Korrigieren
        simulate(1)     TYPE c VALUE 'S',"Simulieren
        aggregate(1)    TYPE c VALUE 'C',"Aggregieren
        reduce(1)       TYPE c VALUE 'R',"Rückmeldung - Reduzieren
        confirmation(1) TYPE c VALUE 'E',"Endrückmeldung - Löschen
              END OF co_vstat .
  data MF_VSTAT type CHAR1 .
  constants CO_PAART_STOCK_ORDER type PAART value 'LA' ##NO_TEXT.
  constants CO_PAART_RUN_SCHEDULE_QTY type PAART value 'PE' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IS_PLAF type PLAF .
  methods SET_PLAF
    importing
      !IS_PLAF type PLAF
    raising
      ZCX_CORE .
  class-methods GET_KBED_TYPKZ_FROM_PLAF
    importing
      !IS_PLAF type PLAF
    returning
      value(RF_KBED_TYPKZ) type TYPKZ .
  class-methods GET_BEDID_FROM_PLAF
    importing
      !IS_PLAF type PLAF
    returning
      value(RF_BEDID) type BEDID .
  methods CONVERT
    importing
      !IF_AUFART type AUFART optional
    returning
      value(RR_ORDER) type ref to ZIF_ORDER
    raising
      ZCX_CORE .
  methods SET_FIRMING_INDICATOR
    importing
      !IS_PLAF type PLAF
    raising
      ZCX_CORE .

  methods ZIF_LONG_TEXT~DISPLAY
    redefinition .
  methods ZIF_LONG_TEXT~EDIT
    redefinition .
  methods ZIF_LONG_TEXT~HAS_LONG_TEXT
    redefinition .
  methods ZIF_ORDER~CHANGE_PRODUCTION_VERSION
    redefinition .
  methods ZIF_ORDER~CHANGE_SEQUENCE_NUMBER
    redefinition .
  methods ZIF_ORDER~CHANGE_TOTAL_QUANTITY
    redefinition .
  methods ZIF_ORDER~CHECK_MATERIAL_AVAILABILITY
    redefinition .
  methods ZIF_ORDER~DIALOG
    redefinition .
  methods ZIF_ORDER~GET_LEAD_PLNID
    redefinition .
  methods ZIF_ORDER~GET_UPDATE_KEY
    redefinition .
  methods ZIF_ORDER~REFRESH
    redefinition .
  methods ZIF_ORDER~SCHEDULE
    redefinition .
  methods ZIF_ORDER~SCHEDULE_BASIC_DATES
    redefinition .
  methods ZIF_ORDER~START_UPDATE
    redefinition .
protected section.

  methods BUILD_PEGGED_REQUIREMENT_HEAD
    redefinition .
  methods READ_HEADER_AND_POSITION
    redefinition .
  methods READ_PRODUCTION_AIDS
    redefinition .
  methods READ_TCX00
    redefinition .
private section.

  data MF_VIRTUAL_AUFNR type AUFNR .
  data MF_KBED_TYPKZ type TYPKZ .
  data MF_LEAD_PLNUM type PLNUM .
  data MF_LEAD_PLNUM_READ type FLAG .

  methods UPDATE_SCHEDULING_TYPE_BUFFER
    importing
      !IF_TERMKZ type TERMKZ .
  methods GET_LEAD_PLNUM
    importing
      !IF_ARSNR type ARSNR
      !IF_ARSPS type ARSPS
    returning
      value(RF_PLNUM) type PLNUM .
  methods GENERATE_VIRTUAL_AUFNR .
  methods BUILD_KBED_TYPKZ .
  methods READ_PLAF .
ENDCLASS.

CLASS ZCL_ORDER_PLANO IMPLEMENTATION.

  METHOD zif_long_text~display.
    DATA: ls_head     TYPE thead,
          ls_result   TYPE itcer,
          lt_lines    TYPE STANDARD TABLE OF tline,
          lf_function TYPE sy-ucomm.

    CHECK sy-batch IS INITIAL.

    CONCATENATE sy-mandt ms_plaf-plnum INTO ls_head-tdname.
    ls_head-tdobject   = '/GIB/DCP'.
    ls_head-tdid       = 'PLAF'.
    ls_head-tdspras    = sy-langu.
    ls_head-tdlinesize = 72.

*# get existing text if any
    CALL FUNCTION 'READ_TEXT' "#EC CI_SUBRC
      EXPORTING
        id                      = ls_head-tdid
        language                = ls_head-tdspras
        name                    = ls_head-tdname
        object                  = ls_head-tdobject
      IMPORTING
        header                  = ls_head
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_success NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE zcl_msg=>co_error.
      RETURN.
    ENDIF.

    CALL FUNCTION 'EDIT_TEXT' "#EC CI_SUBRC
      EXPORTING
        display       = 'X'
        header        = ls_head
        save          = ' '
      IMPORTING
        function      = lf_function
        result        = ls_result
      TABLES
        lines         = lt_lines
      EXCEPTIONS
        OTHERS        = 0.

  ENDMETHOD.

  METHOD zif_long_text~edit.
    DATA: ls_head     TYPE thead,
          ls_result   TYPE itcer,
          lt_lines    TYPE STANDARD TABLE OF tline,
          lf_function TYPE sy-ucomm.

    CHECK sy-batch IS INITIAL.

    start_update( ).

    CONCATENATE sy-mandt ms_plaf-plnum INTO ls_head-tdname.
    ls_head-tdobject   = '/GIB/DCP'.
    ls_head-tdid       = 'PLAF'.
    ls_head-tdspras    = sy-langu.
    ls_head-tdlinesize = 72.

*# get existing text if any
    CALL FUNCTION 'READ_TEXT'"#EC CI_SUBRC
      EXPORTING
        id                      = ls_head-tdid
        language                = ls_head-tdspras
        name                    = ls_head-tdname
        object                  = ls_head-tdobject
      IMPORTING
        header                  = ls_head
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        OTHERS                  = 0.

    CALL FUNCTION 'EDIT_TEXT'"#EC CI_SUBRC
      EXPORTING
        header        = ls_head
        save          = 'X'
      IMPORTING
        function      = lf_function
        result        = ls_result
      TABLES
        lines         = lt_lines
      EXCEPTIONS
        id            = 1
        language      = 2
        linesize      = 3
        name          = 4
        object        = 5
        textformat    = 6
        communication = 7
        OTHERS        = 8.

    IF sy-subrc = 0.
      CALL FUNCTION 'COMMIT_TEXT'"#EC CI_SUBRC
        EXPORTING
          object          = ls_head-tdobject
          name            = ls_head-tdname
          id              = ls_head-tdid
          language        = '*'
          savemode_direct = 'X'.
    ENDIF.

  ENDMETHOD.

  METHOD zif_long_text~has_long_text.
    DATA: ls_head TYPE thead,
          lt_lines TYPE TABLE OF tline.

    CONCATENATE sy-mandt ms_plaf-plnum INTO ls_head-tdname.
    ls_head-tdobject   = '/GIB/DCP'.
    ls_head-tdid       = 'PLAF'.
    ls_head-tdspras    = sy-langu.
    ls_head-tdlinesize = 72.
    SELECT COUNT(*) FROM stxh "#EC DBACCESS_OK
     WHERE tdobject = ls_head-tdobject
       AND tdname   = ls_head-tdname
       AND tdid     = ls_head-tdid
       AND tdspras  = ls_head-tdspras.

    IF sy-subrc = 0.
      rf_answer = 'X'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~change_production_version.

    CREATE OBJECT rr_protocol.

    CHECK if_new_verid IS NOT INITIAL.

    READ TABLE mr_material->mt_mkal WITH KEY verid = if_new_verid TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0 .
      rr_protocol->set( mid = 'Z_CORE'
                        num = 106"Fertigungsversion '&' ist nicht vorhanden.
                        pa1 = if_new_verid
                        typ = 'E' ).
      RETURN.
    ENDIF.

    start_update( ).

    ms_plaf-verid = if_new_verid.
    set_plaf( ms_plaf ).
*#after a change of production version the virtual order must be regenerated
    generate_virtual_aufnr( ).
* before operation can be rebuild we have to refresh sequences table
    read_affl( ).
*#after a change of production version the operations must be rebuilt
    build_operations( ).

    refresh( ).

  ENDMETHOD.

  METHOD zif_order~change_total_quantity.

    super->change_total_quantity( if_value = if_value
                                  ir_protocol = ir_protocol ).

*# Change scrap quantity if required
    IF if_gasmg = -1. "Automatische anpassung
      DATA: lf_new_avmng TYPE plaf-avmng.
      DATA: lf_andec TYPE t006-andec.
      IF ms_caufvd-matnr IS NOT INITIAL AND
         ms_plaf-avmng <> 0 AND
         ms_plaf-gsmng <> if_value.
        lf_new_avmng = ms_plaf-avmng * if_value / ms_plaf-gsmng.
        SELECT SINGLE andec FROM t006 INTO lf_andec WHERE msehi = ms_plaf-meins.
        IF sy-subrc = 0 AND lf_andec < 3 AND lf_new_avmng <> 0.
          IF lf_new_avmng MOD 1 <> 0.
            lf_new_avmng = round( val = lf_new_avmng
                                  dec = lf_andec
                                  mode = cl_abap_math=>round_up ).
          ENDIF.
        ENDIF.

        IF lf_new_avmng <> ms_plaf-avmng.
          IF ir_protocol IS BOUND.
            ir_protocol->set( EXPORTING num = '553' "Ausschussmenge wurde proportional auf x angepasst
                                        typ = zcl_msg=>co_warning
                                        pa1 = |{  lf_new_avmng NUMBER = USER }| ).
          ENDIF.
          ms_plaf-avmng = lf_new_avmng.
        ENDIF.
      ENDIF.
    ELSE.
      ms_plaf-avmng = if_gasmg.
    ENDIF.

    ms_plaf-gsmng = if_value.

    set_plaf( ms_plaf ).
    schedule( ).
    refresh( ).
  ENDMETHOD.

METHOD zif_order~check_material_availability.

  CALL FUNCTION '/GIB/DCP_CHECK_MATNR_AVAIL'
    EXPORTING
      it_aufnr_r  = VALUE /gib/dcp_aufnr_tr( ( ) )
      it_plnum_r  = VALUE range_t_plnum( ( sign = 'I'
                                           option = 'EQ'
                                           low = ms_plaf-plnum ) )
      ir_protocol = rr_protocol.
ENDMETHOD.

  METHOD zif_order~dialog.

    DATA: ls_cm61o TYPE cm61o.
    TRY .
        start_update( ).

*#in order to allow the BASIC Schedule to be manipulated we must change the scheduling parameters from the value
*#currently found in PLAF
        update_scheduling_type_buffer( ms_plaf-trmkz ).
        CALL FUNCTION 'PLANNED_ORDER_CHANGE'
          EXPORTING
            plnum                  = ms_plaf-plnum
          EXCEPTIONS
            plaf_logically_deleted = 1
            plaf_not_found         = 2
            locked                 = 3
            locking_error          = 4
            OTHERS                 = 5.
        IF sy-subrc = 0.
*#read the changes
          read_plaf( ).
          set_plaf( ms_plaf ).
          refresh( ).
        ELSE.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE zcl_msg=>co_error.
        ENDIF.
*#set the scheduling parameters back to the initial state before the method call
        update_scheduling_type_buffer( ms_tcx00-termkz ).

      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
*#if locked just display
        ls_cm61o-darkx = space."Save in Background
        ls_cm61o-autho = abap_true."Authority check durchfuehren
        ls_cm61o-trtyp = 'A'."Display
        ls_cm61o-stpre = 'AP'.
        CALL FUNCTION 'MD_PLANNED_ORDER_SHOW'
          EXPORTING
            ecm61o = ls_cm61o
            eplaf  = ms_plaf.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_order~get_lead_plnid.

    IF mf_lead_plnum_read IS INITIAL.
      mf_lead_plnum = get_lead_plnum( if_arsnr = ms_plaf-arsnr
                                      if_arsps = ms_plaf-arsps ).
      mf_lead_plnum_read = abap_true.
    ENDIF.

    rf_plnid(10) = mf_lead_plnum.

  ENDMETHOD.

  METHOD zif_order~get_update_key.
    IF mf_vstat IS NOT INITIAL.
      CASE mf_vstat.
        WHEN co_vstat-add OR
             co_vstat-insert.
          rf_vbkz = co_vbkz-insert.
        WHEN co_vstat-delete OR
             co_vstat-confirmation.
          rf_vbkz = co_vbkz-delete.
        WHEN OTHERS.
          rf_vbkz = co_vbkz-update.
      ENDCASE.
    ELSE.
      DATA: lf_statu TYPE char1.
      CALL FUNCTION 'GET_PLAF_WITH_PLNUM' "#EC CI_SUBRC
        EXPORTING
          plnum                  = ms_plaf-plnum
        IMPORTING
          statu                  = lf_statu
        EXCEPTIONS
          OTHERS                 = 0.

*#update the VBKZ as for normal orders
      CASE lf_statu.
        WHEN 'D'. "PLAF logically deleted
          rf_vbkz = co_vbkz-delete.
        WHEN 'N'."PLAF new
          rf_vbkz = co_vbkz-insert.
        WHEN 'U'."PLAF modified
          rf_vbkz = co_vbkz-update.
        WHEN 'E'."PLAF unchanged
        WHEN OTHERS.
      ENDCASE.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order~refresh.
    read_plaf( ).

    super->refresh( ).
  ENDMETHOD.

  METHOD zif_order~schedule.
*#this will also re virtualise the plannedOrder and update all the operations from the buffer tables
    start_update( ).

*#in order to allow the BASIC Schedule to be manipulated we must change the scheduling parameters from the value
*#currently found in PLAF
    update_scheduling_type_buffer( ms_plaf-trmkz ).

*#schedule as planned order
    CALL FUNCTION 'CX_CRP_PLANNED_ORDER_SCHEDULE'
      EXPORTING
        plaf_imp      = ms_plaf
        i_kbed_typkz  = mf_kbed_typkz
      IMPORTING
        plaf_exp      = ms_plaf
      EXCEPTIONS
        error_message = 01.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*#set the scheduling parameters back to the initial state before the method call
    update_scheduling_type_buffer( ms_tcx00-termkz ).

*#schedule is already done in 'CX_CRP_PLANNED_ORDER_SCHEDULE'
    rr_protocol = get_scheduling_protocol( ).
*#here we only need to refresh the order
    refresh( ).

  ENDMETHOD.

METHOD zif_order~schedule_basic_dates.
  rr_protocol = super->schedule_basic_dates( if_pit             = if_pit
                                             is_scheduling_type = is_scheduling_type ).

  ms_plaf-psttr = ms_caufvd-gstrp."Basic Start
  ms_plaf-pstti = ms_caufvd-gsuzp."Startzeitpunkt des Planauftrags
  ms_plaf-pedtr = ms_caufvd-gltrp."Basic End
  ms_plaf-pedti = ms_caufvd-gluzp."Endezeitpunkt des Planauftrags

  ms_plaf-trmkz = is_scheduling_type-termkz.

  IF ms_caufvd-autyp = zif_order=>co_autyp-process.
    ms_plaf-psttr = ms_caufvd-gstrs."Scheduled Start
    ms_plaf-pstti = ms_caufvd-gsuzs."Startzeitpunkt des Planauftrags
    ms_plaf-pedtr = ms_caufvd-gltrs."Scheduled End
    ms_plaf-pedti = ms_caufvd-gluzs."Endezeitpunkt des Planauftrags
  ENDIF.

  CLEAR ms_plaf-pertr."will be calcuated form the new basic dates
  set_plaf( ms_plaf ).

  refresh( ).
ENDMETHOD.

  METHOD zif_order~start_update.
    IF zcl_order_buffer=>is_present_in_stack( me ) IS INITIAL
      AND ms_plaf-plnum IS NOT INITIAL.
      CALL FUNCTION 'ENQUEUE_EMPLAFE'
        EXPORTING
          plnum          = ms_plaf-plnum
        EXCEPTIONS
          foreign_lock   = 2
          system_failure = 3.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_order_locked
          EXPORTING
            aufnr = mf_plnid.
      ENDIF.

      read_plaf( )."needed for accurate generation of virtual order
      generate_virtual_aufnr( ).
      refresh( ).
    ENDIF.

    super->start_update( ).

  ENDMETHOD.

  METHOD build_kbed_typkz.
    mf_kbed_typkz = get_kbed_typkz_from_plaf( ms_plaf ).
  ENDMETHOD.

  METHOD BUILD_PEGGED_REQUIREMENT_HEAD.
    ms_pegged_requirement_head-delkz = zif_pegged_requirement=>co_plano.
    ms_pegged_requirement_head-delnr = ms_plaf-plnum.
    ms_pegged_requirement_head-delps = 0.
    ms_pegged_requirement_head-matnr = ms_plaf-matnr.
    ms_pegged_requirement_head-werks = ms_caufvd-werks.
    ms_pegged_requirement_head-plwrk = ms_plaf-plwrk.
  ENDMETHOD.

  METHOD constructor.
    DATA: lf_werks TYPE werks_d.

    super->constructor( ).

    DATA: lr_werks TYPE REF TO zcl_werks.

    ms_plaf   = is_plaf.
    mf_plnid  = is_plaf-plnum.
    mf_sart   = zif_core_constants=>co_sart-plano.
    build_kbed_typkz( ).

    TRY.
        read_tcx00( ).
      CATCH zcx_tcx_notfound.
    ENDTRY.

*#get the werks for the material
    IF ms_plaf-pwwrk IS INITIAL.
      lf_werks = ms_plaf-plwrk.  "Planungswerk
    ELSE.
      lf_werks = ms_plaf-pwwrk.  "Produktionswerk
    ENDIF.
    lr_werks = zcl_werks=>get_instance( lf_werks ).
    mr_material = zcl_werks_material=>get_instance( ir_werks = lr_werks
                                                            if_matnr = ms_plaf-matnr ).

    generate_virtual_aufnr( ).

    read_demand_header( ).
    read_statuses( ).
    read_aob( ).

    read_affl( ).

    mf_parallel_sequences = zcl_order_buffer=>gf_parallel_sequences.
    build_operations( ).
  ENDMETHOD.

METHOD convert.
  DATA: ls_order_type TYPE t003o,
        ls_caufvd     TYPE caufvd,
        ls_afpod      TYPE afpod,
        lt_aufnr_tab  TYPE TABLE OF ord_pre,
        lf_converted  TYPE char1.

  IF ms_plaf-umskz IS INITIAL."Planaufträge ohne Umsetzungskennzeichen können nicht umgesetzt werden.
    RAISE EXCEPTION TYPE zcx_plano_conv_failed
      EXPORTING
        textid = zcx_plano_conv_failed=>no_conversion_indicator
        plnum  = ms_plaf-plnum.
  ENDIF.

  IF ms_plaf-verid IS INITIAL."Fertigungsversion erforderlich - Planauftrag &1 wird nicht umgesetzt
    RAISE EXCEPTION TYPE zcx_plano_conv_failed
      EXPORTING
        textid = zcx_plano_conv_failed=>no_production_version
        plnum  = ms_plaf-plnum.
  ENDIF.

  start_update( ).

  CALL FUNCTION 'CO_TA_T003O_READ'
    EXPORTING
      t003o_auart = if_aufart
    IMPORTING
      t003owa     = ls_order_type
    EXCEPTIONS
      not_found   = 01.
  IF sy-subrc <> 0 OR ls_order_type IS INITIAL.
    CALL FUNCTION 'CO_TA_T003O_READ' "#EC CI_SUBRC
      EXPORTING
        t003o_auart = ms_caufvd-auart
      IMPORTING
        t003owa     = ls_order_type
      EXCEPTIONS
        OTHERS      = 0.
  ENDIF.

*#BUILD AFPOD init entry
  ls_afpod-plnum = ms_plaf-plnum.
  ls_afpod-dwerk = ms_plaf-pwwrk.
  ls_afpod-berid = ms_plaf-berid.
  ls_afpod-matnr = ms_plaf-matnr.
  ls_afpod-sobkz = ms_plaf-sobkz.
  ls_afpod-verid = ms_plaf-verid.

*#BUILD CAUFVD init entry
  ls_caufvd-werks    = ms_plaf-pwwrk.
  ls_caufvd-terkz    = ms_plaf-trmkz.
  ls_caufvd-cy_seqnr = ms_plaf-seqnr.
  ls_caufvd-auart    = ls_order_type-auart.
  ls_caufvd-stats    = ls_order_type-stsma.
  ls_caufvd-umskz    = abap_true.
*#remove the PLANNEDORDER temp AUFNR from buffers!!!!
*#this is important in order not to have conflicts and Short Dumps
*#at in the BUFFER->POST()
  APPEND ms_caufvd-aufnr TO lt_aufnr_tab.
  CALL FUNCTION 'CO_IT_DEL_ORDER_FROM_DOC_TAB' "#EC CI_SUBRC
    TABLES
      aufnr_tab = lt_aufnr_tab.

  DATA(lf_seqnr) = ms_plaf-seqnr."if the SEQNR was set in the plannedorder in the current LUW it will not be mapped automaticaly

  IF ls_order_type-autyp = co_autyp-process. "OCM gilt nicht fuer Prozeßauftrag
    DATA(lf_flg_new_master_data_imp) = abap_false.
  ELSE.
    lf_flg_new_master_data_imp = abap_true.
  ENDIF.
  CALL FUNCTION 'CO_SD_PLANNED_ORDER_CONVERT' "#EC CI_SUBRC
    EXPORTING
      afpod_imp               = ls_afpod
      caufvd_imp              = ls_caufvd
      plaf_imp                = ms_plaf
      t003o_imp               = ls_order_type
      flg_new_master_data_imp = lf_flg_new_master_data_imp
    IMPORTING
      afpod_exp               = ls_afpod
      caufvd_exp              = ls_caufvd
      convert_suc             = lf_converted
      plaf_exp                = ms_plaf.
  IF lf_converted = abap_false."Planauftrag(&PLNUM&) umsetzung könnte nicht durchgeführt werden.
    RAISE EXCEPTION TYPE zcx_plano_conv_failed
      EXPORTING
        plnum = ms_plaf-plnum.
  ENDIF.

*#get the newly created Planned Order
  rr_order = zcl_order_buffer=>get_instance( )->get_order( ls_caufvd-aufnr ).

  "if the SEQNR was set in the plannedorder in the current LUW it will not be mapped automaticaly
  IF lf_seqnr IS NOT INITIAL.
    rr_order->change_sequence_number( lf_seqnr ).
  ENDIF.
ENDMETHOD.

  METHOD generate_virtual_aufnr.
    DATA: lt_mdpm           TYPE STANDARD TABLE OF mdpm,
          lf_in_update_task TYPE sy-subrc.

*#the virtual order must be created with respect to scheduling level(LVSCH)
*#scheduling levels((LVSCH)

*#KBED Types
*# a  inst.-maßnahme
*# b  inst. meldungen

*#in order to avoid a performace calls to MARC_SINGLE_READ
    DATA: ls_cx_marc TYPE cx_marc.

    MOVE-CORRESPONDING mr_material->ms_marc TO ls_cx_marc.
    ls_cx_marc-meins = ms_plaf-meins.

    CALL FUNCTION 'TH_IN_UPDATE_TASK' "#EC CI_SUBRC
      IMPORTING
        in_update_task = lf_in_update_task.

    IF lf_in_update_task IS NOT INITIAL.
      CALL FUNCTION 'MD_LESEN_KOMPONENTEN_RSNUM' "#EC CI_SUBRC
        EXPORTING
          rsnum              = ms_plaf-rsnum
          sbnum              = ms_plaf-sbnum
        TABLES
          mdpmx              = lt_mdpm
        EXCEPTIONS
          OTHERS             = 0.
*#If the order has Couple Products in can produce a short dump in Update task due to a dialog
*#called from the function "CO_ZF_BWTAR_CHECK_DARK"(if the material has a valuation). So we
*#overwrite the Couple Products flag of the component of this order in order to avoid the Dialog Call.
*#This case is only used in UPDATE TASK and will not influance the behaviour of the Planned Order Object
      LOOP AT lt_mdpm ASSIGNING FIELD-SYMBOL(<ls_mdpm>) WHERE kzkup IS NOT INITIAL.
        <ls_mdpm>-kzkup = space.
      ENDLOOP.
    ENDIF.

*#in order to allow the BASIC Schedule to be manipulated we must change the scheduling parameters from the value
*#currently found in PLAF
    update_scheduling_type_buffer( ms_plaf-trmkz ).

  DATA(lf_rap_enabled_old) = abap_false.
  FIELD-SYMBOLS <lf_rap_enabled> TYPE any.
    ASSIGN ('CL_NW_API_HANDLER_UTIL=>GV_RAP_ENABLED') TO <lf_rap_enabled>.
    IF <lf_rap_enabled> IS ASSIGNED.
      lf_rap_enabled_old = <lf_rap_enabled>.
      <lf_rap_enabled> = abap_true.
    ENDIF.

*#generate virtual order
    CASE mf_kbed_typkz.
      WHEN '2'. "Feinplanung
        CALL FUNCTION 'CX_PLANNED_ORDER_SCHEDULE' "#EC CI_SUBRC
          EXPORTING
            plaf_imp       = ms_plaf
            cx_marc_imp    = ls_cx_marc
            i_kbed_typkz   = '2' "feinterminierung
            i_flg_keep_bt  = 'X'
            i_flg_only_bt  = 'X' "Scheduling not necessary if = 'X'
            i_flg_capapl   = 'X'
            i_flg_protocol = space
          IMPORTING
            e_aufnr_fein   = mf_aufnr
          TABLES
            t_mdpm         = lt_mdpm
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN '5'. "Ratenplanung
        CALL FUNCTION 'CX_PLANNED_ORDER_SCHEDULE' "#EC CI_SUBRC
          EXPORTING
            plaf_imp       = ms_plaf
            cx_marc_imp    = ls_cx_marc
            i_kbed_typkz   = '5' "ratenterminierung
            i_flg_keep_bt  = 'X'
            i_flg_only_bt  = 'X' "Scheduling not necessary if = 'X'
            i_flg_capapl   = 'X'
            i_flg_protocol = space
          IMPORTING
            e_aufnr_rate   = mf_aufnr
          TABLES
            t_mdpm         = lt_mdpm
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN '8'. "Grobplanung
        CALL FUNCTION 'CX_PLANNED_ORDER_SCHEDULE' "#EC CI_SUBRC
          EXPORTING
            plaf_imp       = ms_plaf
            cx_marc_imp    = ls_cx_marc
            i_kbed_typkz   = '8' "grobterminierung
            i_flg_keep_bt  = 'X'
            i_flg_only_bt  = 'X' "Scheduling not necessary if = 'X'
            i_flg_capapl   = 'X'
            i_flg_protocol = space
          IMPORTING
            e_aufnr_grob   = mf_aufnr
          TABLES
            t_mdpm         = lt_mdpm
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      WHEN OTHERS.
*#try to generate for detailed scheduling
        CALL FUNCTION 'CX_PLANNED_ORDER_SCHEDULE' "#EC CI_SUBRC
          EXPORTING
            plaf_imp       = ms_plaf
            cx_marc_imp    = ls_cx_marc
            i_kbed_typkz   = '2' "feinterminierung
            i_flg_keep_bt  = 'X'
            i_flg_only_bt  = 'X' "Scheduling not necessary if = 'X'
            i_flg_capapl   = 'X'
            i_flg_protocol = space
          IMPORTING
            e_aufnr_fein   = mf_aufnr
          TABLES
            t_mdpm         = lt_mdpm
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

    ENDCASE.

  IF <lf_rap_enabled> IS ASSIGNED.
    <lf_rap_enabled> = lf_rap_enabled_old.
  ENDIF.

*#set the scheduling parameters back to the initial state before the method call
    update_scheduling_type_buffer( ms_tcx00-termkz ).

    "call the read_header_and_position because it is necessary to
    "update the caufvd structure. It could be, that i.e. after an
    "change of the production version we get another virtual aufnr
    "so we have to update the caufvd from the new aufnr that the
    "following coding can continue.
    read_header_and_position( ).
  ENDMETHOD.

  METHOD get_bedid_from_plaf.

*#scheduling levels((LVSCH)

    rf_bedid = is_plaf-bedid.
  ENDMETHOD.

  METHOD get_kbed_typkz_from_plaf.
*#the kbed_typkz must be created with respect to scheduling level(lvsch)
*#scheduling levels((LVSCH)

*#KBED Types
*# a  inst.-maßnahme
*# b  inst. meldungen

    CASE is_plaf-lvsch.
      WHEN '1'. "Feinplanung
        rf_kbed_typkz = '2'. "feinterminierung
      WHEN '2'. "Ratenplanung
        rf_kbed_typkz = '5'. "ratenterminierung
      WHEN '3'. "Grobplanung
        rf_kbed_typkz = '8'. "grobterminierung
      WHEN OTHERS.
        rf_kbed_typkz = '2'. "feinterminierung
    ENDCASE.
  ENDMETHOD.

  METHOD get_lead_plnum.
    DATA: ls_plaf_lead TYPE plaf_lead.

    SELECT SINGLE * FROM plaf_lead INTO ls_plaf_lead
                                   WHERE rsnum EQ if_arsnr
                                   AND   rspos EQ if_arsps
                                   AND   rsart EQ ' '.
    CHECK sy-subrc IS INITIAL.
    IF ls_plaf_lead-arsnr IS NOT INITIAL.
      rf_plnum = get_lead_plnum( if_arsnr = ls_plaf_lead-arsnr
                                 if_arsps = ls_plaf_lead-arsps ).
    ELSE.
      rf_plnum = ls_plaf_lead-plnum.
    ENDIF.
  ENDMETHOD.

  METHOD read_header_and_position.
    super->read_header_and_position( ).
  ENDMETHOD.

  METHOD read_plaf.
    CALL FUNCTION 'GET_PLAF_WITH_PLNUM'
      EXPORTING
        plnum                  = ms_plaf-plnum
      IMPORTING
        oplaf                  = ms_plaf
      EXCEPTIONS
        no_plnum_specified     = 1
        object_not_found       = 2
        plaf_logically_deleted = 3
        OTHERS                 = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      SELECT SINGLE * FROM plaf INTO ms_plaf WHERE plnum = ms_plaf-plnum."#EC CI_SUBRC
    ENDIF.

  ENDMETHOD.

  METHOD read_production_aids.
    DATA:
          ls_fhm  TYPE affhd,
          ls_fhmx TYPE z_fhmx,
          lt_plpo TYPE TABLE OF coplpo,
          ls_affh TYPE affh.

    DATA(lr_rm) = zcl_routing_master=>get_instance(
                    if_plnty = ms_caufvd-plnty
                    if_plnnr = ms_caufvd-plnnr
                    if_plnal = ms_caufvd-plnal ).
    CHECK lr_rm IS BOUND.
    lr_rm->get_data( IMPORTING
                       et_plfh = DATA(lt_plfh)
                     RECEIVING
                       rf_data_found = DATA(lf_routing_found) ).
    CHECK lf_routing_found = abap_true.

    LOOP AT lt_plfh INTO DATA(ls_plfh).
      CLEAR: ls_fhm,
             ls_fhmx,
             ls_affh.

      MOVE-CORRESPONDING ls_plfh TO ls_affh.
      ls_affh-mgsol   = ls_plfh-mgvgw.
      ls_affh-mgsoleh = ls_plfh-mgeinh.

      CALL FUNCTION 'CF_BT_CO_FHM_FROM_AFFH_FILL'
        EXPORTING
          affh_imp             = ls_affh
        IMPORTING
          affhd_exp            = ls_fhm
        EXCEPTIONS
          fhm_master_not_found = 1.
      IF sy-subrc = 0.
        ls_fhmx-plnkn = ls_plfh-plnkn.
        MOVE-CORRESPONDING ls_fhm TO ls_fhmx.
        APPEND ls_fhmx TO mt_fhm.
      ENDIF.
    ENDLOOP.
    mf_fhm_buffered = abap_true.

  ENDMETHOD.

  METHOD read_tcx00.
*#Read the correct TCX00 for PlannedOrders
    CALL FUNCTION 'TCX00_READ'
      EXPORTING
        i_aufta           = ms_plaf-paart
        i_auftg           = '2' "auf_gruppe-pauf
        i_vagrp           = ms_plaf-plgrp
        i_werks           = ms_plaf-pwwrk
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

  METHOD set_firming_indicator.
    DATA: ls_headerdata TYPE bapiplaf_i2,
          ls_headerdatax TYPE bapiplaf_i2x.

    start_update( ).

    ls_headerdata-firming_ind = is_plaf-auffx.
    ls_headerdatax-firming_ind = abap_true.
    CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'  "#EC CI_USAGE_OK[2438131]
      EXPORTING
        plannedorder = is_plaf-plnum
        headerdata   = ls_headerdata
        headerdatax  = ls_headerdatax.

  ENDMETHOD.

  METHOD set_plaf.
    DATA: ls_plaf TYPE plaf.

    start_update( ).

    ls_plaf = is_plaf.

*#For every database change to a planned order, the system checks the time stamp for the planned order
*#and sets this again. This stores the last time at which the planned order was changed.
*#The timestamp check is successful, when the timestamp of a planned order read from the database by
*#another application at the time when the database change is made exactly matches the timestamp of
*#the planned order in the database.
*#In all other cases, the planned order has been changed by a parallel application at some point in between times.
*#Whem timestamp problems occur, the system usually skips over the planned order in question during updating.
*#Updating is only terminated when parallel changes are made to any dependent data in further update update
*#processes for the planned order, for example, status information about capacity requirements records.
    ls_plaf-pstmp = ms_plaf-pstmp.
    ls_plaf-puser = ms_plaf-puser.

*#in order to allow the BASIC Schedule to be manipulated we must change the scheduling parameters from the value
*#currently found in PLAF
    update_scheduling_type_buffer( ls_plaf-trmkz ).

    CALL FUNCTION 'CX_CRP_PLANNED_ORDER_SCHEDULE'
      EXPORTING
        plaf_imp       = ls_plaf
        i_kbed_typkz   = mf_kbed_typkz
        i_flg_protocol = ' '
      IMPORTING
        plaf_exp       = ms_plaf
      EXCEPTIONS
        error_message  = 01.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*#set the scheduling parameters back to the initial state before the method call
    update_scheduling_type_buffer( ms_tcx00-termkz ).
  ENDMETHOD.

  METHOD zif_order~change_sequence_number.
    super->zif_order~change_sequence_number( if_sequence_number ).
    ms_plaf-seqnr = if_sequence_number.
    set_plaf( ms_plaf ).
  ENDMETHOD.

METHOD update_scheduling_type_buffer.
*#in order to allow the BASIC Schedule to be manipulated we must change the scheduling parameters from the value
*#currently found in PLAF
  CHECK if_termkz IS NOT INITIAL.

  DATA(ls_tcx00) = ms_tcx00.
  ls_tcx00-termkz = if_termkz.
  CALL FUNCTION 'TCX00_UPDATE'
    EXPORTING
      tcx00_imp = ls_tcx00
    EXCEPTIONS
      OTHERS    = 0.

ENDMETHOD.
ENDCLASS.
