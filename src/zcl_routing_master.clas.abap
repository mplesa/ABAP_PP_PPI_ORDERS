class ZCL_ROUTING_MASTER definition
  public
  final
  create private .

public section.

  interfaces ZIF_ROUTING_MASTER .

  class-methods GET_INSTANCE
    importing
      !IF_PLNTY type PLNTY
      !IF_PLNNR type PLNNR
      !IF_PLNAL type PLNAL
    returning
      value(RR_ROUTING_MASTER) type ref to ZIF_ROUTING_MASTER.
  class-methods CLEAR_ALL_BUFFER .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ts_instance,
        plnty TYPE plko-plnty,
        plnnr TYPE plko-plnnr,
        plnal TYPE plko-plnal,
        routing TYPE REF TO ZIF_ROUTING_MASTER,
      END OF ts_instance .

  data MT_PLKO type ZIF_ROUTING_MASTER~TT_PLKO .
  data MT_PLPO type ZIF_ROUTING_MASTER~TT_PLPO .
  data MT_PLAS type ZIF_ROUTING_MASTER~TT_PLAS .
  data MT_PLFL type ZIF_ROUTING_MASTER~TT_PLFL .
  data MT_PLFH type ZIF_ROUTING_MASTER~TT_PLFH .
  data MF_OPERATIONS_READ type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MF_SEQUENCES_READ type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MF_HEAD_READ type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  class-data:
    gt_instances TYPE SORTED TABLE OF ts_instance WITH UNIQUE KEY plnty plnnr plnal .
  data MF_PRODUCTION_RT_READ type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IF_PLNTY type PLNTY
      !IF_PLNNR type PLNNR
      !IF_PLNAL type PLNAL .
  methods READ_ROUTING
    raising
      /GIB/CX_DCP .
ENDCLASS.

CLASS ZCL_ROUTING_MASTER IMPLEMENTATION.

  method ZIF_ROUTING_MASTER~CLEAR_BUFFER.
    CLEAR mt_plpo.
    CLEAR mt_plko.
    CLEAR mt_plfl.
    CLEAR mt_plas.
    CLEAR mt_plfh.

    mf_head_read = abap_false.
    mf_operations_read = abap_false.
    mf_sequences_read = abap_false.
    mf_production_rt_read = abap_false.
  endmethod.

  METHOD zif_routing_master~get_data.
*# Please be aware, that the tables doesn't contain the complete
*# attributes of the database tables. If additional attributes are needed
*# you only have to add there attributes to the ts_* structures in interface

    TRY.
      read_routing( ).
      rf_data_found = abap_true.
    CATCH /gib/cx_dcp.
      rf_data_found = abap_false.
    ENDTRY.

    IF et_plko IS SUPPLIED.
      et_plko = mt_plko.
    ENDIF.

    IF et_plfl IS SUPPLIED.
      et_plfl = mt_plfl.
    ENDIF.

    IF et_plpo IS SUPPLIED.
      et_plpo = mt_plpo.
    ENDIF.

    IF et_plas IS SUPPLIED.
      et_plas = mt_plas.
    ENDIF.
    IF et_plfh IS SUPPLIED.
      et_plfh = mt_plfh.
    ENDIF.

  ENDMETHOD.

  METHOD zif_routing_master~is_workcenter_from_routing.
*# Please only use this with paramter if_plnkn, not with if_zaehl, cause it is not right
*# e.g. when changing routing master per change management
    TRY.
        read_routing( ).
      CATCH /gib/cx_dcp.
        RETURN.
    ENDTRY.

    IF if_plnkn IS SUPPLIED.
      READ TABLE mt_plpo
       WITH KEY vka COMPONENTS vornr = if_vornr
                               plnkn = if_plnkn
                               arbid = if_arbid
       TRANSPORTING NO FIELDS.
    ELSE.
      READ TABLE mt_plpo
       WITH KEY vza COMPONENTS vornr = if_vornr
                               zaehl = if_zaehl
                               arbid = if_arbid
       TRANSPORTING NO FIELDS.
    ENDIF.
    IF sy-subrc = 0.
      rf_is_from_workcenter = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD CLEAR_ALL_BUFFER.
    LOOP AT gt_instances ASSIGNING FIELD-SYMBOL(<ls_instance>).
      <ls_instance>-routing->clear_buffer( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD CONSTRUCTOR.
    zif_routing_master~mf_plnty = if_plnty.
    zif_routing_master~mf_plnnr = if_plnnr.
    zif_routing_master~mf_plnal = if_plnal.
  ENDMETHOD.

  METHOD get_instance.
    CHECK if_plnty IS NOT INITIAL AND
          if_plnnr IS NOT INITIAL AND
          if_plnal IS NOT INITIAL.

    READ TABLE gt_instances
     WITH TABLE KEY plnty = if_plnty
                    plnnr = if_plnnr
                    plnal = if_plnal
     ASSIGNING FIELD-SYMBOL(<ls_instance>).

    IF sy-subrc = 0.
      rr_routing_master = <ls_instance>-routing.
    ELSE.
      rr_routing_master = NEW zcl_routing_master(
                     if_plnty = if_plnty
                     if_plnnr = if_plnnr
                     if_plnal = if_plnal ).
      INSERT VALUE #( plnty = if_plnty
                      plnnr = if_plnnr
                      plnal = if_plnal
                      routing = rr_routing_master ) INTO TABLE gt_instances.
    ENDIF.
  ENDMETHOD.

  METHOD read_routing.

*#CP_EX_PLAN_READ will reverse the imputs from  LS_TCA11 and if you want to
*#read the WorkPlan you half to set it as abap_false
    DATA lt_plpo_exp  TYPE TABLE OF coplpo.
    DATA lt_plko_exp  TYPE TABLE OF plko.
    DATA lt_plfl_exp  TYPE TABLE OF plfl.
    DATA lt_plas_exp  TYPE TABLE OF plas.
    DATA lt_plfh_exp  TYPE TABLE OF plfh.

    DATA ls_plpo TYPE zif_routing_master~ts_plpo.
    DATA ls_plko TYPE zif_routing_master~ts_plko.
    DATA ls_plfl TYPE zif_routing_master~ts_plfl.
    DATA ls_plas TYPE zif_routing_master~ts_plas.
    DATA ls_plfh TYPE zif_routing_master~ts_plfh.

*# Only read from DB, if not buffered (prepared for differential read, but not yet implemented)
    CHECK mf_head_read = abap_false OR
          mf_sequences_read = abap_false OR
          mf_operations_read = abap_false OR
          mf_production_rt_read = abap_false.

    CLEAR mt_plpo.
    CLEAR mt_plko.
    CLEAR mt_plas.
    CLEAR mt_plfl.
    CLEAR mt_plfh.

    DATA ls_tca11 TYPE tca11.
    ls_tca11-flg_alt  = abap_false."Kennzeichen: Pläne
    ls_tca11-flg_seq  = abap_false."Kennzeichen: Folgen
    ls_tca11-flg_opr  = abap_false."Kennzeichen: Vorgänge
    ls_tca11-flg_sop  = abap_true. "Kennzeichen: Untervorgänge
    ls_tca11-flg_aob  = abap_true. "Schlüssel: Sicht auf die Anordnungsbeziehungen
    ls_tca11-flg_mst  = abap_true. "Kennzeichen: Vorgang ist ein Meilenstein
    ls_tca11-flg_txt  = abap_true. "Kennzeichen: PS-Texte
    ls_tca11-flg_fhm  = abap_false. "Kennzeichen: Fertigungshilfsmittel
    ls_tca11-flg_mat  = abap_true. "Kennzeichen: Materialkomponente  "at big selections can come to short dump
    ls_tca11-flg_feat = abap_true. "Kennzeichen: Rezept/Prozeßvorgabe aktiv
    ls_tca11-flg_feav = abap_true. "Kennzeichen: Prozeßvorgabemerkmal/Parameterwert
    ls_tca11-flg_qmk  = abap_true. "Kennzeichen: Prüfmerkmale
    ls_tca11-flg_qmw  = abap_true. "Kennzeichen: Prüfmerkmalswerte
    ls_tca11-flg_pms  = abap_true. "Kennzeichen: Flag für Wartungspaketzuordnung
    ls_tca11-flg_aps  = abap_true. "Kennzeichen: Auftragspositionen
    ls_tca11-flg_bed  = abap_true. "Kennzeichen: Kapazitätsbedarfe
    ls_tca11-flg_phas = abap_true. "Kennzeichen: CAP/Teiloperationen aktiv
    ls_tca11-flg_mst  = abap_true. "Kennzeichen: Vorgang ist ein Meilenstein
    ls_tca11-flg_snt  = abap_true. "Kennzeichen: Teilnetz
    DATA lf_flg_phas TYPE tca01-flg_phas.
    SELECT SINGLE flg_phas
      FROM tca01
      INTO lf_flg_phas
      WHERE plnty = zif_routing_master~mf_plnty.
    CHECK sy-subrc = 0.

    IF lf_flg_phas = abap_true.
      ls_tca11-flg_phas = abap_false.
    ENDIF.

    mf_head_read = abap_true.
    mf_operations_read = abap_true.
    mf_sequences_read = abap_true.
    mf_production_rt_read = abap_true.

    CALL FUNCTION 'CP_EX_PLAN_READ'
      EXPORTING
        plnty_imp     = zif_routing_master~mf_plnty
        plnnr_imp     = zif_routing_master~mf_plnnr
        plnal_imp     = zif_routing_master~mf_plnal
        sttag_imp     = sy-datum
        tca11_imp     = ls_tca11
      TABLES
        plko_exp      = lt_plko_exp
        plpo_exp      = lt_plpo_exp
        plfl_exp      = lt_plfl_exp
        plas_exp      = lt_plas_exp
        plfh_exp      = lt_plfh_exp
      EXCEPTIONS
        not_found     = 1
        plnal_initial = 2
        OTHERS        = 3.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /gib/cx_dcp EXPORTING textid = /gib/cx_dcp=>not_found.
    ENDIF.

    LOOP AT lt_plko_exp ASSIGNING FIELD-SYMBOL(<ls_plko_exp>).
      ls_plko = CORRESPONDING #( <ls_plko_exp> ).
      INSERT ls_plko INTO TABLE mt_plko.
    ENDLOOP.
    LOOP AT lt_plpo_exp ASSIGNING FIELD-SYMBOL(<ls_plpo_exp>).
      ls_plpo = CORRESPONDING #( <ls_plpo_exp> ).
      INSERT ls_plpo INTO TABLE mt_plpo.
    ENDLOOP.
    LOOP AT lt_plas_exp ASSIGNING FIELD-SYMBOL(<ls_plas_exp>).
      ls_plas = CORRESPONDING #( <ls_plas_exp> ).
      INSERT ls_plas INTO TABLE mt_plas.
    ENDLOOP.
    LOOP AT lt_plfl_exp ASSIGNING FIELD-SYMBOL(<ls_plfl_exp>).
      ls_plfl = CORRESPONDING #( <ls_plfl_exp> ).
      INSERT ls_plfl INTO TABLE mt_plfl.
    ENDLOOP.
    LOOP AT lt_plfh_exp ASSIGNING FIELD-SYMBOL(<ls_plfh_exp>).
      ls_plfh = CORRESPONDING #( <ls_plfh_exp> ).
      INSERT ls_plfh INTO TABLE mt_plfh.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
