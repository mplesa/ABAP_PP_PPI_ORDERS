class ZCL_OPERATION_PROCESS definition
  public
  inheriting from ZCL_OPERATION
  create public .

public section.

  methods ZIF_OPERATION~CHANGE_STANDARD_VALUE
    redefinition .
  methods ZIF_OPERATION~CHANGE_STANDARD_VALUES_DIALOG
    redefinition .
  methods ZIF_OPERATION~CHANGE_WORKCENTER
    redefinition .
  methods ZIF_OPERATION~DEALLOCATE
    redefinition .
  methods ZIF_OPERATION~GET_EARLIEST_END
    redefinition .
  methods ZIF_OPERATION~GET_LATEST_END
    redefinition .
  methods ZIF_OPERATION~IS_MAIN_OPERATION
    redefinition .
  methods ZIF_OPERATION~MIDPOINT_SCHEDULE
    redefinition .
  methods ZIF_OPERATION~RELEASE
    redefinition .
  methods ZIF_OPERATION~SCHEDULE
    redefinition .
  methods ZIF_OPERATION~UPDATE_SUBOBJECTS
    redefinition .
  methods SET_AFVGD
    redefinition .
protected section.

  methods GET_MIDPOINT_SCHEDULE_PROTOCOL
    redefinition .
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_OPERATION_PROCESS IMPLEMENTATION.

  METHOD zif_operation~change_standard_value.
    DATA: lr_operation TYPE REF TO zif_operation.
*#by proccess orders do not allows standard value changes to the main
*#operation. If the client tries to change the standard values of the
*#main operation then get the first phase of the operation and change
*#the values of the phase
    IF is_main_operation( ) IS INITIAL.
      rr_protocol = super->zif_operation~change_standard_value( if_no    = if_no
                                                                        if_value = if_value
                                                                        if_unit  = if_unit ).
    ELSE.
      TRY .
          lr_operation = get_successor( ).
        CATCH zcx_core.
          RETURN.
      ENDTRY.

      rr_protocol = lr_operation->change_standard_value( if_no    = if_no
                                                         if_value = if_value
                                                         if_unit  = if_unit ).

    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~change_standard_values_dialog.
    DATA: lr_operation TYPE REF TO zif_operation.
*#by proccess orders do not allows standard value changes to the main
*#operation. If the client tries to change the standard values of the
*#main operation then get the first phase of the operation and change
*#the values of the phase
    IF is_main_operation( ) IS INITIAL.
      super->zif_operation~change_standard_values_dialog( ).
    ELSE.
      TRY .
          lr_operation = get_successor( ).
        CATCH zcx_core.
          RETURN.
      ENDTRY.
      lr_operation->change_standard_values_dialog( ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~change_workcenter.
    DATA: lr_operation TYPE REF TO zif_operation,
          lr_msg       TYPE REF TO zcl_msg.

    " Make sure we have at least an empty object to return, not nothing
    rr_protocol = NEW zcl_msg( mid = 'Z_CORE' ).
    CHECK ir_new <> mr_workcenter.

    CHECK ir_new <> mr_workcenter.

    rr_protocol = super->zif_operation~change_workcenter( ir_new = ir_new
                                                                  if_no_order_schedule = if_no_order_schedule ).

    CASE ms_afvgd-phflg.
      WHEN abap_false."main opeation
*#in case the operation is a parent operation then change the workcenter for all its phases
        LOOP AT mr_order->mt_operations INTO lr_operation WHERE table_line->ms_afvgd-pvzkn = ms_afvgd-aplzl
                                                            AND table_line->ms_afvgd-phflg IS NOT INITIAL.
          lr_msg = lr_operation->change_workcenter( ir_new = ir_new
                                                    if_no_order_schedule = if_no_order_schedule ).
          rr_protocol->append( lr_msg ).
        ENDLOOP.
      WHEN abap_true."phase
*#in case of phase find the main operation and change the workcenter from there
        READ TABLE mr_order->mt_operations INTO lr_operation WITH KEY table_line->ms_afvgd-aplzl = ms_afvgd-pvzkn.
        IF sy-subrc = 0.
          lr_msg = lr_operation->change_workcenter( ir_new = ir_new
                                                    if_no_order_schedule = if_no_order_schedule ).
          rr_protocol->append( lr_msg ).
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

  METHOD zif_operation~deallocate.
    DATA: lr_operation TYPE REF TO zif_operation,
          lr_protocol  TYPE REF TO zcl_msg.

    rr_protocol = super->zif_operation~deallocate( ).

*#make shure that all the phases of the main operation are also delocated
    LOOP AT mr_order->mt_operations INTO lr_operation WHERE table_line->ms_afvgd-pvzkn = ms_afvgd-aplzl.
      lr_protocol  = lr_operation->deallocate( ).
      rr_protocol->append( lr_protocol ).
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_operation~get_earliest_end.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_afvgd-fsedd
                                             if_time = ms_afvgd-fsedz ).
  ENDMETHOD.

  METHOD zif_operation~get_latest_end.
    rf_pit = zcl_pit=>convert_date_time( if_date = ms_afvgd-ssedd
                                             if_time = ms_afvgd-ssedz ).
  ENDMETHOD.

  METHOD zif_operation~is_main_operation.
*#for proccess orders whe have phases and parent operationss
*#a phase will not be considered a main operation
    rf_answer = super->zif_operation~is_main_operation( ).
    IF ms_afvgd-phflg IS NOT INITIAL AND
       ms_afvgd-pvzkn  IS NOT INITIAL.
      CLEAR rf_answer.
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~midpoint_schedule.
    DATA: lr_operation TYPE REF TO zif_operation.

    mr_order->start_update( ).

    read_afvgd( )."in order to have the current INDEX/INDBT

    schedule( EXPORTING if_forward          = if_forward
                        if_pit              = if_pit
              IMPORTING et_operation_phases = DATA(lt_operation_phases)
              CHANGING cs_afvgd             = ms_afvgd ).

    btab_afvgd_update_main(  EXPORTING if_forward = if_forward
                                          if_simple = space
                                CHANGING  cs_afvgd = ms_afvgd
                                          cf_tabix_new = ms_afvgd-indbt ).

*#set the Operation Status Dispatched
    set_status( zif_jstatus=>co_dspt )."'EIGP'

*#in case the operation is a parent operation then dispatch all its phases
*#the phases should be taken in correct order!!!(AOB) iss done in "GET_SUCCESSOR
    IF ms_afvgd-pvznr IS INITIAL.
      DATA(lf_pit_start) = me->get_latest_start( ).
      lr_operation ?= me.
      DO.
        TRY .
            lr_operation = lr_operation->get_successor( ).
            IF lr_operation->ms_afvgd-pvzkn NE ms_afvgd-aplzl.
              EXIT.
            ENDIF.

            READ TABLE lt_operation_phases INTO DATA(ls_phase) WITH KEY vornr = lr_operation->mf_vornr.
            IF sy-subrc = 0.
              DATA(ls_afvgd_phase) = lr_operation->ms_afvgd.
              " Converting the start dates
              zcl_pit=>convert_pit( EXPORTING if_pit       =  ls_phase-sssb
                                        IMPORTING ef_date      =  ls_afvgd_phase-ssavd
                                                  ef_time      =  ls_afvgd_phase-ssavz ).
              zcl_pit=>convert_pit( EXPORTING if_pit       =  ls_phase-fsav
                                        IMPORTING ef_date      =  ls_afvgd_phase-fsavd
                                                  ef_time      =  ls_afvgd_phase-fsavz ).
              ls_afvgd_phase-fssbd = ls_afvgd_phase-fsavd.
              ls_afvgd_phase-fssbz = ls_afvgd_phase-fsavz.
              ls_afvgd_phase-sssbd = ls_afvgd_phase-ssavd.
              ls_afvgd_phase-sssbz = ls_afvgd_phase-ssavz.
              " Converting the end dates
              zcl_pit=>convert_pit( EXPORTING if_pit       =  ls_phase-ssed
                                        IMPORTING ef_date      =  ls_afvgd_phase-ssedd
                                                  ef_time      =  ls_afvgd_phase-ssedz ).
              zcl_pit=>convert_pit( EXPORTING if_pit       =  ls_phase-fsed
                                        IMPORTING ef_date      =  ls_afvgd_phase-fsedd
                                                  ef_time      =  ls_afvgd_phase-fsedz ).
              ls_afvgd_phase-fssad = ls_afvgd_phase-fsedd.
              ls_afvgd_phase-fssaz = ls_afvgd_phase-fsedz.
              ls_afvgd_phase-sssad = ls_afvgd_phase-ssedd.
              ls_afvgd_phase-sssaz = ls_afvgd_phase-ssedz.
              ls_afvgd_phase-fssld = ls_afvgd_phase-fsedd.
              ls_afvgd_phase-fsslz = ls_afvgd_phase-fsedz.
              ls_afvgd_phase-sssld = ls_afvgd_phase-ssedd.
              ls_afvgd_phase-ssslz = ls_afvgd_phase-ssedz.
              ls_afvgd_phase-fseld = ls_afvgd_phase-fsedd.
              ls_afvgd_phase-fselz = ls_afvgd_phase-fsedz.
              ls_afvgd_phase-sseld = ls_afvgd_phase-ssedd.
              ls_afvgd_phase-sselz = ls_afvgd_phase-ssedz.

              btab_afvgd_update_main(  EXPORTING if_forward = if_forward
                                                    if_simple = space
                                          CHANGING  cs_afvgd = ls_afvgd_phase
                                                    cf_tabix_new = ls_afvgd_phase-indbt ).
              TRY.
                  lr_operation->set_status( if_status = zif_jstatus=>co_dspt )."'EIGP'.
                CATCH zcx_core.
                  CONTINUE.
              ENDTRY.
            ENDIF.

          CATCH zcx_no_successor.
            EXIT.
        ENDTRY.
      ENDDO.
    ENDIF.

*#-reschedule the entire order whit the new dispatched operation
*#-this will perform the actual midpoint scheduling of the order
*#-here all the orders operations will refresh their information
    rr_protocol = mr_order->schedule( ).
*#phases are contained within their main operation so they will
*#allways colide with their parent operation
    rr_protocol->append( get_midpoint_schedule_protocol( ) ).

  ENDMETHOD.

  METHOD zif_operation~release.
    DATA: lr_operation TYPE REF TO zif_operation.

    super->zif_operation~release( ir_msg = ir_msg ).

*#in case the operation is a parent operation then release also all its phases
    IF ms_afvgd-pvznr IS INITIAL.
      lr_operation ?= me.
      DO.
        TRY .
            lr_operation = lr_operation->get_successor( ).
            IF lr_operation->ms_afvgd-pvzkn NE ms_afvgd-aplzl.
              EXIT.
            ENDIF.

            lr_operation->release( ir_msg = ir_msg ).

          CATCH zcx_no_successor.
            EXIT.
        ENDTRY.
      ENDDO.
    ENDIF.
  ENDMETHOD.

  METHOD zif_operation~schedule.
    DATA: lf_date_start TYPE sy-datum,
          lf_time_start TYPE sy-uzeit,
          lf_date_end   TYPE sy-datum,
          lf_time_end   TYPE sy-uzeit,
          lf_pit_start  TYPE z_pit,
          lf_pit_end    TYPE z_pit,
          ls_cxzeit     TYPE cxzeit,
          ls_cxafvg     TYPE cxafvg_v1.

*#the CX data (scheduling data) must be refreshed
    CALL FUNCTION 'CX_DATA_RESET'.

*#decide on Forward or Backward scheduling
    lf_pit_start = if_pit.

    zcl_pit=>convert_pit( EXPORTING if_pit  = lf_pit_start
                              IMPORTING ef_date = lf_date_start
                                        ef_time = lf_time_start ).
    IF if_forward IS INITIAL.
      lf_date_end = lf_date_start.
      lf_time_end = lf_time_start.
      lf_pit_end  = lf_pit_start.
      CLEAR: lf_date_start, lf_time_start, lf_pit_start.
    ENDIF.

    CALL FUNCTION 'CX_OPR_AND_PHASES_SCHEDULE'
      EXPORTING
        is_caufvd           = mr_order->ms_caufvd
        is_afvgd            = cs_afvgd
        is_tcx00            = mr_order->ms_tcx00
        i_flg_dialog        = space
        i_date_start        = lf_date_start
        i_time_start        = lf_time_start
        i_date_end          = lf_date_end
        i_time_end          = lf_time_end
        i_no_update         = 'X'
      IMPORTING
        es_afvgd            = cs_afvgd
      TABLES
        et_phases           = et_operation_phases
      EXCEPTIONS
        OTHERS              = 0.

    CALL FUNCTION 'CX_SCHED_VIA_OPERATING_TIME'
      EXPORTING
        i_date_start          = lf_date_start
        i_time_start          = lf_time_start
        i_point_in_time_start = lf_pit_start
        i_date_end            = lf_date_end
        i_time_end            = lf_time_end
        i_point_in_time_end   = lf_pit_end
        i_duration            = cs_afvgd-bearz
        i_unit                = cs_afvgd-beaze
        i_arbid               = cs_afvgd-arbid
        i_flg_exact_breaks    = mr_order->ms_caufvd-breaks
        i_flg_cap_scheduling  = abap_false
        i_flg_no_calendar     = abap_false
      IMPORTING
        e_point_in_time_start = lf_pit_start
        e_point_in_time_end   = lf_pit_end.

    ls_cxzeit-fsav = lf_pit_start.        "Durchführen
    ls_cxzeit-ssav = lf_pit_start.
    ls_cxzeit-fssb = lf_pit_start.        "Bearbeiten
    ls_cxzeit-sssb = lf_pit_start.
    ls_cxzeit-fssa = lf_pit_end.          "Abrüsten
    ls_cxzeit-sssa = lf_pit_end.
    ls_cxzeit-fsed = lf_pit_end.          "Durchführen
    ls_cxzeit-ssed = lf_pit_end.
    ls_cxzeit-fssl = lf_pit_end.          "Liegen
    ls_cxzeit-sssl = lf_pit_end.
    ls_cxzeit-fsel = lf_pit_end.
    ls_cxzeit-ssel = lf_pit_end.

    ls_cxzeit-beaze = cs_afvgd-beaze.

*#modify AFVGD from the scheduling results
    CALL FUNCTION 'CX_OPR_FILL_FROM_CXZEIT'
      EXPORTING
        afvgd_imp        = cs_afvgd
        cxzeit_imp       = ls_cxzeit
        i_flg_arbei      = abap_false
        i_flg_forward    = abap_true
        i_flg_dates_only = abap_true
      IMPORTING
        afvgd_exp        = cs_afvgd.

  ENDMETHOD.

  METHOD zif_operation~update_subobjects.
    mr_order->start_update( ).

    DATA(lf_vornr) = ms_afvgd-vornr.
*#in case of phases the VORNR must point to the MAIN operation
    IF is_main_operation( ) IS INITIAL.
      READ TABLE mr_order->mt_operations INTO DATA(lr_operation) WITH KEY table_line->ms_afvgd-aplzl = ms_afvgd-pvzkn.
      IF sy-subrc = 0.
        lf_vornr = lr_operation->mf_vornr.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'CO_ZF_OPR_SUBOBJECTS_SCHEDULE' "#EC CI_SUBRC
      EXPORTING
        afvgd_imp               = ms_afvgd
        caufvd_imp              = mr_order->ms_caufvd
        i_vornr_opr_with_phases = lf_vornr
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

  METHOD get_midpoint_schedule_protocol.
    rr_protocol = NEW zcl_msg( ).

*#check conflicts with successor and predecesor not needed

*#for proccess orders the parent operation will contain the start of
*#the first phase and the end of the last phase
  ENDMETHOD.

  METHOD set_afvgd.
    DATA: ls_rcrop     TYPE rcrop,
          ls_rcrvgw    TYPE rcrvgw,
          ls_cxzeit    TYPE cxzeit,
          lr_operation TYPE REF TO zif_operation.

    mr_order->start_update( ).

    DATA(ls_afvgd) = is_afvgd.
    er_protocol = check_standard_values( CHANGING cs_afvgd = ls_afvgd ).

*#in case the standard values changed then the operation duration must be recalculated
    MOVE-CORRESPONDING ls_afvgd TO ls_rcrop.
    MOVE-CORRESPONDING ls_afvgd TO ls_rcrvgw.

    CALL FUNCTION 'CR_WORKCENTER_FORMULA_TERM'
      EXPORTING
        arbid       = ls_afvgd-arbid
        date        = ls_afvgd-fsavd
        op          = ls_rcrop
        vgw         = ls_rcrvgw
        flg_network = 'X'
      IMPORTING
        t1          = ls_cxzeit-ruest
        t2          = ls_cxzeit-bearb
        t3          = ls_cxzeit-abruest
      CHANGING
        u1          = ls_afvgd-rstze
        u2          = ls_afvgd-beaze
        u3          = ls_afvgd-aruze
      EXCEPTIONS
        OTHERS      = 0.

    DATA lf_unit_out TYPE msehi.
    " Convert setup time from seconds to real time unit
    IF ls_cxzeit-ruest IS NOT INITIAL.
      lf_unit_out = ls_afvgd-rstze.
      zcl_services=>conversion_time( EXPORTING if_value_in  = ls_cxzeit-ruest
                                                   if_unit_in   = zcl_services=>get_unit_for_seconds( )
                                         CHANGING  ef_unit_out  = lf_unit_out
                                                   ef_value_out = ls_afvgd-ruest ).
    ENDIF.
    " Convert processing time from seconds to real time unit
    IF ls_cxzeit-bearb IS NOT INITIAL.
      lf_unit_out = ls_afvgd-beaze.
      zcl_services=>conversion_time( EXPORTING if_value_in  = ls_cxzeit-bearb
                                                   if_unit_in   = zcl_services=>get_unit_for_seconds( )
                                         CHANGING  ef_unit_out  = lf_unit_out
                                                   ef_value_out = ls_afvgd-bearz ).
    ENDIF.
    " Convert teardown time from seconds to real time unit
    IF ls_cxzeit-abruest IS NOT INITIAL.
      lf_unit_out = ls_afvgd-aruze.
      zcl_services=>conversion_time( EXPORTING if_value_in  = ls_cxzeit-abruest
                                                   if_unit_in   = zcl_services=>get_unit_for_seconds( )
                                         CHANGING  ef_unit_out  = lf_unit_out
                                                   ef_value_out = ls_afvgd-abrue ).
    ENDIF.
    CALL FUNCTION 'CO_BT_AFVG_UPDATE' "#EC CI_USAGE_OK[2267333]
      EXPORTING
        afvgd_new      = ls_afvgd
        tabix_old      = ms_afvgd-indbt
        flg_no_dealloc = 'X'
      IMPORTING
        tabix_new      = ms_afvgd-indbt.

*#operations that have the Status EIGP must be redispatched
*#in case of proccess orders, if the operation in hand is a phase
*#then the main operation must be dispatched because a change to
*#a phase of the operation will bring changes to all the succesor
*#phases and the main operation
    IF has_status( zif_jstatus=>co_dspt ) IS NOT INITIAL.
      DATA(lf_pit) = zcl_pit=>convert_date_time( if_date = ms_afvgd-ssavd
                                                     if_time = ms_afvgd-ssavz ).
      read_afvgd( )."get the new values set before
      dispatch_midpoint( lf_pit ).
      TRY .
          lr_operation = me.
          WHILE  lr_operation->is_main_operation( ) IS INITIAL.
            TRY.
                lr_operation = lr_operation->get_predecessor( ).
              CATCH zcx_no_predecessor.
            ENDTRY.
          ENDWHILE.
          lf_pit = zcl_pit=>convert_date_time( if_date = lr_operation->ms_afvgd-ssavd
                                                   if_time = lr_operation->ms_afvgd-ssavz ).

          lr_operation->dispatch_midpoint( lf_pit ).
        CATCH zcx_core.
      ENDTRY.
    ENDIF.

    mr_order->schedule( ).

  ENDMETHOD.
ENDCLASS.
