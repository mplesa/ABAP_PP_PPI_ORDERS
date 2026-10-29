class ZCL_WERKS_MATERIAL definition
  public
  create protected .

public section.

  interfaces ZIF_WERKS_MATERIAL .

  aliases MR_MATNR
    for ZIF_WERKS_MATERIAL~MR_MATNR .
  aliases MR_WERKS
    for ZIF_WERKS_MATERIAL~MR_WERKS .
  aliases MS_MARC
    for ZIF_WERKS_MATERIAL~MS_MARC .
  aliases MS_MSFCV
    for ZIF_WERKS_MATERIAL~MS_MSFCV .
  aliases MS_MTCOR
    for ZIF_WERKS_MATERIAL~MS_MTCOR .
  aliases MS_TCO43
    for ZIF_WERKS_MATERIAL~MS_TCO43 .
  aliases MT_MKAL
    for ZIF_WERKS_MATERIAL~MT_MKAL .
  aliases GET_MRP_DATA
    for ZIF_WERKS_MATERIAL~GET_MRP_DATA .
  aliases GET_MRP_EXCEPTIONS
    for ZIF_WERKS_MATERIAL~GET_MRP_EXCEPTIONS .

  types:
    BEGIN OF ts_dco_alert,
             auskt TYPE /gib/dco_auskt,
             austx TYPE /gib/dco_austx,
           END OF ts_dco_alert .
  types:

    tt_dco_marc_sort TYPE SORTED TABLE OF /gib/dco_marc WITH UNIQUE KEY werks matnr berid plscn .
  types:
    tt_ftind_sort    TYPE SORTED TABLE OF ftind WITH UNIQUE KEY werks matnr rsnum rspos rsart .
  types:
    BEGIN OF ts_werks_material,
        werks          TYPE werks_d,
        matnr          TYPE matnr,
        werks_material TYPE REF TO zif_werks_material,
      END OF ts_werks_material .
  types:
    tt_werks_material TYPE SORTED TABLE OF ts_werks_material WITH UNIQUE KEY werks matnr .

  data MT_DCO_MARC type TT_DCO_MARC_SORT read-only .
  data MT_FTIND type TT_FTIND_SORT read-only .

  methods GET_DCO_ALERTS
    returning
      value(ER_ALERTS) type ref to /GIB/CL_DCP_DCO_MATERIAL_ALERT .
  methods HAS_PLANNING_FILE_ENTRY
    importing
      !IF_BERID type BERID optional
    returning
      value(EF_PLANV) type XFELD .
  methods CONSTRUCTOR
    importing
      !IR_WERKS type ref to ZCL_WERKS
      !IR_MATNR type ref to ZIF_MATERIAL .
  class-methods GET_INSTANCE
    importing
      !IR_WERKS type ref to ZCL_WERKS
      !IF_MATNR type MATNR
    returning
      value(RR_MATNR) type ref to ZIF_WERKS_MATERIAL .
  class-methods ADD_TO_BUFFER
    importing
      !IT_MARC_HEAD type ZIF_WERKS_MATERIAL=>TT_MARC_HEAD .
  class-methods CLEAR_ALL_MRP_DATA_BUFFER .
  methods CLEAR_MRP_DATA
    importing
      !IF_BERID type BERID optional .
protected section.

  data MT_MRP_DATA type ZIF_WERKS_MATERIAL~TT_MRP_DATA .

  methods READ_MRP_DATA
    importing
      !IF_BERID type BERID .
  methods DETERMINE_MAPPING
    changing
      !CS_MRP type ZIF_WERKS_MATERIAL~TS_MRP_DATA .
private section.

  data MR_ALERTS type ref to /GIB/CL_DCP_DCO_MATERIAL_ALERT .
  class-data GT_WERKS_MATERIALS type TT_WERKS_MATERIAL .
  class-data GF_ONLY_USE_STOCK_REQ_LIST type XFELD value ABAP_FALSE ##NO_TEXT.

  methods READ_DCO_ALERTS
    raising
      /GIB/CX_ROOT .
  methods READ_DCO_MARC .
  methods READ_FTIND .
  methods READ_MARC .
  methods READ_MKAL .
  methods READ_MSFCV .
  methods READ_TCO43 .
ENDCLASS.

CLASS ZCL_WERKS_MATERIAL IMPLEMENTATION.

  METHOD zif_werks_material~get_mrp_data.
    CLEAR: es_mrp_data.
    IF if_refresh = abap_true.
      CLEAR: mt_mrp_data.
    ENDIF.
    READ TABLE mt_mrp_data INTO es_mrp_data WITH TABLE KEY werks = mr_werks->mf_werks
                                                           matnr = mr_matnr->ms_mara-matnr
                                                           berid = if_berid.
    IF sy-subrc <> 0.
      read_mrp_data( if_berid ).
      READ TABLE mt_mrp_data INTO es_mrp_data WITH TABLE KEY werks = mr_werks->mf_werks
                                                             matnr = mr_matnr->ms_mara-matnr
                                                             berid = if_berid.
    ENDIF.

  ENDMETHOD.

  METHOD zif_werks_material~get_mrp_exceptions.

    DATA: ls_dispo_fa TYPE /gib/dcp_dispo_fa_s.

    CLEAR: et_dispo_fa.
    get_mrp_data( EXPORTING if_berid = if_berid
                            if_refresh = if_refresh
                  IMPORTING es_mrp_data = DATA(ls_mrp) ).

    LOOP AT ls_mrp-mdez_t ASSIGNING FIELD-SYMBOL(<ls_mdez>)
                     WHERE ( delkz = 'FE'
                     OR      delkz = 'PA'
                     OR      delkz = 'BR' )
                     AND     auskt <> space.
      READ TABLE ls_mrp-mdps_t ASSIGNING FIELD-SYMBOL(<ls_mdps>) INDEX <ls_mdez>-aline.
      IF sy-subrc = 0.
        CLEAR: ls_dispo_fa.
        MOVE-CORRESPONDING <ls_mdps> TO ls_dispo_fa.        "#EC ENHOK
        IF <ls_mdez>-delkz = 'PA'.
          ls_dispo_fa-aufnr = <ls_mdps>-delnr.
        ELSE.
          ls_dispo_fa-aufnr = <ls_mdps>-del12.
        ENDIF.
        ls_dispo_fa-auskt = <ls_mdez>-auskt.
        ls_dispo_fa-umdat = <ls_mdez>-umdat.
        APPEND ls_dispo_fa TO et_dispo_fa.
      ENDIF.
    ENDLOOP.
    SORT et_dispo_fa BY aufnr auskt.

  ENDMETHOD.

  METHOD constructor.
    mr_werks = ir_werks.
    mr_matnr = ir_matnr.
    read_marc( ).
    read_mkal( ).
    read_dco_marc( ).
    read_ftind( ).
    IF mr_matnr->ms_mara-matnr IS NOT INITIAL.
      read_msfcv( ).
      read_tco43( ).
    ENDIF.
    TRY.
        read_dco_alerts( ).
      CATCH /gib/cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD get_instance.
    DATA: lr_matnr TYPE REF TO zif_material.

    READ TABLE gt_werks_materials ASSIGNING FIELD-SYMBOL(<ls_werks_material>)
      WITH TABLE KEY werks = ir_werks->mf_werks  matnr = if_matnr.
    IF sy-subrc = 0.
      rr_matnr = <ls_werks_material>-werks_material.
    ELSE.
      lr_matnr = zcl_material=>get_instance( if_matnr ).
      CREATE OBJECT rr_matnr TYPE zcl_werks_material
        EXPORTING
          ir_werks = ir_werks
          ir_matnr = lr_matnr.
      INSERT VALUE #( werks = ir_werks->mf_werks
                      matnr = if_matnr
                      werks_material = rr_matnr ) INTO TABLE gt_werks_materials.
    ENDIF.
  ENDMETHOD.

  METHOD has_planning_file_entry.

    DATA: ls_mdvm TYPE mdvm,                  "#EC CI_USAGE_OK[2227059]
          BEGIN OF ls_mdkey,
            disst TYPE disst,
            matnr TYPE matnr,
            werks TYPE werks_d,
          END OF ls_mdkey,
          lf_mdkey TYPE mdkey.

    CLEAR: ef_planv.
    ls_mdkey-disst = mr_matnr->ms_mara-disst.
    ls_mdkey-matnr = ms_marc-matnr.          "#EC CI_FLDEXT_OK[2215424]
    ls_mdkey-werks = mr_werks->mf_werks.
    lf_mdkey = ls_mdkey.                     "#EC CI_FLDEXT_OK[2215424]
    IF /gib/cl_dcp_settings=>is_mrp_area_active( ) = abap_true.
      SELECT SINGLE gsaen akken FROM dbvm INTO CORRESPONDING FIELDS OF ls_mdvm "#EC CI_USAGE_OK[2227059]
        WHERE matnr = ls_mdkey-matnr          "#EC CI_USAGE_OK[2227059]
          AND berid = if_berid                "#EC CI_USAGE_OK[2227059]
          AND disst = ls_mdkey-disst          "#EC CI_USAGE_OK[2227059]
          AND mafid = 'B'.                    "#EC CI_USAGE_OK[2227059]
      IF ls_mdvm-gsaen = 'X'
        OR ls_mdvm-akken = 'X'.
        ef_planv = 'X'.
      ELSE.
        SELECT SINGLE gsaen akken                       "#EC CI_NOORDER
          FROM dbvl INTO CORRESPONDING FIELDS OF ls_mdvm "#EC CI_USAGE_OK[2227059]
          WHERE matnr = ls_mdkey-matnr        "#EC CI_USAGE_OK[2227059]
            AND berid = if_berid              "#EC CI_USAGE_OK[2227059]
            AND disst = ls_mdkey-disst        "#EC CI_USAGE_OK[2227059]
            AND mafid = 'B'.                  "#EC CI_USAGE_OK[2227059]
        IF ls_mdvm-gsaen = 'X'
          OR ls_mdvm-akken = 'X'.
          ef_planv = 'X'.
        ENDIF.
      ENDIF.
    ELSE.
      SELECT SINGLE gsaen akken FROM mdvm INTO CORRESPONDING FIELDS OF ls_mdvm "#EC CI_USAGE_OK[2227059]
        WHERE mafid = 'B'                     "#EC CI_USAGE_OK[2227059]
          AND mdkey = lf_mdkey.               "#EC CI_USAGE_OK[2227059]
      IF ls_mdvm-gsaen = 'X'
        OR ls_mdvm-akken = 'X'.
        ef_planv = 'X'.
      ELSE.
        SELECT SINGLE gsaen akken FROM mdvl             "#EC CI_NOORDER
          INTO CORRESPONDING FIELDS OF ls_mdvm "#EC CI_USAGE_OK[2227059]
          WHERE mafid = 'B'                   "#EC CI_USAGE_OK[2227059]
            AND mdkey = lf_mdkey.             "#EC CI_USAGE_OK[2227059]
        IF ls_mdvm-gsaen = 'X'
          OR ls_mdvm-akken = 'X'.
          ef_planv = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD read_marc.
    CALL FUNCTION 'MARC_SINGLE_READ'
      EXPORTING
        matnr             = mr_matnr->ms_mara-matnr
        werks             = mr_werks->mf_werks
      IMPORTING
        wmarc             = ms_marc
      EXCEPTIONS
        lock_on_marc      = 1
        lock_system_error = 2
        wrong_call        = 3
        not_found         = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD read_mkal.
    CALL FUNCTION 'MKAL_GENERIC_READ_MATNR_PLANT' "#EC CI_SUBRC
      EXPORTING
        matnr      = mr_matnr->ms_mara-matnr
        werks      = mr_werks->mf_werks
      TABLES
        mkal_tab   = mt_mkal
      EXCEPTIONS
        wrong_call = 1
        not_found  = 2
        OTHERS     = 3.
    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.

  METHOD read_mrp_data.
    CHECK mr_matnr->ms_mara-matnr IS NOT INITIAL.
    DATA: ls_mrp TYPE zif_werks_material~ts_mrp_data.
    DATA: lf_ergbz TYPE ergbz.

    DATA: lf_filter_active TYPE xfeld.

    SELECT SINGLE ergbz dfilt FROM t449u INTO (lf_ergbz, lf_filter_active)
      WHERE uname = sy-uname.
    IF sy-subrc <> 0
      OR lf_filter_active = abap_false.
      CLEAR: lf_ergbz.
    ENDIF.
    ls_mrp-matnr = mr_matnr->ms_mara-matnr.
    ls_mrp-werks = mr_werks->mf_werks.
    ls_mrp-berid = if_berid.
    DELETE mt_mrp_data
      WHERE matnr = ls_mrp-matnr
        AND werks = ls_mrp-werks
        AND berid = ls_mrp-berid.
    IF has_planning_file_entry( if_berid ) = abap_true
       OR gf_only_use_stock_req_list = abap_true.

      CALL FUNCTION 'MD_STOCK_REQUIREMENTS_LIST_API' "#EC CI_USAGE_OK[2438110]
        EXPORTING                                    "#EC CI_USAGE_OK[2227532]
          matnr  = ls_mrp-matnr                      "#EC CI_USAGE_OK[2227579]
          werks  = ls_mrp-werks                      "#EC CI_USAGE_OK[3211383]
          berid  = ls_mrp-berid
          nobuf  = 'X'
          ergbz  = lf_ergbz
        IMPORTING
          e_mdkp = ls_mrp-mdkp
        TABLES
          mdpsx  = ls_mrp-mdps_t
          mdezx  = ls_mrp-mdez_t
        EXCEPTIONS
          OTHERS = 0.

    ELSE.
      CALL FUNCTION 'MD_MRP_LIST_API'
        EXPORTING
          matnr                    = ls_mrp-matnr
          werks                    = ls_mrp-werks
          berid                    = ls_mrp-berid
        IMPORTING
          e_mdkp                   = ls_mrp-mdkp
        TABLES
          mdpsx                    = ls_mrp-mdps_t
          mdezx                    = ls_mrp-mdez_t
        EXCEPTIONS
          mrp_list_not_found       = 1
          material_plant_not_found = 2
          error                    = 3
          error_message            = 4
          OTHERS                   = 5.
      IF sy-subrc <> 0.
        CALL FUNCTION 'MD_STOCK_REQUIREMENTS_LIST_API' "#EC CI_USAGE_OK[2227579]
          EXPORTING                                    "#EC CI_USAGE_OK[2438110]
            matnr  = ls_mrp-matnr                      "#EC CI_USAGE_OK[2227532]
            werks  = ls_mrp-werks                      "#EC CI_USAGE_OK[3211383]
            berid  = ls_mrp-berid
            nobuf  = 'X'
            ergbz  = lf_ergbz
          IMPORTING
            e_mdkp = ls_mrp-mdkp
          TABLES
            mdpsx  = ls_mrp-mdps_t
            mdezx  = ls_mrp-mdez_t
          EXCEPTIONS
            OTHERS = 0.

      ENDIF.
    ENDIF.

*# Check if there is no information about secondary requirements according to SAP Note 2423930
    IF gf_only_use_stock_req_list = abap_false.
      LOOP AT ls_mrp-mdps_t ASSIGNING FIELD-SYMBOL(<ls_mdps>)
       WHERE delkz = /gib/cl_dcp_mrp_element=>co_delkz_secondary_requirement AND aufvr = 'DUMMY'.
        gf_only_use_stock_req_list = abap_true.
        read_mrp_data( if_berid = if_berid ).
        RETURN.
      ENDLOOP.
    ENDIF.

    INSERT ls_mrp INTO TABLE mt_mrp_data.

  ENDMETHOD.

  METHOD read_msfcv.
    TYPES: BEGIN OF ts_dummy,       "Dummy-Tabelle für den Funktions-
             row TYPE sy-tabix.        "baustein
    TYPES: END OF ts_dummy.
    DATA: ls_mtcom TYPE mtcom,
          lt_dummy TYPE TABLE OF ts_dummy.

    CHECK  mr_matnr->ms_mara-matnr IS NOT INITIAL.
    ls_mtcom-matnr = mr_matnr->ms_mara-matnr.
    ls_mtcom-werks = mr_werks->mf_werks.
    ls_mtcom-kenng = 'MSFCV'.

    CALL FUNCTION 'MATERIAL_READ' "#EC CI_FLDEXT_OK[2215424]
      EXPORTING
        schluessel = ls_mtcom
      IMPORTING
        matdaten   = ms_msfcv
        return     = ms_mtcor
      TABLES
        seqmat01   = lt_dummy
      EXCEPTIONS
        OTHERS     = 0.

  ENDMETHOD.

  METHOD read_tco43.
    IF ms_msfcv-sfcpf IS NOT INITIAL.
      CALL FUNCTION 'TCO43_SINGLE_READ'
        EXPORTING
          tco43_werks      = mr_werks->mf_werks
          tco43_co_prodprf = ms_msfcv-sfcpf
        IMPORTING
          wtco43           = ms_tco43
        EXCEPTIONS
          OTHERS           = 0.

    ENDIF.
  ENDMETHOD.

  METHOD add_to_buffer.
    CHECK it_marc_head IS NOT INITIAL.

    DATA: lt_mara_head TYPE zif_material=>tt_mara_head,
          ls_mara_head TYPE pre03.
    DATA(lt_marc_head) = it_marc_head."FUBA will change the Importing table

    LOOP AT lt_marc_head ASSIGNING FIELD-SYMBOL(<ls_marc_head>)
      WHERE matnr IS NOT INITIAL.
      ls_mara_head-matnr = <ls_marc_head>-matnr.
      COLLECT ls_mara_head INTO lt_mara_head.
    ENDLOOP.

    "first buffer the material and short texts
    zcl_material=>add_to_buffer( lt_mara_head ).

    CALL FUNCTION 'MARC_ARRAY_READ'
      TABLES
        ipre01               = lt_marc_head
      EXCEPTIONS
        enqueue_mode_changed = 1
        lock_on_marc         = 2
        lock_system_error    = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD clear_mrp_data.

    IF if_berid IS NOT INITIAL.
      DELETE mt_mrp_data USING KEY primary_key WHERE matnr = mr_matnr->ms_mara-matnr
                                                 AND werks = mr_werks->mf_werks
                                                 AND berid = if_berid.
    ELSE.
      CLEAR mt_mrp_data.
    ENDIF.
  ENDMETHOD.

  METHOD determine_mapping.

  ENDMETHOD.

  METHOD read_dco_marc.
    SELECT matnr werks berid plscn btextn btextl FROM /gib/dco_marc INTO CORRESPONDING FIELDS OF TABLE mt_dco_marc
      WHERE matnr = mr_matnr->ms_mara-matnr
      AND   werks = mr_werks->mf_werks
      AND   plscn = '000'.
  ENDMETHOD.

  METHOD read_ftind.
    SELECT werks matnr rsnum rspos rsart bdter aufnr FROM ftind INTO CORRESPONDING FIELDS OF TABLE mt_ftind
      WHERE werks = mr_werks->mf_werks
      AND   matnr = mr_matnr->ms_mara-matnr.
  ENDMETHOD.

  METHOD clear_all_mrp_data_buffer.
*# Clears all MRP Data Buffer
    DATA: lr_werks_material TYPE REF TO zcl_werks_material.
    LOOP AT gt_werks_materials ASSIGNING FIELD-SYMBOL(<ls_werks_materials>).
      TRY.
          lr_werks_material ?= <ls_werks_materials>-werks_material.
          lr_werks_material->clear_mrp_data( ).
        CATCH cx_sy_move_cast_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_dco_alerts.
    mr_alerts = NEW /gib/cl_dcp_dco_material_alert( if_werks = mr_werks->mf_werks
                                                    if_matnr = mr_matnr->ms_mara-matnr ).

    mr_alerts->read_data( ).

  ENDMETHOD.

  METHOD get_dco_alerts.
    er_alerts = mr_alerts.

  ENDMETHOD.
ENDCLASS.
