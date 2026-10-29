class ZCL_OPERATION_PLANO definition
  public
  inheriting from ZCL_OPERATION
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IR_ORDER type ref to ZIF_ORDER
      !IS_AFVGD type AFVGD .
  methods IS_WORKCENTER_FROM_ROOTING
    importing
      !IR_ARBID type ref to ZCL_ARBID
      !IF_REFRESH_ROUTING type ABAP_BOOL default ABAP_FALSE
    returning
      value(RF_ANSWER) type FLAG .

  methods ZIF_LONG_TEXT~HAS_LONG_TEXT
    redefinition .
  methods ZIF_OPERATION~CHANGE_STANDARD_VALUE
    redefinition .
  methods ZIF_OPERATION~CHANGE_STANDARD_VALUES
    redefinition .
  methods ZIF_OPERATION~CHANGE_STANDARD_VALUES_DIALOG
    redefinition .
  methods ZIF_OPERATION~CHANGE_WORKCENTER
    redefinition .
  methods ZIF_OPERATION~DEALLOCATE
    redefinition .
  methods ZIF_OPERATION~DISPATCH_MIDPOINT
    redefinition .
  methods ZIF_OPERATION~IS_MAIN_OPERATION
    redefinition .
  methods ZIF_OPERATION~MIDPOINT_SCHEDULE
    redefinition .
  methods ZIF_OPERATION~REFRESH
    redefinition .
  methods ZIF_OPERATION~SCHEDULE
    redefinition .
  methods SET_AFVGD
    redefinition .
protected section.

  data MR_VIRTUAL_OPERATION type ref to ZCL_OPERATION .

  methods FILTER_PRODUCTION_AIDS
    redefinition .
  methods GET_MIDPOINT_SCHEDULE_PROTOCOL
    redefinition .
  methods READ_AFVGD
    redefinition .
  PRIVATE SECTION.
    TYPES: begin of ts_plpo_arbid,
             zaehl TYPE coplpo-zaehl,
             vornr TYPE coplpo-vornr,
             arbid TYPE coplpo-arbid,
           END of ts_plpo_arbid.
    TYPES: tt_plpo_arbid TYPE SORTED TABLE OF ts_plpo_arbid WITH UNIQUE KEY zaehl vornr arbid.
    TYPES: BEGIN OF ts_aufnr_plpo,
             aufnr TYPE aufnr,
             plpo TYPE tt_plpo_arbid,
           end OF ts_aufnr_plpo.
    TYPES: tt_aufnr_plpo TYPE SORTED TABLE OF ts_aufnr_plpo WITH UNIQUE KEY aufnr.
    CLASS-DATA: gt_aufnr_plpo TYPE tt_aufnr_plpo.
    METHODS generate_objnr .
    METHODS get_virtual_operation
      RETURNING
        VALUE(rr_operation) TYPE REF TO zif_operation .
ENDCLASS.

CLASS ZCL_OPERATION_PLANO IMPLEMENTATION.

  METHOD zif_long_text~has_long_text.
*#planned Order operation have no long text
  ENDMETHOD.

  METHOD zif_operation~change_standard_value.
    DATA: lt_kbedd TYPE TABLE OF kbedd.
    FIELD-SYMBOLS: <ls_kbedd> TYPE kbedd.

*#this will also re virtualise the plannedOrder and update all the operations from the buffer tables
    mr_order->start_update( ).

    mr_virtual_operation->refresh( ).
    rr_protocol = mr_virtual_operation->change_standard_value( if_no    = if_no
                                                               if_value = if_value
                                                               if_unit  = if_unit ).

    CALL FUNCTION 'CX_OPR_CAPACITIES'
      EXPORTING
        afvgd_imp         = ms_afvgd
        i_bedty           = mr_order->ms_caufvd-typkz
        i_flg_write_null  = 'X' "also write 0 time KBEDS
      TABLES
        t_kbedd           = lt_kbedd
      EXCEPTIONS
        missing_parameter = 1
        not_found         = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_kbedd ASSIGNING <ls_kbedd>.
      <ls_kbedd>-vgw01 = ms_afvgd-vgw01.
      <ls_kbedd>-vge01 = ms_afvgd-vge01.
      <ls_kbedd>-vgw02 = ms_afvgd-vgw02.
      <ls_kbedd>-vge02 = ms_afvgd-vge02.
      <ls_kbedd>-vgw03 = ms_afvgd-vgw03.
      <ls_kbedd>-vge03 = ms_afvgd-vge03.
      <ls_kbedd>-vgw04 = ms_afvgd-vgw04.
      <ls_kbedd>-vge04 = ms_afvgd-vge04.
      <ls_kbedd>-vgw05 = ms_afvgd-vgw05.
      <ls_kbedd>-vge05 = ms_afvgd-vge05.
      <ls_kbedd>-vgw06 = ms_afvgd-vgw06.
      <ls_kbedd>-vge06 = ms_afvgd-vge06.
      <ls_kbedd>-bmsch = ms_afvgd-bmsch.
      <ls_kbedd>-usr04 = ms_afvgd-usr04.
      <ls_kbedd>-use04 = ms_afvgd-use04.
      <ls_kbedd>-usr05 = ms_afvgd-usr05.
      <ls_kbedd>-use05 = ms_afvgd-use05.
      <ls_kbedd>-umren = ms_afvgd-umren.
      <ls_kbedd>-umrez = ms_afvgd-umrez.
    ENDLOOP.

    CALL FUNCTION 'CY_BT_KBED_OPR_UPDATE'
      EXPORTING
        i_aufnr         = mr_order->ms_caufvd-aufnr
        i_bedid         = ms_afvgd-bedid
        i_bedzl         = ms_afvgd-bedzl
        i_index_afvg_bt = ms_afvgd-indbt
      TABLES
        t_kbedd         = lt_kbedd.

    mr_order->schedule( ).
  ENDMETHOD.

  METHOD zif_operation~change_standard_values.
    DATA: lt_kbedd TYPE TABLE OF kbedd.
    FIELD-SYMBOLS: <ls_kbedd> TYPE kbedd.

*#this will also re virtualise the plannedOrder
    mr_order->start_update( ).
    mr_virtual_operation->refresh( ).
    er_protocol = mr_virtual_operation->change_standard_values(
                                   if_vgw01 = if_vgw01
                                   if_vge01 = if_vge01
                                   if_vgw02 = if_vgw02
                                   if_vge02 = if_vge02
                                   if_vgw03 = if_vgw03
                                   if_vge03 = if_vge03
                                   if_vgw04 = if_vgw04
                                   if_vge04 = if_vge04
                                   if_vgw05 = if_vgw05
                                   if_vge05 = if_vge05
                                   if_vgw06 = if_vgw06
                                   if_vge06 = if_vge06 ).

    CALL FUNCTION 'CX_OPR_CAPACITIES'
      EXPORTING
        afvgd_imp         = ms_afvgd
        i_bedty           = mr_order->ms_caufvd-typkz
        i_flg_write_null  = 'X' "also write 0 time KBEDS
      TABLES
        t_kbedd           = lt_kbedd
      EXCEPTIONS
        missing_parameter = 1
        not_found         = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_kbedd ASSIGNING <ls_kbedd>.
      <ls_kbedd>-vgw01 = ms_afvgd-vgw01.
      <ls_kbedd>-vge01 = ms_afvgd-vge01.
      <ls_kbedd>-vgw02 = ms_afvgd-vgw02.
      <ls_kbedd>-vge02 = ms_afvgd-vge02.
      <ls_kbedd>-vgw03 = ms_afvgd-vgw03.
      <ls_kbedd>-vge03 = ms_afvgd-vge03.
      <ls_kbedd>-vgw04 = ms_afvgd-vgw04.
      <ls_kbedd>-vge04 = ms_afvgd-vge04.
      <ls_kbedd>-vgw05 = ms_afvgd-vgw05.
      <ls_kbedd>-vge05 = ms_afvgd-vge05.
      <ls_kbedd>-vgw06 = ms_afvgd-vgw06.
      <ls_kbedd>-vge06 = ms_afvgd-vge06.
      <ls_kbedd>-bmsch = ms_afvgd-bmsch.
      <ls_kbedd>-usr04 = ms_afvgd-usr04.
      <ls_kbedd>-use04 = ms_afvgd-use04.
      <ls_kbedd>-usr05 = ms_afvgd-usr05.
      <ls_kbedd>-use05 = ms_afvgd-use05.
      <ls_kbedd>-umren = ms_afvgd-umren.
      <ls_kbedd>-umrez = ms_afvgd-umrez.
    ENDLOOP.

    CALL FUNCTION 'CY_BT_KBED_OPR_UPDATE'
      EXPORTING
        i_aufnr         = mr_order->ms_caufvd-aufnr
        i_bedid         = ms_afvgd-bedid
        i_bedzl         = ms_afvgd-bedzl
        i_index_afvg_bt = ms_afvgd-indbt
      TABLES
        t_kbedd         = lt_kbedd.

    mr_order->schedule( ).
  ENDMETHOD.

  METHOD zif_operation~change_standard_values_dialog.
    mr_virtual_operation->refresh( ).
    mr_virtual_operation->change_standard_values_dialog( ).
  ENDMETHOD.

  METHOD zif_operation~change_workcenter.
    " Make sure we have at least an empty object to return, not nothing
    rr_protocol = NEW zcl_msg( mid = 'Z_CORE' ).
    CHECK ir_new <> mr_workcenter.

    mr_order->start_update( ).
    " Make sure we have at least an empty object to return, not nothing
*#planned orders can only change their workcenter if the
*#KBED has the status EIGP
    generate_objnr( ).

    mr_virtual_operation->refresh( ).

    rr_protocol = mr_virtual_operation->change_workcenter( ir_new = ir_new
                                                           if_no_order_schedule = if_no_order_schedule ).

*#set the status UMGP(umgeplant) for all operations that do not have the same Workcenter as from rooting
    IF is_workcenter_from_rooting( ir_new ) = abap_false.
*#only if the operation has the Status DSPT and UMGP can the workcenter remain unchanged after a change to the order
      set_status( zif_jstatus=>co_umgp )."Umgeplant
      set_status( zif_jstatus=>co_dspt )."'EIGP'
    ELSE.
      IF has_status( zif_jstatus=>co_dspt ) = abap_true.
        remove_status( zif_jstatus=>co_umgp )."Umgeplant
        set_status( zif_jstatus=>co_dspt )."'EIGP'
      ELSE.
        remove_status( zif_jstatus=>co_umgp )."Umgeplant
      ENDIF.
    ENDIF.

*#schedule the order after the workcenter change
    IF if_no_order_schedule = abap_false.
      mr_order->schedule( ).
    ENDIF.

    TRY .
        mr_workcenter ?= ir_new.
      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_operation~deallocate.

*#for planned Orders we have some special situations:
*# - The Capacity Firming of the PlannedOrder(PLAF-KAPFX) is an Order field and not an Operation field. This flag
*#but it should be removed only when all operations do not have this status any more.!!!
*# - The Capacity Firming of the PlannedOrder(PLAF-KAPFX) will automaticaly be removed if the Order Firming of the
*#plannedOrder(PLAF-AUFFX) is removed. In this case all the statuses of the operations will be removed.
*#We can change this behaviour by making shour that we first remove the PLAF-KAPFX and then remove the PLAF-AUFFX.

    DATA: lr_plano           TYPE REF TO zcl_order_plano,
          lr_operation_plano TYPE REF TO zcl_operation_plano.

    mr_order->start_update( ).

    IF is_workcenter_from_rooting( ir_arbid = mr_workcenter
                                   if_refresh_routing = abap_true ) = abap_true.
      mr_virtual_operation->refresh( ).
      rr_protocol = mr_virtual_operation->deallocate( ).
      refresh( )."read the operation information again
    ELSE.
      CREATE OBJECT rr_protocol.
    ENDIF.

    TRY .
        lr_plano ?= mr_order.
*#To decide if the indicator KAPFX should be reset all operations must be checked if there are dispatched or not
*#from this check we must not take into consideration the operations that do not have the workcenter from the rooting
        IF lr_plano->ms_plaf-kapfx IS NOT INITIAL.
          LOOP AT mr_order->mt_operations INTO DATA(lr_operation).
            TRY .
                lr_operation_plano ?= lr_operation.
                IF lr_operation_plano->is_workcenter_from_rooting( ir_arbid = lr_operation_plano->mr_workcenter ) = abap_true AND
                   lr_operation_plano->has_status( zif_jstatus=>co_dspt ) = abap_true.
*#refresh the entire order(read the SAP buffer tables again...)
                  mr_order->refresh( ).
                  RETURN."an operation with the status was found so no further processing
                ENDIF.
              CATCH cx_sy_move_cast_error.
            ENDTRY.
          ENDLOOP.

          DATA(ls_plaf) = lr_plano->ms_plaf.
          ls_plaf-kapfx = space.
          lr_plano->set_plaf( ls_plaf ).

          rr_protocol->set( mid = 'Z_CORE'
                            num = '108'"Planauftrag '&': "Kapazitiv eingeplant" kenzeichen würde entfernt.
                            pa1 = ls_plaf-plnum ).

*#after the removal of the KAPFX from the PLAF the status DSPT will be removed from all the operations so
*#set the status again for all the operations do not have the workcenter from the rooting
          LOOP AT mr_order->mt_operations INTO lr_operation.
            TRY .
                lr_operation_plano ?= lr_operation.
                IF lr_operation_plano->is_workcenter_from_rooting( ir_arbid = lr_operation_plano->mr_workcenter ) = abap_false.
                  lr_operation->set_status( zif_jstatus=>co_dspt ).
                  lr_operation->set_status( zif_jstatus=>co_umgp ).
                ENDIF.
              CATCH cx_sy_move_cast_error.
            ENDTRY.
          ENDLOOP.

*#refresh the entire order(read the SAP buffer tables again...)
          mr_order->refresh( ).
        ENDIF.
      CATCH cx_sy_move_cast_error.
    ENDTRY.

  ENDMETHOD.

  METHOD zif_operation~dispatch_midpoint.
    DATA: ls_plaf      TYPE plaf,
          lf_kapfx_old TYPE kapfx,
          lf_auffx_old TYPE plafx,
          lr_plano     TYPE REF TO zcl_order_plano.

    mr_order->start_update( ).

*#for planned orders the KAPFX must be set
    TRY .
        lr_plano ?= mr_order.
*#remember the old values in case the dispatch does not work
        lf_kapfx_old = lr_plano->ms_plaf-kapfx.
        lf_auffx_old = lr_plano->ms_plaf-auffx.

        ls_plaf = lr_plano->ms_plaf.

        ls_plaf-kapfx = abap_true.
        ls_plaf-auffx = abap_true."will not reschedule without auffx
        lr_plano->set_plaf( ls_plaf ).

*#If the operation does not have a object number then one must be created
*#and the operation statuses must be reread
        generate_objnr( ).

        mr_virtual_operation->refresh( ).
        rr_protocol = mr_virtual_operation->dispatch_midpoint( if_pit     = if_pit
                                                               if_forward = if_forward ).
        ls_plaf-auffx = lf_auffx_old.
        ls_plaf-kapfx = lf_kapfx_old.
        TRY .
            lr_plano ?= mr_virtual_operation->mr_order.
            ls_plaf = lr_plano->ms_plaf.
            lr_plano->set_plaf( ls_plaf ).
          CATCH cx_sy_move_cast_error.
        ENDTRY.
      CATCH cx_sy_move_cast_error
        zcx_core.
    ENDTRY.

  ENDMETHOD.

  METHOD zif_operation~is_main_operation.
*#for proccess orders whe have phases and parent operationss
*#a phase will not be considered a main operation
    mr_virtual_operation->refresh( ).
    rf_answer = mr_virtual_operation->is_main_operation( ).
  ENDMETHOD.

  METHOD zif_operation~midpoint_schedule.
    mr_order->schedule( ).
*#for series production the LINE_SCHED_TABLE must be cleard
    IF ms_afvgd-takt IS NOT INITIAL.
      CALL FUNCTION 'CX_TK_TABLES_RESET'.
    ENDIF.

    mr_virtual_operation->refresh( ).
    rr_protocol = mr_virtual_operation->midpoint_schedule( if_pit     = if_pit
                                                           if_forward = if_forward ).

    mr_order->schedule( ).
  ENDMETHOD.

  METHOD zif_operation~refresh.
    super->zif_operation~refresh( ).
    mr_virtual_operation->refresh( ).
  ENDMETHOD.

  METHOD zif_operation~schedule.
    mr_virtual_operation->refresh( ).
    mr_virtual_operation->schedule( EXPORTING if_pit     = if_pit
                                              if_forward = if_forward
                                    CHANGING  cs_afvgd   = cs_afvgd ).
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ir_order = ir_order
                        is_afvgd = is_afvgd ).
    TRY .
        mr_virtual_operation ?= get_virtual_operation( ).
      CATCH cx_sy_move_cast_error.
    ENDTRY.

*#only generate object number for dispatched operations

*#in UPDATE TASK the following situation can occure:
*#-if the workcenter was changed for an operation the Stauts EIGP will not
*#be found by the SAP virtualisation of the planned order because the status
*#is in that moment not yet persisted. Planned Orders can only change their
*#workcenter if the operation is Planned(Status EIGP)
    READ TABLE mt_kbed INTO DATA(ls_kbed) INDEX 1.
    CHECK sy-subrc = 0.
    CHECK ls_kbed-arbid <> mr_workcenter->mf_arbid.
    mr_workcenter = zcl_arbid=>get_instance( ls_kbed-arbid ).
  ENDMETHOD.

  METHOD filter_production_aids.
    DELETE ct_fhm WHERE plnkn <> ms_afvgd-plnkn.
  ENDMETHOD.

  METHOD generate_objnr.
*#only if necessary
    CHECK ms_afvgd-objnr IS INITIAL.
    PERFORM create_status_object_for_kbed IN PROGRAM  saplcy06 IF FOUND USING ms_afvgd.
    read_statuses( ).
    read_demand( ).
  ENDMETHOD.

  METHOD get_midpoint_schedule_protocol.
    mr_virtual_operation->refresh( ).
    rr_protocol = mr_virtual_operation->get_midpoint_schedule_protocol( ).
  ENDMETHOD.

  METHOD get_virtual_operation.
    CASE mr_order->ms_caufvd-autyp.
      WHEN mr_order->co_autyp-process.
        CREATE OBJECT rr_operation TYPE zcl_operation_process
          EXPORTING
            ir_order = mr_order
            is_afvgd = ms_afvgd.
      WHEN mr_order->co_autyp-iho.
        CREATE OBJECT rr_operation TYPE zcl_operation_ih
          EXPORTING
            ir_order = mr_order
            is_afvgd = ms_afvgd.
      WHEN mr_order->co_autyp-network.
        CREATE OBJECT rr_operation TYPE zcl_operation_netwk
          EXPORTING
            ir_order = mr_order
            is_afvgd = ms_afvgd.
      WHEN OTHERS.
        CREATE OBJECT rr_operation TYPE zcl_operation_prodo
          EXPORTING
            ir_order = mr_order
            is_afvgd = ms_afvgd.
    ENDCASE.
  ENDMETHOD.

  METHOD is_workcenter_from_rooting.
*# Routing is now handled by its own class.

     rf_answer = mr_order->get_routing_master( )->is_workcenter_from_routing( if_vornr = ms_afvgd-vornr
                                                                              if_plnkn = ms_afvgd-plnkn
                                                                              if_arbid = ms_afvgd-arbid ).
  ENDMETHOD.

  METHOD read_afvgd.
*#only generate object number for dispatched operations
    CALL FUNCTION 'CO_BT_AFVG_READ_WITH_LOGKEY'
      EXPORTING
        aplfl     = ms_afvgd-aplfl
        aufnr_act = mr_order->ms_caufvd-aufnr
        flg_work  = 'X'
        vornr     = ms_afvgd-vornr
      IMPORTING
        afvgd_exp = ms_afvgd
      EXCEPTIONS
        OTHERS    = 0.

  ENDMETHOD.

  METHOD set_afvgd.
    mr_virtual_operation->refresh( ).
    er_protocol = mr_virtual_operation->set_afvgd( is_afvgd ).
  ENDMETHOD.
ENDCLASS.
