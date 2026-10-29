class ZCL_OPERATION definition
  public
  create protected

  global friends ZIF_ORDER .

public section.
  type-pools ABAP .

  interfaces ZIF_AMOUNTS .
  interfaces ZIF_LONG_TEXT .
  interfaces ZIF_JSTATUS .
  interfaces ZIF_OPERATION .

  aliases MF_VORNR
    for ZIF_OPERATION~MF_VORNR .
  aliases MR_ORDER
    for ZIF_OPERATION~MR_ORDER .
  aliases MR_SEQUANCE
    for ZIF_OPERATION~MR_SEQUANCE .
  aliases MR_WORKCENTER
    for ZIF_OPERATION~MR_WORKCENTER .
  aliases MS_AFVGD
    for ZIF_OPERATION~MS_AFVGD .
  aliases MT_FHM
    for ZIF_OPERATION~MT_FHM .
  aliases MT_KBED
    for ZIF_OPERATION~MT_KBED .
  aliases MT_STATUSES
    for ZIF_OPERATION~MT_STATUSES .
  aliases BTAB_AFVGD_UPDATE_MAIN
    for ZIF_OPERATION~BTAB_AFVGD_UPDATE_MAIN .
  aliases CHANGE_STANDARD_VALUE
    for ZIF_OPERATION~CHANGE_STANDARD_VALUE .
  aliases CHANGE_STANDARD_VALUES
    for ZIF_OPERATION~CHANGE_STANDARD_VALUES .
  aliases CHANGE_STANDARD_VALUES_DIALOG
    for ZIF_OPERATION~CHANGE_STANDARD_VALUES_DIALOG .
  aliases CHANGE_WORKCENTER
    for ZIF_OPERATION~CHANGE_WORKCENTER .
  aliases DEALLOCATE
    for ZIF_OPERATION~DEALLOCATE .
  aliases DIALOG
    for ZIF_OPERATION~DIALOG .
  aliases DISPATCH_MIDPOINT
    for ZIF_OPERATION~DISPATCH_MIDPOINT .
  aliases DISPLAY_LONG_TEXT
    for ZIF_OPERATION~DISPLAY_LONG_TEXT .
  aliases EDIT_LONG_TEXT
    for ZIF_OPERATION~EDIT_LONG_TEXT .
  aliases GET_CONFIRMATION_API
    for ZIF_OPERATION~GET_CONFIRMATION_API .
  aliases GET_EARLIEST_END
    for ZIF_OPERATION~GET_EARLIEST_END .
  aliases GET_EARLIEST_START
    for ZIF_OPERATION~GET_EARLIEST_START .
  aliases GET_FIRST_PRODUCTION_AID
    for ZIF_OPERATION~GET_FIRST_PRODUCTION_AID .
  aliases GET_LATEST_END
    for ZIF_OPERATION~GET_LATEST_END .
  aliases GET_LATEST_START
    for ZIF_OPERATION~GET_LATEST_START .
  aliases GET_PREDECESSOR
    for ZIF_OPERATION~GET_PREDECESSOR .
  aliases GET_SUCCESSOR
    for ZIF_OPERATION~GET_SUCCESSOR .
  aliases GET_VERIDS_FOR_WORKCENTER
    for ZIF_OPERATION~GET_VERIDS_FOR_WORKCENTER .
  aliases HAS_LONG_TEXT
    for ZIF_OPERATION~HAS_LONG_TEXT .
  aliases HAS_STATUS
    for ZIF_OPERATION~HAS_STATUS .
  aliases IS_DELIVERY_OPERATION
    for ZIF_OPERATION~IS_DELIVERY_OPERATION .
  aliases IS_MAIN_OPERATION
    for ZIF_OPERATION~IS_MAIN_OPERATION .
  aliases MESSAGE_TAB_STORE
    for ZIF_OPERATION~MESSAGE_TAB_STORE .
  aliases MIDPOINT_SCHEDULE
    for ZIF_OPERATION~MIDPOINT_SCHEDULE .
  aliases REFRESH
    for ZIF_OPERATION~REFRESH .
  aliases RELEASE
    for ZIF_OPERATION~RELEASE .
  aliases REMOVE_STATUS
    for ZIF_OPERATION~REMOVE_STATUS .
  aliases SCHEDULE
    for ZIF_OPERATION~SCHEDULE .
  aliases SET_STATUS
    for ZIF_OPERATION~SET_STATUS .
  aliases UPDATE_SUBOBJECTS
    for ZIF_OPERATION~UPDATE_SUBOBJECTS .

  methods CONSTRUCTOR
    importing
      !IR_ORDER type ref to ZIF_ORDER
      !IS_AFVGD type AFVGD .
  class-methods FACTORY
    importing
      !IR_ORDER type ref to ZIF_ORDER
      !IS_AFVGD type AFVGD
    returning
      value(RR_OPERATION) type ref to ZCL_OPERATION .
  methods SET_AFVGD
    importing
      !IS_AFVGD type AFVGD
    returning
      value(ER_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  PROTECTED SECTION.

    DATA mr_confirmation_api TYPE REF TO zif_confirmation_api .

    METHODS filter_production_aids
      CHANGING
        !ct_fhm TYPE zif_order=>tt_fhm .
    METHODS read_afvgd .
    METHODS read_demand .
    METHODS read_statuses .
    METHODS read_fhm .
    METHODS get_midpoint_schedule_protocol
      RETURNING
        VALUE(rr_protocol) TYPE REF TO zcl_msg .
    METHODS check_standard_values
      CHANGING
        !cs_afvgd          TYPE afvgd
      RETURNING
        VALUE(er_protocol) TYPE REF TO zcl_msg
      RAISING
        zcx_core .
private section.
ENDCLASS.

CLASS ZCL_OPERATION IMPLEMENTATION.

  METHOD zif_amounts~get.
    rf_amount = ms_afvgd-mgvrg.
  ENDMETHOD.

  METHOD zif_amounts~get_gross.
    rf_amount = ms_afvgd-mgvrg.
  ENDMETHOD.

  METHOD zif_amounts~get_net.
    rf_amount = ms_afvgd-mgvrg - ms_afvgd-lmnga.
    IF rf_amount < 0.
      rf_amount = 0.
    ENDIF.
  ENDMETHOD.

  METHOD zif_amounts~get_open.
    rf_amount =  ms_afvgd-mgvrg - ms_afvgd-lmnga - ms_afvgd-xmnga.
    IF rf_amount < 0.
      rf_amount = 0.
    ENDIF.
  ENDMETHOD.

  METHOD zif_amounts~get_unit.
    rf_unit = ms_afvgd-meinh.
  ENDMETHOD.

  METHOD zif_jstatus~get_status_text.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        flg_user_stat = 'X'
        objnr         = ms_afvgd-objnr
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

    mr_order->start_update( ).

*#remove the Operation Status
    CALL FUNCTION 'STATUS_RESET_INTERN'
      EXPORTING
        iv_objnr            = ms_afvgd-objnr
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

    mr_order->start_update( ).

*#set the Operation Status
    CALL FUNCTION 'STATUS_SET_INTERN'
      EXPORTING
        iv_objnr            = ms_afvgd-objnr
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
    DATA: ls_rc27i  TYPE rc27i,
          lf_action TYPE ttxct-function.

    CHECK sy-batch IS INITIAL.

    CALL FUNCTION 'CO_BT_AFVG_READ_WITH_APLZL'
      EXPORTING
        aplzl     = ms_afvgd-aplzl
        aufnr_act = mr_order->ms_caufvd-aufnr
      IMPORTING
        index     = ls_rc27i-index_plpo
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RETURN.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'CO_TX_PROCESSING'
      EXPORTING
        aktyp         = 'A'
        autyp         = mr_order->ms_caufvd-autyp
        ktsch_old     = ms_afvgd-ktsch
        object        = 'O'
        rc27i_new     = ls_rc27i
        rc27i_old     = ls_rc27i
      IMPORTING
        action        = lf_action
        afvgd_exp     = ms_afvgd
      EXCEPTIONS
        kein_langtext = 1
        OTHERS        = 2.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD zif_long_text~edit.
    DATA: ls_rc27i  TYPE rc27i,
          lf_action TYPE ttxct-function.

    CHECK sy-batch IS INITIAL.
    mr_order->start_update( ).

    CALL FUNCTION 'CO_BT_AFVG_READ_WITH_APLZL'
      EXPORTING
        aplzl     = ms_afvgd-aplzl
        aufnr_act = mr_order->ms_caufvd-aufnr
      IMPORTING
        index     = ls_rc27i-index_plpo
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RETURN.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'CO_TX_PROCESSING'    "#EC CI_SUBRC
      EXPORTING
        aktyp         = 'V'
        autyp         = mr_order->ms_caufvd-autyp
        ktsch_old     = ms_afvgd-ktsch
        object        = 'O'
        rc27i_new     = ls_rc27i
        rc27i_old     = ls_rc27i
      IMPORTING
        action        = lf_action
        afvgd_exp     = ms_afvgd
      EXCEPTIONS
        kein_langtext = 1
        OTHERS        = 2.
    IF sy-subrc = 0.
      CASE lf_action.
        WHEN 'D'
          OR 'U'
          OR 'I'.
          DATA(lr_msg) = set_afvgd( ms_afvgd ).
          IF lr_msg IS BOUND.
            lr_msg->show( ).
          ENDIF.
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD zif_long_text~has_long_text.
    IF ms_afvgd-ltxa1 IS NOT INITIAL.
      rf_answer = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~change_standard_value.
    DATA: lf_fieldname   TYPE string,
          ls_rcr01       TYPE rcr01,
          lf_numc13      TYPE numc13,
          lf_char1       TYPE char64,
          lf_char2       TYPE char64,
          lf_vgwrt_old   TYPE vgwrt,
          lf_vgwrteh_old TYPE vgwrteh,
          lf_vgw_old     TYPE symsgv,
          lf_vgw_new     TYPE symsgv.

    FIELD-SYMBOLS <lf_vgwrt> TYPE vgwrt.
    FIELD-SYMBOLS <lf_vgwrteh> TYPE vgwrteh.
    FIELD-SYMBOLS <lf_vgtxt> TYPE rcr01-vgt01.

    mr_order->start_update( ).

    CONCATENATE 'VGW'
                if_no
           INTO lf_fieldname.
    ASSIGN COMPONENT lf_fieldname OF STRUCTURE ms_afvgd TO <lf_vgwrt>. "<lf_field>.
    IF sy-subrc <> 0.
      CONCATENATE 'VGW0'
                  if_no
             INTO lf_fieldname.
      ASSIGN COMPONENT lf_fieldname OF STRUCTURE ms_afvgd TO <lf_vgwrt>. "<lf_field>.
    ENDIF.
    lf_vgwrt_old = <lf_vgwrt>. "<lf_field>.
    <lf_vgwrt> = if_value. "<lf_field> =
    CONCATENATE 'VGE'
                if_no
           INTO lf_fieldname.
    ASSIGN COMPONENT lf_fieldname OF STRUCTURE ms_afvgd TO <lf_vgwrteh>. "<lf_field>.
    IF sy-subrc <> 0.
      CONCATENATE 'VGE0'
                  if_no
             INTO lf_fieldname.
      ASSIGN COMPONENT lf_fieldname OF STRUCTURE ms_afvgd TO <lf_vgwrteh>. "<lf_field>.
    ENDIF.
    lf_vgwrteh_old = <lf_vgwrteh>. "<lf_field>.
    <lf_vgwrteh> = if_unit.

    DATA(lr_msg) = set_afvgd( ms_afvgd ).

    mr_order->schedule( ).

*#write a protocol
    rr_protocol = NEW zcl_msg( mid =  'Z_CORE' )."#EC_NO_TEXT
    IF lr_msg IS BOUND.
      rr_protocol->append( lr_msg ).
    ENDIF.

    CALL FUNCTION 'CO_CHK_WORKSTATION'
      EXPORTING
        afvgd_imp        = ms_afvgd
        caufvd_imp       = mr_order->ms_caufvd
      IMPORTING
        rcr01_exp        = ls_rcr01
      EXCEPTIONS
        not_found        = 1
        type_not_allowed = 2
        OTHERS           = 3.
    IF sy-subrc = 0.
*#get the name of the standard value that has been changed
      UNASSIGN <lf_vgtxt>. "<lf_field>.
      CONCATENATE 'VGT'
                  if_no
             INTO lf_fieldname.
      ASSIGN COMPONENT lf_fieldname OF STRUCTURE ls_rcr01 TO <lf_vgtxt>. "<lf_field>.
      IF sy-subrc <> 0.
        CONCATENATE 'VGT0'
                    if_no
               INTO lf_fieldname.
        ASSIGN COMPONENT lf_fieldname OF STRUCTURE ls_rcr01 TO <lf_vgtxt>. "<lf_field>.
      ENDIF.
      IF <lf_vgtxt> IS ASSIGNED. "<lf_field>.
        IF ms_afvgd-phflg IS INITIAL.
          rr_protocol->set( num = '111'"Auftrag '&1'(Vorgang &2):
                            pa1 = mr_order->mf_plnid
                            pa2 = ms_afvgd-vornr ).
        ELSE.
          rr_protocol->set( num = '112'"Auftrag '&1'(Phase &2):
                            pa1 = mr_order->mf_plnid
                            pa2 = ms_afvgd-vornr ).
        ENDIF.
        WRITE lf_vgwrt_old   TO lf_numc13 UNIT if_unit.
        WRITE lf_vgwrteh_old TO lf_char2.
        CONCATENATE lf_numc13
                    lf_char2
               INTO lf_vgw_old SEPARATED BY space.
        CONDENSE lf_vgw_old.
        WRITE if_value TO lf_numc13 UNIT if_unit.
        WRITE if_unit  TO lf_char2.
        CONCATENATE lf_numc13
                    lf_char2
               INTO lf_vgw_new SEPARATED BY space.
        CONDENSE lf_vgw_new.
        rr_protocol->set( num = '114'"&1 wurde von &2 auf &3 geändert.
                          pa1 = <lf_vgtxt> "<lf_field>
                          pa2 = lf_vgw_old
                          pa3 = lf_vgw_new ).

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD zif_operation~change_standard_values.

    DATA: lf_continue TYPE flag,
          ls_afvgd    TYPE afvgd.

    mr_order->start_update( ).

    ls_afvgd = ms_afvgd.

    IF if_vgw01 IS SUPPLIED AND
       if_vge01 IS SUPPLIED.
      ls_afvgd-vgw01 = if_vgw01.
      ls_afvgd-vge01 = if_vge01.
      lf_continue = abap_true.
    ENDIF.
    IF if_vgw02 IS SUPPLIED AND
       if_vge02 IS SUPPLIED.
      ls_afvgd-vgw02 = if_vgw02.
      ls_afvgd-vge02 = if_vge02.
      lf_continue = abap_true.
    ENDIF.
    IF if_vgw03 IS SUPPLIED AND
       if_vge03 IS SUPPLIED.
      ls_afvgd-vgw03 = if_vgw03.
      ls_afvgd-vge03 = if_vge03.
      lf_continue = abap_true.
    ENDIF.
    IF if_vgw04 IS SUPPLIED AND
       if_vge04 IS SUPPLIED.
      ls_afvgd-vgw04 = if_vgw04.
      ls_afvgd-vge04 = if_vge04.
      lf_continue = abap_true.
    ENDIF.
    IF if_vgw05 IS SUPPLIED AND
       if_vge05 IS SUPPLIED.
      ls_afvgd-vgw05 = if_vgw05.
      ls_afvgd-vge05 = if_vge05.
      lf_continue = abap_true.
    ENDIF.
    IF if_vgw06 IS SUPPLIED AND
       if_vge06 IS SUPPLIED.
      ls_afvgd-vgw06 = if_vgw06.
      ls_afvgd-vge06 = if_vge06.
      lf_continue = abap_true.
    ENDIF.
    CHECK lf_continue EQ abap_true.

    TRY.
        er_protocol = set_afvgd( ls_afvgd ).
      CATCH zcx_core INTO DATA(lr_error).
        IF er_protocol IS  INITIAL.
          CREATE OBJECT er_protocol.
        ENDIF.
        er_protocol->set_exc( lr_error ).
    ENDTRY.
    mr_order->schedule( ).

  ENDMETHOD.

  METHOD zif_operation~change_standard_values_dialog.
    DATA: lr_operation TYPE REF TO zif_operation.

    CHECK sy-batch IS INITIAL.

    mr_order->start_update( ).

    TRY .
        lr_operation = mr_order->get_operation( if_vornr = ms_afvgd-vornr
                                                if_aplzl = ms_afvgd-aplzl ).

        CALL FUNCTION 'Z_STANDARD_VALUES'
          EXPORTING
            ir_operation = lr_operation.

      CATCH zcx_operation_notfound.
      CLEANUP.

    ENDTRY.

  ENDMETHOD.

  METHOD zif_operation~change_workcenter.
    DATA: ls_rcr01 TYPE rcr01.

    " Make sure we have at least an empty object to return, not nothing
    rr_protocol = NEW zcl_msg( mid = 'Z_CORE' ).
    CHECK ir_new <> mr_workcenter.

    mr_order->start_update( ).
    DATA(lr_old_workcenter) = mr_workcenter.

*#set the new workcenter
    DATA(ls_afvgd) = ms_afvgd.
    ls_afvgd-arbid = ir_new->ms_crhd-objid.
    ls_afvgd-werks = ir_new->ms_crhd-werks.
    ls_afvgd-arbpl = ir_new->ms_crhd-arbpl.
*#check if the workcenter change is allowed
    CALL FUNCTION 'CO_CHK_WORKSTATION'
      EXPORTING
        afvgd_imp        = ls_afvgd
        caufvd_imp       = mr_order->ms_caufvd
        sttag            = mr_order->ms_caufvd-aufld
      IMPORTING
        afvgd_exp        = ls_afvgd
        rcr01_exp        = ls_rcr01
      EXCEPTIONS
        not_found        = 1
        type_not_allowed = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      rr_protocol->sy_set( ).
      RETURN.
    ENDIF.
*#Einheiten für Vorgabewerte dürfen nicht überschrieben werden
    ls_afvgd-vge01 = ms_afvgd-vge01.
    ls_afvgd-vge02 = ms_afvgd-vge02.
    ls_afvgd-vge03 = ms_afvgd-vge03.
    ls_afvgd-vge04 = ms_afvgd-vge04.
    ls_afvgd-vge05 = ms_afvgd-vge05.
    ls_afvgd-vge06 = ms_afvgd-vge06.

*#Accept default values from the workcenter
    CALL FUNCTION 'CO_DI_AFVGD_RCR01_REF_FILL'
      EXPORTING
        is_caufvd    = mr_order->ms_caufvd
        afvgd_imp    = ls_afvgd
        is_afvgd_old = ms_afvgd
        autyp_imp    = mr_order->ms_caufvd-autyp
        rcr01_imp    = ls_rcr01
      IMPORTING
        afvgd_exp    = ls_afvgd.

*#Steuerschlüssel nicht ändern
    ls_afvgd-steus = ms_afvgd-steus.

*#Nominate data of the workcenter as default values
    CALL FUNCTION 'CO_DI_AFVGD_RCR01_DEF_FILL'
      EXPORTING
        afvgd_imp = ls_afvgd
        rcr01_imp = ls_rcr01
      IMPORTING
        afvgd_exp = ls_afvgd.

*#!!!This will remove Status EIGP. otherwise use SET_AFVGD()!!!
*#update buffer table of operation
    CALL FUNCTION 'CO_BT_AFVG_UPDATE' "#EC CI_USAGE_OK[2267333]
      EXPORTING
        afvgd_new = ls_afvgd
        tabix_old = ms_afvgd-indbt.

    remove_status( zif_jstatus=>co_cref ).

*#read the AFVGD again from the buffer
    read_afvgd( ).
    update_subobjects( ).

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

*#protocol
    IF ms_afvgd-phflg IS INITIAL.
      rr_protocol->set( num = '111'"Auftrag '&1'(Vorgang &2):
                        pa1 = mr_order->mf_plnid
                        pa2 = ms_afvgd-vornr ).
    ELSE.
      rr_protocol->set( num = '112'"Auftrag '&1'(Phase &2):
                        pa1 = mr_order->mf_plnid
                        pa2 = ms_afvgd-vornr ).
    ENDIF.

    rr_protocol->set( num = '113'"Arbeitsplatzwechsel von (&1) nach (&2) wurde durchgeführt.
                      pa1 = lr_old_workcenter->mf_arbpl
                      pa2 = ir_new->mf_arbpl ).

*#after workcenter change a rescheduling of the order is necesary
    me->refresh( ).
    IF if_no_order_schedule = abap_false.
      mr_order->schedule( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_operation~deallocate.
    DATA: lf_txt04 TYPE tj02t-txt04,
          lf_txt30 TYPE tj02t-txt30.

    CREATE OBJECT rr_protocol.

*#when deallocating an operation just remove the status Dispatched
    CHECK has_status( zif_jstatus=>co_dspt ) IS NOT INITIAL."EIGP
    mr_order->start_update( ).
    remove_status( zif_jstatus=>co_dspt )."EIGP

    CALL FUNCTION 'STATUS_NUMBER_CONVERSION'
      EXPORTING
        language           = sy-langu
        status_number      = zif_jstatus=>co_dspt
      IMPORTING
        txt04              = lf_txt04
        txt30              = lf_txt30
      EXCEPTIONS
        insufficient_input = 1
        object_not_found   = 2
        status_not_found   = 3
        stsma_not_found    = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      rr_protocol->sy_set( ).
    ELSE.
      rr_protocol->set( mid = 'Z_CORE'
                    num = '109'"'Auftrag '&1'/Vorgang '&2': Status &3(&4) würde entfernt.
                    pa1 = mr_order->mf_plnid
                    pa2 = mf_vornr
                    pa3 = lf_txt04
                    pa4 = lf_txt30 ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~dialog.
    TYPES: BEGIN OF ts_afvg_index.
             INCLUDE TYPE coindex.
    TYPES: END OF ts_afvg_index.
    DATA: lt_afvg_index TYPE TABLE OF ts_afvg_index,
          ls_afvg_index TYPE ts_afvg_index.
    DATA: ls_ordpar TYPE  ordpar,
          lr_exc    TYPE REF TO zcx_order_locked.

    TRY .
        mr_order->start_update( ).
        ls_ordpar-trtyp = 'V'."change operation
      CATCH zcx_order_locked INTO lr_exc.
        MESSAGE lr_exc TYPE 'S'.
        ls_ordpar-trtyp = 'A'."display operation
    ENDTRY.

    ls_ordpar-aufnr = mr_order->ms_caufvd-aufnr.
    CASE  mr_order->ms_caufvd-autyp.
* wen PPS-Fertigungsauftrag
      WHEN zif_order=>co_autyp-prodo."'10'.
        ls_ordpar-fcode    =   'ALAV'.
* wenn Netzplan
      WHEN zif_order=>co_autyp-network."'20'.
        ls_ordpar-fcode    =   'VORD'.
* wenn Instandhaltungsauftrag
      WHEN zif_order=>co_autyp-iho."'30'.
        ls_ordpar-fcode    =   'VDV '.
* wenn Prozeßauftrag
      WHEN zif_order=>co_autyp-process."'40'.
        ls_ordpar-fcode    =   'ALAV'.
* wenn Personalauftrag
      WHEN zif_order=>co_autyp-personnel."'60'.
        ls_ordpar-fcode    =   'ALAV'.

    ENDCASE.

    ls_afvg_index-index = ms_afvgd-indbt.
    APPEND ls_afvg_index TO lt_afvg_index.

    CALL FUNCTION 'CO_EXT_ORDER_ENTRY'
      EXPORTING
        ordpar_imp             = ls_ordpar
      TABLES
        opr_index_tab          = lt_afvg_index
      EXCEPTIONS
        authority_check_failed = 01
        dialog_chanceled       = 02
        enqueue_failed         = 03
        new_data_error         = 04
        not_found              = 05
        wrong_auart            = 06
        wrong_autyp            = 07
        wrong_trtyp            = 08.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

*#refresh the entire order because it is not posible to
*#se exacty what data has been changed
    mr_order->refresh( ).
  ENDMETHOD.

  METHOD zif_operation~dispatch_midpoint.
    mr_order->start_update( ).
    rr_protocol = midpoint_schedule( if_pit = if_pit
                                     if_forward = if_forward ).
  ENDMETHOD.

  METHOD zif_operation~get_confirmation_api.
    IF mr_confirmation_api IS NOT BOUND.
      mr_confirmation_api = zcl_confirmation_api=>operation_factory( me ).
    ENDIF.
    rr_confirmation_api = mr_confirmation_api.
  ENDMETHOD.

  METHOD zif_operation~get_earliest_end.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_afvgd-fseld
                                             if_time = ms_afvgd-fselz ).
  ENDMETHOD.

  METHOD zif_operation~get_earliest_start.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_afvgd-fsavd
                                             if_time = ms_afvgd-fsavz ).
  ENDMETHOD.

  METHOD zif_operation~get_first_production_aid.
    CLEAR: es_fhm.

    zif_operation~get_production_aid( IMPORTING et_fhm = DATA(lt_fhm) ).
    SORT lt_fhm BY psnfh.
    READ TABLE lt_fhm INTO es_fhm INDEX 1.

  ENDMETHOD.

  METHOD zif_operation~get_latest_end.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_afvgd-ssedd
                                             if_time = ms_afvgd-ssedz ).

  ENDMETHOD.

  METHOD zif_operation~get_latest_start.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_afvgd-ssavd
                                             if_time = ms_afvgd-ssavz ).
  ENDMETHOD.

  METHOD zif_operation~get_predecessor.

    rr_predecessor = mr_order->get_predecessor_operation( me ).

  ENDMETHOD.

  METHOD zif_operation~get_production_aid.
    CLEAR: et_fhm.
    mr_order->get_production_aids( IMPORTING et_fhm = et_fhm ).
    filter_production_aids( CHANGING ct_fhm = et_fhm ).
    LOOP AT et_fhm ASSIGNING FIELD-SYMBOL(<ls_fhm>).
      <ls_fhm>-vornr = mf_vornr.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_operation~get_successor.

    rr_successor = mr_order->get_successor_operation( me ).

  ENDMETHOD.

  METHOD zif_operation~get_verids_for_workcenter.
*#the method will give back all the MKAL enties that have
*#a work plan with the same operation number as the current
*#operation and the workcenter that is requested
    DATA: ls_mkal  TYPE mkal,
          lf_gamng TYPE gamng,
          lf_plnty TYPE plnty,
          lf_plnnr TYPE plnnr,
          lf_plnal TYPE plnal.

    mr_order->get_production_versions( IMPORTING et_mkal = et_mkal ).
    CHECK et_mkal IS NOT INITIAL.
    lf_gamng = mr_order->get_order_amount( ).

    LOOP AT et_mkal INTO ls_mkal.
*#The workplan ID is in a differnet field for Fein/Raten/Grob
      CLEAR: lf_plnty, lf_plnnr, lf_plnal.

      lf_plnty = ls_mkal-plnty.
      lf_plnnr = ls_mkal-plnnr.
      lf_plnal = ls_mkal-alnal.
      IF lf_plnty IS INITIAL.
        lf_plnty = ls_mkal-pltyg.
        lf_plnnr = ls_mkal-plnng.
        lf_plnal = ls_mkal-alnag.
      ENDIF.
      IF lf_plnty IS INITIAL.
        lf_plnty = ls_mkal-pltym.
        lf_plnnr = ls_mkal-plnnm.
        lf_plnal = ls_mkal-alnam.
      ENDIF.

      DATA(lr_rm) = zcl_routing_master=>get_instance(
                      if_plnty = lf_plnty
                      if_plnnr = lf_plnnr
                      if_plnal = lf_plnal ).
      lr_rm->get_data( IMPORTING
                         et_plko = DATA(lt_plko)
                         et_plpo = DATA(lt_plpo)
                       RECEIVING
                         rf_data_found = DATA(lf_routing_found) ).
      IF lf_routing_found = abap_false.
        "the MKAL entriy is invalid
        DELETE et_mkal.
        CONTINUE.
      ENDIF.

*#Remove invalid entries:
*#-entries that are not yet valid
      DELETE lt_plko WHERE datuv GT sy-datum.
*#-entries that have the deletion flag set
      DELETE lt_plko WHERE loekz NE space.

*#check the lot size only if MAX lot is not INITIAL.
      IF ls_mkal-bstma IS NOT INITIAL.
*#-entries thath have 'lot size from' bigger than the GAMNG
        DELETE lt_plko WHERE losvn GT lf_gamng.
*#-entries thath have 'lot size to' smaller than the GAMNG
        DELETE lt_plko WHERE losbs LT lf_gamng.
      ENDIF.

*#if no entry is found then the plan is not valid
      READ TABLE lt_plko TRANSPORTING NO FIELDS INDEX 1.
      IF sy-subrc <> 0.
        "the mkal entrie is invalid
        DELETE et_mkal.
        CONTINUE.
      ENDIF.

*#get the operation information for the work plan and new workcenter
      READ TABLE lt_plpo TRANSPORTING NO FIELDS WITH KEY wva COMPONENTS werks = ms_afvgd-werks
                                                                        vornr = ms_afvgd-vornr
                                                                        arbid = ir_workcenter->mf_arbid.
      IF sy-subrc <> 0.
        "the mkal entrie is invalid
        DELETE et_mkal.
        CONTINUE.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD zif_operation~is_delivery_operation.
    DATA ls_t430 TYPE t430.
    CALL FUNCTION 'CO_TA_T430_READ'
      EXPORTING
        steus  = ms_afvgd-steus
      IMPORTING
        struct = ls_t430
      EXCEPTIONS
        OTHERS = 0.
    IF ls_t430-autwe = abap_true.
      rf_result = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~is_main_operation.
*#should be redifined in Subclasses->PRODO/PROCESS...
    rf_answer = abap_true.
  ENDMETHOD.

  METHOD zif_operation~midpoint_schedule.

    DATA: lr_protocol TYPE REF TO zcl_msg,
          ls_cxzeit   TYPE cxzeit,
          ls_cxafvg   TYPE cxafvg_v1,
          tabix_new   TYPE sy-tabix,
          lf_error    TYPE sy-subrc.

    CHECK if_pit IS NOT INITIAL.

    mr_order->start_update( ).

    schedule( EXPORTING if_forward = if_forward
                        if_pit     = if_pit
              CHANGING  cs_afvgd   = ms_afvgd ).

    btab_afvgd_update_main(  EXPORTING if_forward = if_forward
                                       if_simple = space
                             CHANGING  cs_afvgd = ms_afvgd
                                       cf_tabix_new = ms_afvgd-indbt ).

*#set the Operation Status Dispatched
    set_status( zif_jstatus=>co_dspt )."'EIGP'

*#-reschedule the entire order whit the new dispatched operation
*#-this will perform the actual midpoint scheduling of the order
*#-here all the orders operations will refresh their information
    rr_protocol = mr_order->schedule( ).
    lr_protocol = get_midpoint_schedule_protocol( ).
    rr_protocol->append( lr_protocol ).
  ENDMETHOD.

  METHOD zif_operation~refresh.
    read_afvgd( ).
    read_statuses( ).
    read_demand( ).
  ENDMETHOD.

  METHOD zif_operation~release.
    CONSTANTS co_trtyp_change TYPE c LENGTH 1 VALUE 'V'.
    DATA lt_msgprot TYPE TABLE OF cmfmsg.
    DATA lf_num     TYPE sy-msgno.

    DATA(lr_msg) = zcl_msg=>evaluate_object( ir_msg ).

*# Check if the operation is already released
    IF has_status( zif_jstatus=>co_free ) = abap_true.
      MESSAGE ID 'Z_CORE'
              TYPE zcl_msg=>co_info
              NUMBER 639
              WITH |{ mr_order->mf_plnid ALPHA = OUT }| |{ ms_afvgd-aplfl ALPHA = OUT }| mf_vornr
              INTO DATA(lf_msg_dummy).
      lr_msg->sy_set( ).
      RETURN.
    ENDIF.

    DATA(lf_fre) = mr_order->has_status( zif_jstatus=>co_free ).
    DATA(lf_tfr) = mr_order->has_status( zif_jstatus=>co_trel ).

*# Release the operation
    CALL FUNCTION 'CO_ZR_OPERATION_RELEASE'
      EXPORTING
        afvgd_imp   = ms_afvgd
        caufvd_imp  = mr_order->ms_caufvd
        flg_fre     = lf_fre
        flg_tfr     = lf_tfr
        trtyp       = co_trtyp_change
      EXCEPTIONS
        free_failed = 1
        OTHERS      = 2.
    IF sy-subrc = 0.
      MESSAGE ID 'Z_CORE'
              TYPE zcl_msg=>co_success
              NUMBER 640
              WITH |{ mr_order->mf_plnid ALPHA = OUT }| |{ ms_afvgd-aplfl ALPHA = OUT }| mf_vornr
              INTO lf_msg_dummy.
      lr_msg->sy_set( ).
      RETURN.
    ELSE.
      lr_msg->sy_set( ).
      MESSAGE ID 'Z_CORE'
              TYPE zcl_msg=>co_error
              NUMBER 641
              WITH |{ mr_order->mf_plnid ALPHA = OUT }| |{ ms_afvgd-aplfl ALPHA = OUT }| mf_vornr
              INTO lf_msg_dummy.
      lr_msg->sy_set( ).
    ENDIF.

*# Get the protocol and put it in our message queue
    CALL FUNCTION 'CM_F_MESSAGES_GET'
      EXPORTING
        aplid     = 'PPFR'
      TABLES
        e_msgprot = lt_msgprot
      EXCEPTIONS
        OTHERS    = 0.

    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES'
      EXPORTING
        aplid  = 'PPFR'
        number = '999'
      EXCEPTIONS
        OTHERS = 0.

    LOOP AT lt_msgprot ASSIGNING FIELD-SYMBOL(<ls_msgprot>).
      lf_num = <ls_msgprot>-msgnr.
      lr_msg->set( mid = <ls_msgprot>-arbgb
                   num = lf_num
                   pa1 = <ls_msgprot>-msgv1
                   pa2 = <ls_msgprot>-msgv2
                   pa3 = <ls_msgprot>-msgv3
                   pa4 = <ls_msgprot>-msgv4
                   typ = <ls_msgprot>-msgty ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_operation~schedule.
    DATA: ls_cxzeit TYPE cxzeit,
          ls_cxafvg TYPE cxafvg_v1,
          lf_error  TYPE sy-subrc.
*#the CX data (scheduling data) must be refreshed
    CALL FUNCTION 'CX_DATA_RESET'.

    IF if_pit IS INITIAL.
      DATA(lf_pit) = zcl_pit=>get_sy_pit( ).
    ELSE.
      lf_pit = if_pit.
    ENDIF.

    IF if_forward IS NOT INITIAL.
*#forward scheduling from PIT
      ls_cxzeit-ssav = lf_pit.
    ELSE.
*#backward scheduling from PIT
      ls_cxzeit-ssed = lf_pit.
    ENDIF.

    MOVE-CORRESPONDING cs_afvgd TO ls_cxafvg.

*#schedule the operation with results in ls_cxzeit
    CALL FUNCTION 'CX_OPR_SCHEDULE'
      EXPORTING
        afvg_v1_imp          = ls_cxafvg "Planned/Production Orders
        cxzeit_imp           = ls_cxzeit
        i_flg_shift_order    = 'X' "for TRÜCK
        i_overlapped         = 'X'
        i_flg_no_calendar    = ' '
        i_flg_cap_scheduling = ' '
        i_flg_forward        = if_forward
        i_flg_protocol       = ' '
        i_flg_exact_breaks   = mr_order->ms_caufvd-breaks
        i_point_in_time      = if_pit
      IMPORTING
        cxzeit_exp           = ls_cxzeit
        e_error_code         = lf_error.
*#modify AFVGD from the scheduling results
    CALL FUNCTION 'CX_OPR_FILL_FROM_CXZEIT'
      EXPORTING
        afvgd_imp        = cs_afvgd
        cxzeit_imp       = ls_cxzeit
        i_flg_arbei      = ' '
        i_flg_forward    = 'X'
        i_flg_dates_only = ' '
      IMPORTING
        afvgd_exp        = cs_afvgd.
  ENDMETHOD.

  METHOD zif_operation~update_production_aid.

  ENDMETHOD.

  METHOD zif_operation~update_subobjects.
    mr_order->start_update( ).
    CALL FUNCTION 'CO_ZF_OPR_SUBOBJECTS_SCHEDULE' "#EC CI_SUBRC
      EXPORTING
        afvgd_imp               = ms_afvgd
        caufvd_imp              = mr_order->ms_caufvd
        i_vornr_opr_with_phases = ms_afvgd-vornr
      IMPORTING
        afvgd_exp               = ms_afvgd
      EXCEPTIONS
        itab_entry_not_found    = 1
        no_date                 = 2
        OTHERS                  = 3.
    IF sy-subrc = 0.
      mr_order->refresh( ).
    ENDIF.
  ENDMETHOD.

  METHOD check_standard_values.
    DATA: lf_dimfield TYPE fieldname,
          lf_mesfield TYPE fieldname,
          lf_parfield TYPE fieldname.

    FIELD-SYMBOLS: <lf_value> TYPE vgwrt,
                   <lf_meins> TYPE vgwrteh,
                   <lf_param> TYPE paramid,
                   <lf_dim>   TYPE dimid,
                   <lf_mes>   TYPE ap_vgw_mes.
    DATA: ls_rcr01      TYPE rcr01,
          ls_afvgd      TYPE afvgd,
          lf_suffix     TYPE numc1,
          lf_vfield     TYPE fieldname,
          lf_efield     TYPE fieldname,
          lf_name_field TYPE fieldname,
          lf_dummy      TYPE c,
          lf_val1       TYPE text50,
          lf_val2       TYPE text50.

    FIELD-SYMBOLS: <lf_val_new>   TYPE vgwrt,
                   <lf_val_old>   TYPE vgwrt,
                   <lf_val_org>   TYPE vgwrt,
                   <lf_meins_new> TYPE vgwrteh,
                   <lf_meins_old> TYPE vgwrteh,
                   <lf_meins_org> TYPE vgwrteh,
                   <lf_name>      TYPE paraltxt.

    CALL FUNCTION 'CO_CHK_WORKSTATION'
      EXPORTING
        afvgd_imp        = ms_afvgd
        caufvd_imp       = mr_order->ms_caufvd
      IMPORTING
        rcr01_exp        = ls_rcr01
      EXCEPTIONS
        not_found        = 1
        type_not_allowed = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      CLEAR: ls_rcr01.
    ENDIF.

    ls_afvgd = cs_afvgd.
    CALL FUNCTION 'CO_VC_AFVG_RCR01_CHANGE_CHK'
      EXPORTING
        afvgd_new_imp = ls_afvgd
        afvgd_old_imp = ms_afvgd
        rcr01_new_imp = ls_rcr01
        rcr01_old_imp = ls_rcr01
      IMPORTING
        afvgd_new_exp = cs_afvgd.
    CREATE OBJECT er_protocol.
    DO 6 TIMES.

      DATA(lf_tabix) = sy-index.

      lf_suffix = lf_tabix.

      CONCATENATE 'VGW0' lf_suffix INTO lf_vfield.
      CONCATENATE 'VGE0' lf_suffix INTO lf_efield.
      CONCATENATE 'VGM0' lf_suffix INTO lf_mesfield.
      CONCATENATE 'VGD0' lf_suffix INTO lf_dimfield.
      CONCATENATE 'PAR0' lf_suffix INTO lf_parfield.

      ASSIGN COMPONENT lf_vfield   OF STRUCTURE cs_afvgd TO <lf_value>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_efield   OF STRUCTURE cs_afvgd TO <lf_meins>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_mesfield OF STRUCTURE ls_rcr01 TO <lf_mes>.
      ASSIGN COMPONENT lf_parfield OF STRUCTURE ls_rcr01 TO <lf_param>.
      ASSIGN COMPONENT lf_dimfield OF STRUCTURE ls_rcr01 TO <lf_dim>.
      CALL FUNCTION 'CO_VC_CHK_AFVG_RCR01_VORGWERT'
        EXPORTING
          parid         = <lf_param>
          vgwdi         = <lf_dim>
          vgwei         = <lf_meins>
          vgwrt         = <lf_value>
          vgwst         = <lf_mes>
          vgwnr         = lf_tabix
        EXCEPTIONS
          error_message = 1.
      IF sy-subrc <> 0.
        er_protocol->sy_set( ).
        CONCATENATE 'VGTL' lf_suffix INTO lf_name_field.
        ASSIGN COMPONENT lf_name_field OF STRUCTURE ls_rcr01 TO <lf_name>.
        RAISE EXCEPTION TYPE zcx_op_invalid_default
          EXPORTING
            value_description = <lf_name>.
      ENDIF.

      CONCATENATE 'VGW0' lf_suffix INTO lf_vfield.
      CONCATENATE 'VGE0' lf_suffix INTO lf_efield.
      ASSIGN COMPONENT lf_vfield OF STRUCTURE cs_afvgd TO <lf_val_new>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_vfield OF STRUCTURE ls_afvgd TO <lf_val_old>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_vfield OF STRUCTURE ms_afvgd TO <lf_val_org>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_efield OF STRUCTURE cs_afvgd TO <lf_meins_new>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_efield OF STRUCTURE ls_afvgd TO <lf_meins_old>. "#EC CI_FLDEXT_OK[2215424]
      ASSIGN COMPONENT lf_efield OF STRUCTURE ms_afvgd TO <lf_meins_org>. "#EC CI_FLDEXT_OK[2215424]
      IF <lf_val_new> <> <lf_val_old>
        OR <lf_meins_new> <> <lf_meins_old>.
        CONCATENATE 'VGTL' lf_suffix INTO lf_name_field.
        ASSIGN COMPONENT lf_name_field OF STRUCTURE ls_rcr01 TO <lf_name>.
        IF <lf_val_new> = <lf_val_org>
          AND <lf_meins_new> = <lf_meins_org>.
          MESSAGE s115(z_core) INTO lf_dummy WITH <lf_name>.
          er_protocol->sy_set( ).
          RAISE EXCEPTION TYPE zcx_op_invalid_default
            EXPORTING
              value_description = <lf_name>.
        ELSE.
          WRITE <lf_val_old> TO lf_val1 LEFT-JUSTIFIED ##UOM_IN_MES.
          SHIFT  lf_val1 LEFT DELETING LEADING space.
          CONCATENATE lf_val1 <lf_meins_old> INTO lf_val1.
          CONCATENATE lf_val2 <lf_meins_new> INTO lf_val2.
          WRITE <lf_val_new> TO lf_val2 LEFT-JUSTIFIED ##UOM_IN_MES.
          SHIFT  lf_val2 LEFT DELETING LEADING space.
          MESSAGE s114(z_core) INTO lf_dummy WITH <lf_name> lf_val1 lf_val2.
          er_protocol->sy_set( ).
        ENDIF.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD constructor.
    mr_order = ir_order.
    ms_afvgd = is_afvgd.
    mf_vornr = ms_afvgd-vornr.
    read_statuses( ).
    read_demand( ).
    mr_workcenter = zcl_arbid=>get_instance( ms_afvgd-arbid ).
    READ TABLE mr_order->mt_operation_sequances INTO mr_sequance WITH KEY table_line->ms_affl-plnfl = ms_afvgd-aplfl.
  ENDMETHOD.

  METHOD factory.
    CASE ir_order->mf_sart.
      WHEN zif_core_constants=>co_sart-plano.
        CREATE OBJECT rr_operation TYPE zcl_operation_plano
          EXPORTING
            ir_order = ir_order
            is_afvgd = is_afvgd.
      WHEN zif_core_constants=>co_sart-process.
        CREATE OBJECT rr_operation TYPE zcl_operation_process
          EXPORTING
            ir_order = ir_order
            is_afvgd = is_afvgd.
      WHEN zif_core_constants=>co_sart-iho.
        CREATE OBJECT rr_operation TYPE zcl_operation_ih
          EXPORTING
            ir_order = ir_order
            is_afvgd = is_afvgd.
      WHEN zif_core_constants=>co_sart-network.
        CREATE OBJECT rr_operation TYPE zcl_operation_netwk
          EXPORTING
            ir_order = ir_order
            is_afvgd = is_afvgd.
      WHEN OTHERS.
        CREATE OBJECT rr_operation TYPE zcl_operation_prodo
          EXPORTING
            ir_order = ir_order
            is_afvgd = is_afvgd.
    ENDCASE.
  ENDMETHOD.

  METHOD filter_production_aids.
  ENDMETHOD.

  METHOD get_midpoint_schedule_protocol.

*#should only be called after order->schedule( ).
    rr_protocol = NEW zcl_msg( ).

*#check conflicts with successors and predecesors
    DATA: lr_operation TYPE REF TO zif_operation.

*#get operation PoinInTime start
    DATA(lf_pit_start) = get_latest_start( ).
*#get operation PoinInTime end
    DATA(lf_pit_end) = get_latest_end( ).

*#predecessor:
    lr_operation ?= me.
    DO.
      TRY .
          lr_operation = lr_operation->get_predecessor( ).
*#get successor PoinInTime end
          DATA(lf_pit) = lr_operation->get_latest_end( ).
*# |--------PREDECESSOR-------| PIT
*#               PIT_START |##---------OPERATION---------|

          IF lf_pit > lf_pit_start.
            rr_protocol->set( mid = 'Z_CORE'
                              num = '003'"Terminkonflikt: Überschneidung mit vorgänger Vorgang '&1'.
                              pa1 = lr_operation->mf_vornr
                              typ = rr_protocol->co_warning ).
          ENDIF.
          EXIT."only the first predecessor
        CATCH zcx_no_predecessor.
          EXIT.
      ENDTRY.
    ENDDO.

*#successors:
    lr_operation ?= me.
    DO.
      TRY .
          lr_operation = lr_operation->get_successor( ).
*#get successor PoinInTime start
          lf_pit = lr_operation->get_latest_start( ).
*#                      PIT  |--------SUCCESSOR-------|
*# |----------OPERATION-------##| PIT_END
          IF lf_pit < lf_pit_end.
            rr_protocol->set( mid = 'Z_CORE'
                              num = '004'"Terminkonflikt: Überschneidung mit nachfolger Vorgang '&1'.
                              pa1 = lr_operation->mf_vornr
                              typ = rr_protocol->co_warning ).
          ENDIF.
          EXIT."only the first successor
        CATCH zcx_no_successor.
          EXIT.
      ENDTRY.
    ENDDO.

  ENDMETHOD.

  METHOD read_afvgd.
    CALL FUNCTION 'CO_BT_AFVG_READ_WITH_APLZL'
      EXPORTING
        aplzl     = ms_afvgd-aplzl
        aufnr_act = mr_order->ms_caufvd-aufnr
        aufpl     = mr_order->ms_caufvd-aufpl
        flg_conv  = 'X'
        flg_work  = 'X'
      IMPORTING
        afvgd_exp = ms_afvgd
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    DATA(lf_arbid) = ms_afvgd-arbid.

*#if the workcenter has changed then also change the
*#workcenter object
    IF mr_workcenter->ms_crhd-objid <> lf_arbid.
      mr_workcenter = zcl_arbid=>get_instance( lf_arbid ).
      ms_afvgd-arbpl = mr_workcenter->ms_crhd-arbpl.
      ms_afvgd-werks = mr_workcenter->mr_werks->mf_werks.
    ENDIF.
  ENDMETHOD.

  METHOD read_demand.
*#this method will read the demand of a order operation in the MT_KBED atributte
    CALL FUNCTION 'CY_BT_KBED_OPR_TAB_GET'
      EXPORTING
        i_aufnr  = mr_order->ms_caufvd-aufnr
        i_bedid  = ms_afvgd-bedid
        i_bedzl  = ms_afvgd-bedzl
      TABLES
        t_kbedd  = mt_kbed
      EXCEPTIONS
        no_entry = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.

*#if the demand is not found for an operation then it may be posible that we are
*#dealing with a newly created planned order that still does not have the BEDID
*#transfered to in the AFVGD structure
      DATA: lf_bedid TYPE bedid,
            lr_plano TYPE REF TO zcl_order_plano.
      TRY .
          lr_plano ?= mr_order.
          lf_bedid = lr_plano->get_bedid_from_plaf( lr_plano->ms_plaf ).
          CALL FUNCTION 'CY_BT_KBED_OPR_TAB_GET'    "#EC CI_SUBRC
            EXPORTING
              i_aufnr = mr_order->ms_caufvd-aufnr
              i_bedid = lf_bedid
              i_bedzl = ms_afvgd-bedzl
            TABLES
              t_kbedd = mt_kbed
            EXCEPTIONS
              OTHERS  = 0.

        CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDIF.
    DATA: lt_kbed TYPE TABLE OF kbedd.

    LOOP AT mr_order->mt_afvgd_sub ASSIGNING FIELD-SYMBOL(<ls_afvgd_sub>)
      USING KEY primary_key
      WHERE sumnr = ms_afvgd-aplzl
        AND arbid = ms_afvgd-arbid.
      CLEAR: lt_kbed.
      CALL FUNCTION 'CY_BT_KBED_OPR_TAB_GET'
        EXPORTING
          i_aufnr  = mr_order->ms_caufvd-aufnr
          i_bedid  = <ls_afvgd_sub>-bedid
          i_bedzl  = <ls_afvgd_sub>-bedzl
        TABLES
          t_kbedd  = lt_kbed
        EXCEPTIONS
          no_entry = 1
          OTHERS   = 2.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      APPEND LINES OF lt_kbed TO mt_kbed.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_fhm.
*# Die Unterscheidung des Lesevorgangs wurde verlagert:
*# Die FHM werden vom Auftrag gelesen. Die Filterung der FHM zum Vorgang erfolgt
*# in den abgeleiteten Klassen des Vorgangs.
*#++++++++  MT_FHM wird nicht mehr gefüllt ++++++++++++++
    DATA: lt_plfh TYPE TABLE OF plfh,
          ls_fhm  TYPE affhd,
          lt_plpo TYPE TABLE OF coplpo,
          ls_affh TYPE affh.
    DATA: ls_tca11 TYPE tca11.

    IF mr_order->mf_sart <> zif_core_constants=>co_sart-plano.

      CALL FUNCTION 'CF_BT_CO_AFFHD_TAB_GET'
        EXPORTING
          i_aufpl           = ms_afvgd-aufpl
          i_aplzl           = ms_afvgd-aplzl
          i_no_deleted      = 'X'
          i_no_phys_deleted = 'X'
          i_flg_statx       = 'X'
        TABLES
          affhd_tab         = mt_fhm
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.
      IF sy-subrc <> 0 OR mt_fhm IS INITIAL.
        RETURN.
      ENDIF.
    ELSE."other way for planned orders
      "Planned orders do not have a AFFH entry so we half to build one from the Plan PLFH
      ls_tca11-flg_alt  = abap_true.
      ls_tca11-flg_fhm  = abap_true.
      CALL FUNCTION 'CP_EX_PLAN_READ'
        EXPORTING
          plnty_imp     = mr_order->ms_caufvd-plnty
          plnnr_imp     = mr_order->ms_caufvd-plnnr
          plnal_imp     = mr_order->ms_caufvd-plnal
          sttag_imp     = mr_order->ms_caufvd-plauf
          tca11_imp     = ls_tca11
        TABLES
          plfh_exp      = lt_plfh
          plpo_exp      = lt_plpo "is not optional
        EXCEPTIONS
          not_found     = 1
          plnal_initial = 2
          OTHERS        = 3.
      CHECK sy-subrc = 0.
*#Find the PLFH that are linked to the Operation
      DELETE lt_plfh WHERE plnkn <>  ms_afvgd-plnkn.

      LOOP AT lt_plfh INTO DATA(ls_plfh).
        CLEAR: ls_fhm, ls_affh.

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
          APPEND ls_fhm TO mt_fhm.
        ENDIF.
      ENDLOOP.

    ENDIF.

    SORT mt_fhm BY psnfh ASCENDING datui DESCENDING.

*#the field FHMAR   represents the Fertigungshilfsmittel-Art
*#the field FHMNR   represents the Fertigungshilfsmittel Nr.
*#the field FHWRK   represents the Fertigungshilfsmittel Werk
*#the field FHKTX   represents the Fertigungshilfsmittel Text
*#the field MGSOL   represents the Fertigungshilfsmittel Gesamte Menge
*#the field MGSOLEH represents the Fertigungshilfsmittel Einheit Menge
  ENDMETHOD.

  METHOD read_statuses.
*#read Operation Statuses
*#all needed status constants are here---->LCOKOSTA
    CLEAR mt_statuses.
    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        objnr       = ms_afvgd-objnr
        only_active = abap_true
      TABLES
        status      = mt_statuses
      EXCEPTIONS
        OTHERS      = 0.

  ENDMETHOD.

  METHOD set_afvgd.
    DATA(ls_afvgd) = is_afvgd.
    er_protocol = check_standard_values( CHANGING cs_afvgd = ls_afvgd ).
    mr_order->start_update( ).

    CALL FUNCTION 'CO_BT_AFVG_UPDATE' "#EC CI_USAGE_OK[2267333]
      EXPORTING
        afvgd_new      = ls_afvgd
        tabix_old      = ms_afvgd-indbt
        flg_no_dealloc = 'X'
      IMPORTING
        tabix_new      = ms_afvgd-indbt.

*#operations that have the Status EIGP must be redispatched
    IF has_status( zif_jstatus=>co_dspt ) IS NOT INITIAL.
      DATA(lf_pit) = zcl_pit=>convert_date_time( if_date = ms_afvgd-ssavd
                                                     if_time = ms_afvgd-ssavz ).
      read_afvgd( ).

      dispatch_midpoint( lf_pit ).
    ENDIF.

    mr_order->schedule( ).
  ENDMETHOD.

  METHOD zif_operation~get_total_activities.
    DATA:
      ls_acties        TYPE afvc_acties, "Geplante Leistungsarten
      ls_planned_activ TYPE ttl_activ, "Geplante Leistungen
      ls_conf_activ    TYPE ttl_activ. "Bereits rückgemeldete Leistungen
    DATA:
      lf_ism TYPE afvgd-ism01,
      lf_ile TYPE afvgd-ile01,
      lf_lek TYPE afvgd-lek01,
      lf_act TYPE ttl_activ-acti1,
      lf_uni TYPE ttl_activ-unit1,
      lf_nrm TYPE ttl_activ-nact1.
    DATA:
      lf_defstunde   TYPE t006-msehi,
      lf_defminute   TYPE t006-msehi,
      lf_zeiteinheit TYPE t006-msehi,
      lf_smeng       TYPE ru_smeng.   "Zeiteinheit für Rückmeldung

    lf_smeng = ms_afvgd-mgvrg.

    "for process orders, only determine activities for phases and for secondary resources
    IF mr_order->ms_caufvd-autyp NE mr_order->co_autyp-process
      OR ms_afvgd-sumnr IS NOT INITIAL
      OR ms_afvgd-phflg IS NOT INITIAL.

      "Minuten und Stundene definieren
      CALL FUNCTION 'TIME_UNITS'
        IMPORTING
          minute          = lf_defminute
          hour            = lf_defstunde
        EXCEPTIONS
          si_unit_missing = 1.
      IF sy-subrc <> 0.
        MESSAGE s747(cp). "Einheit in Tabelle T006 ist nicht gepflegt
        RETURN.
      ENDIF.

      CLEAR lf_zeiteinheit. "vorerst immer ohne Zeiteinheit - Babel

* Eingestellte Ausgabeart der Zeiteinheit ermitteln.
      SELECT SINGLE zestd, zemin
        FROM tcoru INTO @DATA(ls_tcoru)
        WHERE werks = @mr_order->ms_caufvd-werks
          AND auart = @mr_order->ms_caufvd-auart.
      IF sy-subrc <> 0.
        MESSAGE s010(ru) WITH mr_order->ms_caufvd-werks mr_order->ms_caufvd-auart. "Zum Werk & Auftragsart & sind keine Parameter definiert
        CLEAR ls_tcoru.
      ENDIF.
      IF NOT ls_tcoru-zestd IS INITIAL.
        lf_zeiteinheit = lf_defstunde.
      ENDIF.
      IF NOT ls_tcoru-zemin IS INITIAL.
        lf_zeiteinheit = lf_defminute.
      ENDIF.

* Leistungen ermitteln
      CALL FUNCTION 'CO_R0_DET_TOTAL_ACTIVITY'
        EXPORTING
          act_afvgd        = ms_afvgd
          act_quantity     = lf_smeng
          act_unit_of_time = lf_zeiteinheit
        IMPORTING
          exp_activities   = ls_planned_activ.
* geplante Leistungsarten bereitstellen
      MOVE-CORRESPONDING ms_afvgd TO ls_acties.
* bereits rückgemeldete Leistungen bereitstellen
      CLEAR ls_conf_activ.
      DO 6 TIMES VARYING lf_ism FROM ms_afvgd-ism01
                                NEXT ms_afvgd-ism02
                 VARYING lf_ile FROM ms_afvgd-ile01
                                NEXT ms_afvgd-ile02
                 VARYING lf_lek FROM ms_afvgd-lek01
                                NEXT ms_afvgd-lek02
                 VARYING lf_act FROM ls_conf_activ-acti1
                                NEXT ls_conf_activ-acti2
                 VARYING lf_uni FROM ls_conf_activ-unit1
                                NEXT ls_conf_activ-unit2
                 VARYING lf_nrm FROM ls_conf_activ-nact1
                                NEXT ls_conf_activ-nact2.
        lf_act = lf_ism.
        lf_uni = lf_ile.
        lf_nrm = lf_lek.
      ENDDO.

    ELSE. "Leistungen für Vorgaenge in Prozessauftraegen initialisieren
      CLEAR: ls_planned_activ, ls_conf_activ.
    ENDIF.

    "Tabelle mit Leistungsdaten des Vorgangs aufbauen
    CALL FUNCTION 'CO_R0_CREATE_ACTIVITY_TAB'
      EXPORTING
        i_arbid            = ms_afvgd-arbid
        i_datum            = sy-datum
        is_acties          = ls_acties
        is_confirmed_activ = ls_conf_activ
        is_planned_activ   = ls_planned_activ
      TABLES
        et_activ           = rt_ectivities.
  ENDMETHOD.

  METHOD zif_operation~btab_afvgd_update_main.
    DATA: v1 TYPE cmimsg-msgv1,
          v2 TYPE cmimsg-msgv2,
          v3 TYPE cmimsg-msgv3,
          v4 TYPE cmimsg-msgv4.

    DATA: no_banf      TYPE sy-datar VALUE ' ',
          pauf_exp     TYPE cyrefs-flag,
          lf_vornr0    TYPE afvgd-vornr VALUE '0000',
          ls_msg       TYPE z_operation_msg,
          lf_flg_fixed TYPE c.

* CXZEIT_MAINOPR ist schon in OPR_IN übertragen.
    IF NOT if_forward IS INITIAL.
*   Forward
      IF if_simple IS INITIAL.
*     Normal scheduling
        cs_afvgd-epanf = cs_afvgd-ssavd.
        cs_afvgd-epanz = cs_afvgd-ssavz.

        IF mr_order->ms_caufvd-flg_aob IS INITIAL.
*       PP: EPEND not used
          CLEAR cs_afvgd-epend.
          CLEAR cs_afvgd-epenz.
        ELSE.
*       Networks: EPEND needed
          cs_afvgd-epend = cs_afvgd-ssedd.
          cs_afvgd-epenz = cs_afvgd-ssedz.
        ENDIF.
      ELSE.
*     Simple sequencing
        cs_afvgd-epanf = cs_afvgd-ssedd.
        cs_afvgd-epanz = cs_afvgd-ssedz.

        IF mr_order->ms_caufvd-flg_aob IS INITIAL.
*       PP: EPANF, EPEND not used
          CLEAR cs_afvgd-epend.
          CLEAR cs_afvgd-epenz.
        ELSE.
*       Networks: EPANF, EPEND needed
          cs_afvgd-epend = cs_afvgd-ssedd.
          cs_afvgd-epenz = cs_afvgd-ssedz.
        ENDIF.
      ENDIF.
    ELSE.
*   Backward
      IF if_simple IS INITIAL.
*     Normal scheduling
        cs_afvgd-epend = cs_afvgd-ssedd.
        cs_afvgd-epenz = cs_afvgd-ssedz.

        IF mr_order->ms_caufvd-flg_aob IS INITIAL.
*       PP: EPANF not used
          CLEAR cs_afvgd-epanf.
          CLEAR cs_afvgd-epanz.
        ELSE.
*       Networks: EPANF needed
          cs_afvgd-epanf = cs_afvgd-ssavd.
          cs_afvgd-epanz = cs_afvgd-ssavz.
        ENDIF.
      ELSE.
*     Simple sequencing
        cs_afvgd-epend = cs_afvgd-ssavd.
        cs_afvgd-epenz = cs_afvgd-ssavz.
        IF mr_order->ms_caufvd-flg_aob IS INITIAL.
*       PP: EPANF not used
          CLEAR cs_afvgd-epanf.
          CLEAR cs_afvgd-epanz.
        ELSE.
*       Networks: EPANF needed
          cs_afvgd-epanf = cs_afvgd-ssavd.
          cs_afvgd-epanz = cs_afvgd-ssavz.
        ENDIF.
      ENDIF.
    ENDIF.
* Anforderung der PS Terminierung: Prognosetermine nicht mehr löschen
* Puffer löschen.
    CLEAR cs_afvgd-puffr.
    CLEAR cs_afvgd-pufgs.
* Bei Arbeitsplatzwechsel Rueckmelde-Vorschlagsarbeitsplatz loeschen
    IF cs_afvgd-arbid <> zif_operation~ms_akt_opr_sav-arbid.
      CLEAR cs_afvgd-arbii.
    ENDIF.
    CALL FUNCTION 'CY01_PLANNED_ORDER_CHECK'
      EXPORTING
        aufnr_imp               = cs_afvgd-aufnrd
        check_only_imp          = 'X'
      IMPORTING
        pauf_exp                = pauf_exp
      EXCEPTIONS
        no_order_identification = 1
        OTHERS                  = 2.
* Keine BANF-Verarbeitung für Planufträge
    IF sy-subrc = 0 AND NOT pauf_exp IS INITIAL.
      no_banf = 'X'.
    ENDIF.
* Update auf Hauptvorgang
    CALL FUNCTION 'CO_BT_AFVG_UPDATE'
      EXPORTING
        afvgd_new          = cs_afvgd
        flg_no_sched       = ' '
        flg_no_uvo_upd     = 'X'
        flg_no_dealloc     = 'X'
        tabix_old          = cs_afvgd-indbt
        flg_no_rec_process = no_banf
      IMPORTING
        tabix_new          = cf_tabix_new.
* Erfolgsmeldung
    IF lf_flg_fixed IS INITIAL.
      IF cs_afvgd-phflg IS INITIAL.
        v1 = ls_msg-aufnr.
        v2 = cs_afvgd-vornr.
        v3 = cs_afvgd-arbpl.
        message_tab_store(  EXPORTING if_vorn2 = lf_vornr0
                                      if_msgno = '732'
                                      if_msgty = zif_operation~con_msgty_success
                                      if_msgv1 = v1
                                      if_msgv2 = v2
                                      if_msgv3 = v3
                                      if_msgv4 = space
                                      is_msg = ls_msg
                                      ).
      ELSE.
        v1 = ls_msg-aufnr.
        v2 = cs_afvgd-vornr.
        message_tab_store(  EXPORTING if_vorn2 = lf_vornr0
                                    if_msgno = '718'
                                     if_msgty = zif_operation~con_msgty_success
                                     if_msgv1 = v1
                                     if_msgv2 = v2
                                     if_msgv3 = space
                                     if_msgv4 = space
                                     is_msg = ls_msg
                                     ).
      ENDIF.
    ENDIF.
    WRITE cs_afvgd-ssavd TO v1 DD/MM/YYYY.
    WRITE cs_afvgd-ssavz TO v2 USING EDIT MASK '__:__:__'.
    WRITE cs_afvgd-ssedd TO v3 DD/MM/YYYY.
    WRITE cs_afvgd-ssedz TO v4 USING EDIT MASK '__:__:__'.
    IF lf_flg_fixed IS INITIAL.
      message_tab_store(  EXPORTING if_vorn2 = lf_vornr0
                                   if_msgno = '734'
                                    if_msgty = zif_operation~con_msgty_success
                                    if_msgv1 = v1
                                    if_msgv2 = v2
                                    if_msgv3 = v3
                                    if_msgv4 = v4
                                    is_msg = ls_msg
                                    ).
    ENDIF.
    CHECK cs_afvgd-phflg IS INITIAL.
    IF cs_afvgd-arbid <> zif_operation~ms_akt_opr_sav-arbid.
      IF zif_operation~ms_akt_opr_sav-arbpl IS INITIAL.
        CALL FUNCTION 'CR_WORKSTATION_READ'
          EXPORTING
            id        = zif_operation~ms_akt_opr_sav-arbid
          IMPORTING
            arbpl     = zif_operation~ms_akt_opr_sav-arbpl
          EXCEPTIONS
            not_found = 01.
      ENDIF.

      v1 = ls_msg-aufnr.
      v2 = cs_afvgd-vornr.
      v3 = zif_operation~ms_akt_opr_sav-arbpl.
      v4 = cs_afvgd-arbpl.
      message_tab_store(  EXPORTING if_vorn2 = lf_vornr0
                                if_msgno = '746'
                                 if_msgty = zif_operation~con_msgty_info
                                 if_msgv1 = v1
                                 if_msgv2 = v2
                                 if_msgv3 = v3
                                 if_msgv4 = v4
                                 is_msg = ls_msg
                                 ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_operation~message_tab_store.

    DATA: reduce_messages TYPE c,
          lf_msgty        TYPE cmimsg-msgty,
          lf_msgno        TYPE cmimsg-msgnr,
          lf_msgv1        TYPE string,
          lf_msgv2        TYPE string,
          lf_msgv3        TYPE string,
          lf_msgv4        TYPE string.

    GET PARAMETER ID 'CY"' FIELD reduce_messages.

    CHECK reduce_messages <> 'N'.
    CHECK reduce_messages IS INITIAL OR
          if_msgty = zif_operation~con_msgty_warning  OR
          if_msgty = zif_operation~con_msgty_error.

    lf_msgty = if_msgty.
    lf_msgno = if_msgno.
    lf_msgv1 = if_msgv1.
    lf_msgv2 = if_msgv2.
    lf_msgv3 = if_msgv3.
    lf_msgv4 = if_msgv4.

    CALL FUNCTION 'CX_F_SET_OBJECT'
      EXPORTING
        i_aufnr = is_msg-aufnr
        i_dispo = ' '
        i_fevor = ' '
        i_folge = is_msg-folge
        i_vorn2 = if_vorn2
        i_vornr = is_msg-vornr.
    CALL FUNCTION 'CX_F_MESSAGE'
      EXPORTING
        i_flg_message   = 'X'
        i_arbgb         = is_msg-arbgb
        i_msgty         = lf_msgty
        i_msgnr         = lf_msgno
        i_msgv1         = lf_msgv1
        i_msgv2         = lf_msgv2
        i_msgv3         = lf_msgv3
        i_msgv4         = lf_msgv4
        i_msg_code      = 0
        i_msg_on_screen = ' '.
  ENDMETHOD.
ENDCLASS.
