class ZCL_ORDER_PRODO definition
  public
  inheriting from ZCL_ORDER
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IF_AUFNR type AUFNR .
  class-methods GET_SART_FROM_AUTYP
    importing
      !IF_AUTYP type AUFTYP
    returning
      value(RF_SART) type CHAR1 .
  class-methods FACTORY
    importing
      !IF_AUFNR type AUFNR
    returning
      value(RR_ORDER) type ref to ZIF_ORDER .

  methods zif_order~CHANGE_TOTAL_QUANTITY
    redefinition .
protected section.

  methods BUILD_PEGGED_REQUIREMENT_HEAD
    redefinition .
  methods READ_PRODUCTION_AIDS
    redefinition .
private section.
ENDCLASS.

CLASS ZCL_ORDER_PRODO IMPLEMENTATION.

  METHOD BUILD_PEGGED_REQUIREMENT_HEAD.
    ms_pegged_requirement_head-delkz = zif_pegged_requirement=>co_prodo.
    ms_pegged_requirement_head-delnr = ms_caufvd-aufnr.
    ms_pegged_requirement_head-delps = 1.
    ms_pegged_requirement_head-matnr = ms_caufvd-matnr.
    ms_pegged_requirement_head-werks = ms_caufvd-werks.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).

    DATA: lr_werks TYPE REF TO zcl_werks.

    mf_aufnr = if_aufnr.
    mf_plnid = if_aufnr.
    read_header_and_position( ).

    mf_sart  = get_sart_from_autyp( ms_caufvd-autyp ).
    TRY.
        read_tcx00( ).
      CATCH zcx_tcx_notfound.
    ENDTRY.
    read_statuses( ).
    read_demand_header( ).
    read_aob( ).
    read_affl( ).

    lr_werks = zcl_werks=>get_instance( ms_caufvd-werks ).
    mr_material = zcl_werks_material=>get_instance( ir_werks = lr_werks
                                                            if_matnr = ms_caufvd-matnr ).
*# Parallele Folgen
    SELECT SINGLE parallel_sequences FROM /gib/dcp_0003 INTO mf_parallel_sequences "#EC CI_SUBRC
      WHERE werks = lr_werks->mf_werks.
*## Parallele Folgen

    build_operations( ).
  ENDMETHOD.

  METHOD factory.
    DATA: lf_autyp TYPE auftyp.
    CALL FUNCTION 'CO_BT_CAUFV_READ_WITH_KEY'
      EXPORTING
        aufnr_act = if_aufnr
      IMPORTING
        autyp_exp = lf_autyp
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*#if the order was not pre buffered(CO_DB_ORDER_PRE_READ) then read it from the DB
      SELECT SINGLE autyp FROM caufv INTO lf_autyp WHERE aufnr = if_aufnr. "#EC CI_SUBRC
    ENDIF.
    CASE lf_autyp.
      WHEN co_autyp-prodo."'10'
        CREATE OBJECT rr_order TYPE zcl_order_prodo
          EXPORTING
            if_aufnr = if_aufnr.
      WHEN co_autyp-network."'20'.
        CREATE OBJECT rr_order TYPE zcl_order_netwk
          EXPORTING
            if_aufnr = if_aufnr.
      WHEN co_autyp-iho."'30'.
        CREATE OBJECT rr_order TYPE zcl_order_ih
          EXPORTING
            if_aufnr = if_aufnr.
      WHEN co_autyp-process."'40'.
        CREATE OBJECT rr_order TYPE zcl_order_process
          EXPORTING
            if_aufnr = if_aufnr.
      WHEN OTHERS.
        CREATE OBJECT rr_order TYPE zcl_order_prodo
          EXPORTING
            if_aufnr = if_aufnr.
    ENDCASE.

  ENDMETHOD.

METHOD get_sart_from_autyp.
  CASE if_autyp.
    WHEN co_autyp-prodo.   rf_sart = /gib/cl_dcp_sart=>co_prodo.
    WHEN co_autyp-network. rf_sart = /gib/cl_dcp_sart=>co_network.
    WHEN co_autyp-iho.     rf_sart = /gib/cl_dcp_sart=>co_iho.
    WHEN co_autyp-process. rf_sart = /gib/cl_dcp_sart=>co_process.
    WHEN OTHERS.           rf_sart = /gib/cl_dcp_sart=>co_prodo.
  ENDCASE.
ENDMETHOD.

  METHOD read_production_aids.
    DATA: lt_fhm TYPE TABLE OF affhd.

    CLEAR: mt_fhm.
    CALL FUNCTION 'CF_BT_CO_AFFHD_TAB_GET'
      EXPORTING
        i_aufpl           = ms_caufvd-aufpl
        i_no_deleted      = 'X'
        i_no_phys_deleted = 'X'
        i_flg_statx       = 'X'
      TABLES
        affhd_tab         = lt_fhm
      EXCEPTIONS
        not_found         = 1
        OTHERS            = 2.
    IF sy-subrc <> 0
      OR lt_fhm IS INITIAL.
      RETURN.
    ENDIF.
    LOOP AT lt_fhm INTO DATA(ls_fhm).
      APPEND INITIAL LINE TO mt_fhm ASSIGNING FIELD-SYMBOL(<ls_fhmx>).
      MOVE-CORRESPONDING ls_fhm TO <ls_fhmx>.
    ENDLOOP.
    mf_fhm_buffered = abap_true.

  ENDMETHOD.

  METHOD zif_order~change_total_quantity.

    DATA: ls_header  TYPE bapi_pp_order_change,
          ls_headerx TYPE bapi_pp_order_changex.

    CALL METHOD super->change_total_quantity
      EXPORTING
        if_value = if_value.

    IF if_value = 0.
      MESSAGE s104(z_core) DISPLAY LIKE zcl_msg=>co_error.
      RETURN.
    ENDIF.
    start_update( ).

*# Change scrap quantity if required
    IF if_gasmg = -1. "Automatische anpassung
      DATA: lf_new_gasmg TYPE caufv-gasmg.
      DATA: lf_andec TYPE t006-andec.
      IF ms_caufvd-matnr IS NOT INITIAL AND
         ms_caufvd-gasmg <> 0 AND
         ms_caufvd-gamng <> if_value.
        lf_new_gasmg = ms_caufvd-gasmg * if_value / ms_caufvd-gamng.
        SELECT SINGLE andec FROM t006 INTO lf_andec WHERE msehi = ms_caufvd-gmein.
        IF sy-subrc = 0 AND lf_andec < 3 AND lf_new_gasmg <> 0.
          IF lf_new_gasmg MOD 1 <> 0.
            lf_new_gasmg = round( val = lf_new_gasmg
                                  dec = lf_andec
                                  mode = cl_abap_math=>round_up ).
          ENDIF.
        ENDIF.

        IF lf_new_gasmg <> ms_caufvd-gasmg.
          IF ir_protocol IS BOUND.
            ir_protocol->set( EXPORTING num = '553' "Ausschussmenge wurde proportional auf x angepasst
                                        typ = zcl_msg=>co_warning
                                        pa1 = |{  lf_new_gasmg NUMBER = USER }| ).
          ENDIF.
          ms_caufvd-gasmg = lf_new_gasmg.
          ls_header-scrap_quantity = lf_new_gasmg.
          ls_headerx-scrap_quantity = abap_true.
        ENDIF.
      ENDIF.
    ELSEIF ms_caufvd-gasmg <> if_gasmg.
      ms_caufvd-gasmg = if_gasmg.
      ls_header-scrap_quantity = if_gasmg.
      ls_headerx-scrap_quantity = abap_true.
    ENDIF.

    ms_caufvd-gamng = if_value.

    ls_header-quantity = if_value.
    ls_headerx-quantity = abap_true.

    DATA(lf_batch) = sy-batch.

    CALL FUNCTION 'COXT_BAPI_ORDER_CHANGE'
      EXPORTING
        i_order_number   = ms_caufvd-aufnr
        is_header        = ls_header
        is_headerx       = ls_headerx
        i_order_category = ms_caufvd-autyp
        iv_commit        = abap_false
        iv_order_post    = abap_false
      EXCEPTIONS
        error_message    = 1.
    IF sy-subrc NE 0.
      IF ir_protocol IS BOUND.
        ir_protocol->sy_set( ).
      ENDIF.
    ENDIF.

    sy-batch = lf_batch.

    read_header_and_position( ).
    schedule( ).

  ENDMETHOD.
ENDCLASS.
