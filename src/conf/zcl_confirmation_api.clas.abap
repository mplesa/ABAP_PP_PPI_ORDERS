CLASS zcl_confirmation_api DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_confirmation_api .

    ALIASES post
      FOR zif_confirmation_api~post .
    ALIASES refresh
      FOR zif_confirmation_api~refresh .
    ALIASES ts_confirmation
      FOR zif_confirmation_api~ts_confirmation .
    ALIASES tt_confirmation_sort
      FOR zif_confirmation_api~tt_confirmation_sort .
    ALIASES tt_pernr
      FOR zif_confirmation_api~tt_pernr .

    METHODS constructor
      IMPORTING
        !if_rueck TYPE co_rueck .
    CLASS-METHODS operation_factory
      IMPORTING
        !ir_operation TYPE REF TO zif_operation
      RETURNING
        VALUE(rr_api) TYPE REF TO zif_confirmation_api .
    CLASS-METHODS order_factory
      IMPORTING
        !ir_order     TYPE REF TO zif_order
      RETURNING
        VALUE(rr_api) TYPE REF TO zif_confirmation_api .
  PROTECTED SECTION.

    DATA mt_confirmation TYPE tt_confirmation_sort .
    DATA mf_rueck TYPE co_rueck .

    METHODS post_time_events
      ABSTRACT
      RETURNING
        VALUE(rr_msg) TYPE REF TO zcl_msg .
    METHODS post_time_tickets
      ABSTRACT
      RETURNING
        VALUE(rr_msg) TYPE REF TO zcl_msg .
  PRIVATE SECTION.

    ALIASES get_last
      FOR zif_confirmation_api~get_last .
    ALIASES get_last_not_cancelled
      for zif_confirmation_api~get_last_not_cancelled .
    METHODS build_not_cancelled_conf_table
      RETURNING VALUE(rt_confirmation) TYPE tt_confirmation_sort .
    METHODS build_confirmation_table .
ENDCLASS.

CLASS ZCL_CONFIRMATION_API IMPLEMENTATION.

  METHOD zif_confirmation_api~get_afrud_table.
    CLEAR et_afrud.
    LOOP AT mt_confirmation INTO DATA(ls_confirmation).
      APPEND ls_confirmation-record->get_afrud_entry( ) TO et_afrud.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_confirmation_api~refresh.
    build_confirmation_table( ).
  ENDMETHOD.

  METHOD zif_confirmation_api~cancel_last.
    DATA(lr_confirmation) = get_last( if_pernr ).
  ENDMETHOD.

  METHOD zif_confirmation_api~get_goods_movement_table.
  ENDMETHOD.

  METHOD zif_confirmation_api~get_last.
    IF if_pernr IS INITIAL.
      DATA(lf_last_index) = lines( mt_confirmation ).
      READ TABLE mt_confirmation INTO DATA(ls_last) INDEX lf_last_index.
      rr_last = ls_last-record.
    ELSE.
      DATA(lt_confirmation) = mt_confirmation.
      DELETE lt_confirmation WHERE pernr <> if_pernr.
      lf_last_index = lines( lt_confirmation ).
      READ TABLE lt_confirmation INTO ls_last INDEX lf_last_index.
      rr_last = ls_last-record.
    ENDIF.
  ENDMETHOD.

  METHOD zif_confirmation_api~get_last_not_cancelled.
    DATA(lt_confirmation) = build_not_cancelled_conf_table(  ).
    IF if_pernr IS INITIAL.
      DATA(lf_last_index) = lines( lt_confirmation ).
      READ TABLE lt_confirmation INTO DATA(ls_last) INDEX lf_last_index.
      rr_last = ls_last-record.
    ELSE.
      DELETE lt_confirmation WHERE pernr <> if_pernr.
      lf_last_index = lines( lt_confirmation ).
      READ TABLE lt_confirmation INTO ls_last INDEX lf_last_index.
      rr_last = ls_last-record.
    ENDIF.
  ENDMETHOD.

    METHOD build_not_cancelled_conf_table.
    DATA: lt_afrud        TYPE TABLE OF afrud,
          lt_afru_pre_tab TYPE TABLE OF rueck_pre,
          ls_confirmation TYPE ts_confirmation.

    APPEND INITIAL LINE TO lt_afru_pre_tab REFERENCE INTO DATA(lr_afru_pre).
    lr_afru_pre->rueck = mf_rueck.
    CALL FUNCTION 'CO_RU_BT_AFRU_PRE_READ'
      TABLES
        afru_pre_tab = lt_afru_pre_tab.

    CALL FUNCTION 'CO_RU_BT_AFRUD_OF_BT_GET'
      TABLES
        confirmations = lt_afrud
      EXCEPTIONS
        not_found     = 1
        OTHERS        = 2.
    CHECK sy-subrc = 0.
    DELETE lt_afrud WHERE rueck <> mf_rueck.
    DELETE lt_afrud WHERE stzhl is not initial or stokz = 'X'.
    LOOP AT lt_afrud REFERENCE INTO DATA(lr_afrud).
      ls_confirmation-counter    = lr_afrud->rmzhl.
      ls_confirmation-recordtype = lr_afrud->satza.
      ls_confirmation-pernr      = lr_afrud->pernr.
      ls_confirmation-record     = NEW zcl_confirmation( ).
      ls_confirmation-record->set_afrud( lr_afrud->* ).
      INSERT ls_confirmation INTO TABLE rt_confirmation.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_confirmation_api~post.
    DATA: ls_return TYPE bapiret2,
          lt_return TYPE bapiret2_t.
    rr_msg = NEW #( ).

    rr_msg->append( post_time_tickets( ) ).

    rr_msg->append( post_time_events( ) ).

    IF if_commit_work = abap_true.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = if_wait
        IMPORTING
          return = ls_return.
      APPEND ls_return TO lt_return.
      rr_msg->add_bapiret2_tab( lt_return ).

      build_confirmation_table( ).

    ENDIF.
  ENDMETHOD.

  METHOD zif_confirmation_api~get_active_pernr_table.
    CLEAR et_pernr.
    LOOP AT mt_confirmation INTO DATA(ls_confirmation) WHERE pernr IS NOT INITIAL.
      COLLECT ls_confirmation-pernr INTO et_pernr.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_confirmation_api~get_time_ticket_proposal.
  ENDMETHOD.

  METHOD zif_confirmation_api~get_time_event_proposal.
  ENDMETHOD.

  METHOD zif_confirmation_api~create_time_ticket.
    DATA: ls_confirmation TYPE ts_confirmation.

    ls_confirmation-new        = abap_true.
    ls_confirmation-recordtype = is_time_ticket-ticket-recordtype.
    ls_confirmation-pernr      = is_time_ticket-ticket-pers_no.
    DATA(lr_confirmation) = get_last( ).
    IF lr_confirmation IS BOUND.
      ls_confirmation-counter = get_last( )->get_afrud_entry( )-rmzhl + 1.
    ELSE.
      ls_confirmation-counter = 1.
    ENDIF.

    ls_confirmation-record     = NEW zcl_confirmation( ).
    ls_confirmation-record->set_time_ticket( is_time_ticket ).
    INSERT ls_confirmation INTO TABLE mt_confirmation.

    rr_confirmation = ls_confirmation-record.
  ENDMETHOD.

  METHOD zif_confirmation_api~create_time_event.
    DATA: ls_confirmation TYPE ts_confirmation.

    ls_confirmation-new        = abap_true.
    ls_confirmation-recordtype = is_time_event-ticket-recordtype.
    ls_confirmation-pernr      = is_time_event-ticket-pers_no.
    DATA(lr_confirmation) = get_last( ).
    IF lr_confirmation IS BOUND.
      ls_confirmation-counter = get_last( )->get_afrud_entry( )-rmzhl + 1.
    ELSE.
      ls_confirmation-counter = 1.
    ENDIF.
    ls_confirmation-record     = NEW zcl_confirmation( ).
    ls_confirmation-record->set_time_event( is_time_event ).
    INSERT ls_confirmation INTO TABLE mt_confirmation.

    rr_confirmation = ls_confirmation-record.

  ENDMETHOD.

  METHOD build_confirmation_table.
    DATA: lt_afrud        TYPE TABLE OF afrud,
          lt_afru_pre_tab TYPE TABLE OF rueck_pre,
          ls_confirmation TYPE ts_confirmation.

    CLEAR mt_confirmation.

    APPEND INITIAL LINE TO lt_afru_pre_tab REFERENCE INTO DATA(lr_afru_pre).
    lr_afru_pre->rueck = mf_rueck.
    CALL FUNCTION 'CO_RU_BT_AFRU_PRE_READ'
      TABLES
        afru_pre_tab = lt_afru_pre_tab.

    CALL FUNCTION 'CO_RU_BT_AFRUD_OF_BT_GET'
      TABLES
        confirmations = lt_afrud
      EXCEPTIONS
        not_found     = 1
        OTHERS        = 2.
    CHECK sy-subrc = 0.
    DELETE lt_afrud WHERE rueck <> mf_rueck.
    LOOP AT lt_afrud REFERENCE INTO DATA(lr_afrud).
      ls_confirmation-counter    = lr_afrud->rmzhl.
      ls_confirmation-recordtype = lr_afrud->satza.
      ls_confirmation-pernr      = lr_afrud->pernr.
      ls_confirmation-record     = NEW zcl_confirmation( ).
      ls_confirmation-record->set_afrud( lr_afrud->* ).
      INSERT ls_confirmation INTO TABLE mt_confirmation.
    ENDLOOP.

  ENDMETHOD.

  METHOD constructor.
    mf_rueck = if_rueck.
    build_confirmation_table( ).
  ENDMETHOD.

  METHOD operation_factory.
    CASE ir_operation->mr_order->ms_caufvd-autyp.
      WHEN zif_order=>co_autyp-prodo.
        rr_api = NEW zcl_op_prodo_conf_api( ir_operation ).
      WHEN zif_order=>co_autyp-process.
        rr_api = NEW zcl_op_pcess_conf_api( ir_operation ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD order_factory.
  CASE ir_order->ms_caufvd-autyp.
    WHEN zif_order=>co_autyp-prodo.
      rr_api = NEW zcl_or_prodo_conf_api( ir_order ).
    WHEN zif_order=>co_autyp-process.
      rr_api = NEW zcl_or_pcess_conf_api( ir_order ).
    WHEN OTHERS.
  ENDCASE.
  ENDMETHOD.
ENDCLASS.
