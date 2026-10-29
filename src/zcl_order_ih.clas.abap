class ZCL_ORDER_IH definition
  public
  inheriting from ZCL_ORDER_PRODO
  create public .

public section.

  data CO_PHASE_RELEASED type PM_PHASE value '2' ##NO_TEXT.
  data CO_PHASE_OPEN type PM_PHASE value '0' ##NO_TEXT.
protected section.

  methods BUILD_PEGGED_REQUIREMENT_HEAD
    redefinition .
  methods DO_AFTER_RELEASE
    redefinition .
  methods UPDATE_ORDER
    redefinition .
private section.
ENDCLASS.

CLASS ZCL_ORDER_IH IMPLEMENTATION.

  METHOD BUILD_PEGGED_REQUIREMENT_HEAD.
    ms_pegged_requirement_head-delkz = zif_pegged_requirement=>co_maintenance.
    ms_pegged_requirement_head-delnr = ms_caufvd-aufnr.
    ms_pegged_requirement_head-delps = 1.
    ms_pegged_requirement_head-matnr = ms_caufvd-matnr.
    ms_pegged_requirement_head-werks = ms_caufvd-werks.
  ENDMETHOD.

  METHOD do_after_release.
    ms_caufvd-iphas = co_phase_released.
* Ab jetzt wird immer Kalkuliert
    CLEAR ms_caufvd-naucost.
    ms_caufvd-aucost = abap_true.
* Ab Freigabe wird alles disponiert was nicht auf NIE steht
* Mit Hinweis 418429 läßt sich in OIOE auch NIE einstellen
    IF ms_caufvd-no_disp <> zif_order=>co_dispo_relevance_no.
      CLEAR ms_caufvd-no_disp.
      ms_caufvd-audisp = zif_order=>co_dispo_relevance_yes.
    ENDIF.

    TRY.
        update_order( ).
      CATCH /gib/cx_dcp.
    ENDTRY.
* . . . Caufvd im SAPLCOVG aktualisieren
*       wichtig, weil Funktionen aus dem SAPLCOVG als externer Perform
*       aufgerufen werden können
    IF ms_caufvd-abruf_flag IS INITIAL.

      CALL FUNCTION 'CO_VG_GET_HEADER'
        EXPORTING
          caufvd_imp = ms_caufvd.
    ENDIF.

    super->do_after_release( ).

  ENDMETHOD.

  METHOD update_order.
*    like perform caufv_upd_IH

    DATA lt_caufvd_bt TYPE TABLE OF caufvdb.

    CALL FUNCTION 'CO_BH_CAUFV_BT_FETCH_PS'
      TABLES
        et_caufv_bt = lt_caufvd_bt.

    TRY.
        DATA(lf_enq) = lt_caufvd_bt[ ms_caufvd-indbt ]-flg_enq.
*  Order is locked --> normal Update
        IF lf_enq IS NOT INITIAL.
          DATA(lf_vbkz) = abap_true.
        ELSE.
          lf_vbkz = abap_false.
        ENDIF.
        super->update_order( lf_vbkz ).

      CATCH cx_sy_itab_line_not_found.
        MESSAGE e888(co) WITH TEXT-kop INTO DATA(lf_msg).
        RAISE EXCEPTION TYPE /gib/cx_dcp USING MESSAGE.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
