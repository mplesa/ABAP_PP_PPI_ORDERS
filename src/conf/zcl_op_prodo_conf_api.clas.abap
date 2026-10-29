class ZCL_OP_PRODO_CONF_API definition
  public
  inheriting from ZCL_OPERATION_CONF_API
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IR_OPERATION type ref to ZIF_OPERATION .

  methods ZIF_CONFIRMATION_API~CANCEL_LAST
    redefinition .
  methods ZIF_CONFIRMATION_API~GET_GOODS_MOVEMENT_TABLE
    redefinition .
  PROTECTED SECTION.

    DATA ms_key TYPE ts_pp_operation_key .

    METHODS post_time_events
        REDEFINITION .
    METHODS post_time_tickets
        REDEFINITION .
private section.

  methods GET_GOODS_MOVEMENT_TE_PROP
    exporting
      !ET_GOODS_MOVEMENT type BAPI2017_GM_ITEM_CREATE_T
      !ET_LINK_CONF_GOODSMOV type BAPI_LINK_CONF_GOODSMOV_TT
    changing
      !CT_TIMEEVENTS type BAPI_PP_TIMEEVENT_T .
ENDCLASS.

CLASS ZCL_OP_PRODO_CONF_API IMPLEMENTATION.

  METHOD zif_confirmation_api~get_goods_movement_table.

    DATA(lr_last) = get_last( ).

    IF lr_last->get_ticket( )-recordtype CA  zif_confirmation=>co_time_event_record_types.
      DATA: ls_timeevent  TYPE bapi_pp_timeevent.
      DATA: lt_timeevents TYPE STANDARD TABLE OF bapi_pp_timeevent.

      MOVE-CORRESPONDING lr_last->get_time_event( ) TO ls_timeevent.
      MOVE-CORRESPONDING ms_key TO ls_timeevent.

      APPEND ls_timeevent TO lt_timeevents.

      get_goods_movement_te_prop( IMPORTING et_goods_movement     = et_goods_movement
                                            et_link_conf_goodsmov = et_link_conf_goodsmov
                                  CHANGING  ct_timeevents          = lt_timeevents ).

    ELSEIF lr_last->get_ticket( )-recordtype CA  zif_confirmation=>co_time_ticket_record_types.

      DATA: ls_propose     TYPE  bapi_pp_conf_prop,
            ls_timeticket  TYPE bapi_pp_timeticket,
            lt_timetickets TYPE STANDARD TABLE OF bapi_pp_timeticket.

      ls_propose-goodsmovement = abap_true.

      MOVE-CORRESPONDING lr_last->get_time_ticket( ) TO ls_timeticket.
      MOVE-CORRESPONDING ms_key TO ls_timeticket.
      APPEND ls_timeticket TO lt_timetickets.

      CALL FUNCTION 'BAPI_PRODORDCONF_GET_TT_PROP'  "#EC CI_USAGE_OK[2438131]
        EXPORTING
          propose            = ls_propose
        TABLES
          timetickets        = lt_timetickets
          goodsmovements     = et_goods_movement
          link_conf_goodsmov = et_link_conf_goodsmov
        .

    ENDIF.
  ENDMETHOD.

  METHOD get_goods_movement_te_prop.
    DATA: lt_afrud_tab      TYPE TABLE OF afrud INITIAL SIZE 0,
          ls_afrud          TYPE afrud,
          ls_timeevent      TYPE bapi_pp_timeevent,
          lt_imseg_tab      TYPE TABLE OF imseg INITIAL SIZE 0,
          lt_detail_ret     TYPE TABLE OF bapi_coru_return,
          ls_return         TYPE bapiret1,
          ls_goods_movement TYPE bapi2017_gm_item_create,
          lt_link           TYPE TABLE OF bapi_link_conf_goodsmov.

    CLEAR: et_goods_movement,
           et_link_conf_goodsmov.

    LOOP AT ct_timeevents INTO ls_timeevent.
      CLEAR ls_afrud.
      CALL FUNCTION 'MAP2I_PP_TIMEEVENT_TO_AFRUD' "#EC CI_SUBRC
        EXPORTING
          bapi_pp_timeevent         = ls_timeevent
        CHANGING
          afrud                     = ls_afrud
        EXCEPTIONS
          error_converting_iso_code = 1
          OTHERS                    = 2.
      APPEND ls_afrud TO lt_afrud_tab.
    ENDLOOP.

    CALL FUNCTION 'CO_RI_TIMEEVENTCONF_CREATE' "#EC CI_USAGE_OK[2438006]
      EXPORTING
        order_category     = zcl_order_prodo=>co_autyp-prodo
        prop_conf          = abap_false
        prop_gmov          = abap_true
      IMPORTING
        return             = ls_return
      TABLES
        timeevents         = lt_afrud_tab
        goodsmovements     = lt_imseg_tab
        link_conf_goodsmov = et_link_conf_goodsmov
        detail_return      = lt_detail_ret.

    CHECK ls_return IS INITIAL.

    CLEAR ct_timeevents.

    LOOP AT lt_afrud_tab INTO ls_afrud.
      CALL FUNCTION 'MAP2E_AFRUD_TO_PP_TIMEEVENT'
        EXPORTING
          afrud             = ls_afrud
        CHANGING
          bapi_pp_timeevent = ls_timeevent.
      APPEND ls_timeevent TO ct_timeevents.
    ENDLOOP.

    LOOP AT lt_imseg_tab INTO DATA(ls_imseg_tab).
*     store reference index for dependent goods movements
      LOOP AT lt_link ASSIGNING FIELD-SYMBOL(<ls_link_conf>) WHERE index_goodsmov = sy-tabix.
        <ls_link_conf>-index_gm_depend = ls_imseg_tab-refix.
      ENDLOOP.
      CLEAR ls_goods_movement.
      CALL FUNCTION 'MP2E_IMSEG_TO_2017_ITEM_CREATE' "#EC CI_USAGE_OK[2438006]
        EXPORTING
          imseg                        = ls_imseg_tab
        CHANGING
          bapi2017_gm_item_create      = ls_goods_movement
        EXCEPTIONS
          error_converting_iso_code    = 1
          error_converting_keys        = 2
          error_converting_curr_amount = 3
          error_converting_network     = 4
          OTHERS                       = 5.

      APPEND ls_goods_movement TO et_goods_movement.
    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ir_operation ).
    ms_key-conf_no   = ir_operation->ms_afvgd-rueck.
    ms_key-orderid   = ir_operation->mr_order->ms_caufvd-aufnr.
    ms_key-sequence  = ir_operation->ms_afvgd-aplfl.
    ms_key-work_cntr = ir_operation->ms_afvgd-arbpl.
    ms_key-operation = ir_operation->ms_afvgd-vornr.
    ms_key-sub_oper  = ir_operation->ms_afvgd-uvorn.
  ENDMETHOD.

  METHOD post_time_tickets.
    rr_msg = NEW #( ).

    DATA: ls_return      TYPE bapiret1,
          lt_timetickets TYPE TABLE OF bapi_pp_timeticket,
          ls_timeticket  TYPE bapi_pp_timeticket.
    DATA lt_detail_return TYPE TABLE OF bapi_coru_return.

    LOOP AT mt_confirmation INTO DATA(ls_confirmation) WHERE new = abap_true
                                                         AND recordtype CA zif_confirmation=>co_time_ticket_record_types.
      MOVE-CORRESPONDING ls_confirmation-record->get_time_ticket( ) TO ls_timeticket.
      MOVE-CORRESPONDING ms_key TO ls_timeticket.
      APPEND ls_timeticket TO lt_timetickets.
    ENDLOOP.

    CHECK lt_timetickets IS NOT INITIAL.

    get_goods_movement_table( IMPORTING et_goods_movement     = DATA(lt_goodsmovements)
                                        et_link_conf_goodsmov = DATA(lt_link_conf_goodsmov) ).

    CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT' "#EC CI_USAGE_OK[2438131]
      EXPORTING
        post_wrong_entries = '2'
      IMPORTING
        return             = ls_return
      TABLES
        timetickets        = lt_timetickets
        goodsmovements     = lt_goodsmovements
        link_conf_goodsmov = lt_link_conf_goodsmov
       DETAIL_RETURN      = lt_detail_return
      .

    IF ls_return-type = zcl_msg=>co_error.
      LOOP AT lt_detail_return ASSIGNING FIELD-SYMBOL(<ls_detail>).
        rr_msg->set( mid = <ls_detail>-id
                     num = <ls_detail>-number
                     pa1 = <ls_detail>-message_v1
                     pa2 = <ls_detail>-message_v2
                     pa3 = <ls_detail>-message_v3
                     pa4 = <ls_detail>-message_v4
                     typ = <ls_detail>-type ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD zif_confirmation_api~cancel_last.
    DATA(lr_confirmation) = get_last( if_pernr ).
    DATA(ls_afrud) = lr_confirmation->get_afrud_entry( ).

    DATA: ls_return      TYPE bapiret1,
          ls_return_comm TYPE bapiret2,
          lf_locked      TYPE ru_locked.

    CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
      EXPORTING
        confirmation        = ls_afrud-rueck
        confirmationcounter = ls_afrud-rmzhl
      IMPORTING
        return              = ls_return
        locked              = lf_locked.

    IF lf_locked = abap_true.
      MESSAGE i999(z_core)  WITH 'Auftrag gesperrt! Stornierung nicht erfolgreich'(021) DISPLAY LIKE 'E'.
    ENDIF.
    IF ls_return-type NE 'S' AND ls_return-type IS NOT INITIAL.
      MESSAGE i999(z_core) WITH 'Fehler in der Stornierung.'(022) DISPLAY LIKE 'E'.
    ENDIF.

*if the last confirmation is Final variable activity then also cancel the penultimeate confirmation
*#if it is a processing finish time event
    IF ls_afrud-satza = lr_confirmation->co_time_event-finish_variable_activity.
      DATA(lf_conf_index) = lines( mt_confirmation ).

      CHECK ls_afrud-satza EQ lr_confirmation->co_time_event-processing_finish.

      CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
        EXPORTING
          confirmation        = ls_afrud-rueck
          confirmationcounter = ls_afrud-rmzhl
        IMPORTING
          return              = ls_return
          locked              = lf_locked.
    ENDIF.
    MESSAGE i999(z_core) WITH 'Letzte Buchung wurde erfolgreich storniert.'(023).
  ENDMETHOD.

  METHOD post_time_events.
    rr_msg = NEW #( ).

    DATA: lt_return     TYPE TABLE OF bapi_coru_return,
          lt_timeevents TYPE TABLE OF bapi_pp_timeevent,
          ls_timeevent  TYPE bapi_pp_timeevent.

    LOOP AT mt_confirmation INTO DATA(ls_confirmation) WHERE new = abap_true
                                                         AND recordtype CA zif_confirmation=>co_time_event_record_types.
      MOVE-CORRESPONDING ls_confirmation-record->get_time_event( ) TO ls_timeevent.
      MOVE-CORRESPONDING ms_key TO ls_timeevent.
      APPEND ls_timeevent TO lt_timeevents.
    ENDLOOP.

    CHECK lt_timeevents IS NOT INITIAL.

    get_goods_movement_table( IMPORTING et_goods_movement     = DATA(lt_goodsmovements)
                                        et_link_conf_goodsmov = DATA(lt_link_conf_goodsmov) ).

    CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TE'
      EXPORTING
        post_wrong_entries = '2' "Fehlerhafte Rückmeldungen und Rückmeldungen,die aufgrund einer Sperrsituation nicht bearbeitet werden können
      TABLES
        timeevents         = lt_timeevents
        goodsmovements     = lt_goodsmovements  "#EC CI_USAGE_OK[2438131]
        link_conf_goodsmov = lt_link_conf_goodsmov
        detail_return      = lt_return.

    READ TABLE lt_return WITH KEY type = rr_msg->co_error TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
    ENDIF.
    LOOP AT lt_return INTO DATA(ls_return).
      rr_msg->set( mid = ls_return-id
                   num = ls_return-number
                   pa1 = ls_return-message
                   typ = ls_return-type ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
