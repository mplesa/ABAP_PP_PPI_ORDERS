interface ZIF_ORDER
  public .

  interfaces ZIF_AMOUNTS .
  interfaces ZIF_JSTATUS .
  interfaces ZIF_LONG_TEXT .

  aliases MT_STATUSES
    for ZIF_JSTATUS~MT_STATUSES .
  aliases DISPLAY_LONG_TEXT
    for ZIF_LONG_TEXT~DISPLAY .
  aliases EDIT_LONG_TEXT
    for ZIF_LONG_TEXT~EDIT .
  aliases HAS_LONG_TEXT
    for ZIF_LONG_TEXT~HAS_LONG_TEXT .
  aliases HAS_STATUS
    for ZIF_JSTATUS~HAS_STATUS .
  aliases REMOVE_STATUS
    for ZIF_JSTATUS~REMOVE_STATUS .
  aliases SET_STATUS
    for ZIF_JSTATUS~SET_STATUS .

  types:
    tt_fehl_kap TYPE STANDARD TABLE OF cyfehl_kap WITH DEFAULT KEY .
  types:
    tt_missing_parts TYPE TABLE OF mdva .
  types:
    tt_fhm TYPE TABLE OF z_fhmx .
  types:
    tt_operations TYPE TABLE OF REF TO zif_operation .
  types:
    tt_operation_sequances TYPE TABLE OF REF TO zif_operation_sequance .
  types:
    BEGIN OF ts_afvgd,
      aufpl TYPE  co_aufpl,
      aplzl TYPE  co_aplzl,
      banfn TYPE  co_banfn,
      bnfpo TYPE  co_bnfpo,
      sumnr TYPE sumkntnr,
      bedid TYPE bedid,
      bedzl TYPE cim_count,
      arbid TYPE cr_objid,
    END OF ts_afvgd .
  types:
    tt_afvgd TYPE TABLE OF ts_afvgd .
  types:
    tt_afvgd_sub TYPE SORTED TABLE OF ts_afvgd WITH NON-UNIQUE KEY sumnr arbid .
  types:
    tf_change_quantity_mode TYPE c LENGTH 1 .

  data MT_AFVGD_SUB type TT_AFVGD read-only .
  data MT_AFVGD type TT_AFVGD read-only .
  data MT_OPERATIONS type TT_OPERATIONS read-only .
  data MT_OPERATION_SEQUANCES type TT_OPERATION_SEQUANCES read-only .
  data MR_MATERIAL type ref to ZIF_WERKS_MATERIAL read-only .
  data MF_PLNID type Z_PLNID read-only .
  data MF_SART type Z_SART read-only .
  data MS_CAUFVD type CAUFVD read-only .
  data MS_AFPOD type AFPOD read-only .
  data MS_KBKO type KBKO .                    "#EC CI_USAGE_OK[2380568]
  data MS_TCX00 type TCX00 read-only .
  data MR_PEGGED_REQUIREMENT type ref to ZIF_PEGGED_REQUIREMENT read-only .
  constants:
    BEGIN OF co_autyp,
      prodo     TYPE auftyp VALUE '10',
      network   TYPE auftyp VALUE '20',
      iho       TYPE auftyp VALUE '30',
      process   TYPE auftyp VALUE '40',
      personnel TYPE auftyp VALUE '60',
    END OF co_autyp .
  constants:
    BEGIN OF co_vbkz,
      insert TYPE vbkz VALUE 'I',
      update TYPE vbkz VALUE 'U',
      delete TYPE vbkz VALUE 'D',
    END OF co_vbkz .
  constants:
    BEGIN OF co_authority,
      edit    TYPE aktyp VALUE 'V',
      display TYPE aktyp VALUE 'A',
      none    TYPE aktyp VALUE '1',
    END OF co_authority .
  constants:
    BEGIN OF co_change_quantity_mode,
      gross TYPE c VALUE 'G',
      net   TYPE c VALUE 'N',
      scrap TYPE c VALUE 'S',
    END OF co_change_quantity_mode .
  data MT_AFFL type ZIF_OPERATION_SEQUANCE=>TT_AFFL read-only .
  class-data:
    gt_scheduling_type TYPE SORTED TABLE OF t482 WITH UNIQUE KEY termkz .
  constants CO_DISPO_RELEVANCE_NO type AUDISP_PLUS value '1' ##NO_TEXT.
  constants CO_DISPO_RELEVANCE_AT_RELEASE type AUDISP_PLUS value '2' ##NO_TEXT.
  constants CO_DISPO_RELEVANCE_YES type AUDISP_PLUS value '3' ##NO_TEXT.
  data MR_ROUTING_MASTER type ref to ZIF_ROUTING_MASTER .

  events TEMP_AUFNR_CHANGED
    exporting
      value(EF_AUFNR) type AUFNR .

  methods CHANGE_PRODUCTION_VERSION
    importing
      !IF_NEW_VERID type VERID
      !IF_TARGET_DATE type SY-DATUM optional
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods CHANGE_SEQUENCE_NUMBER
    importing
      !IF_SEQUENCE_NUMBER type CY_SEQNR
    raising
      ZCX_CORE .
  methods CHANGE_BATCH
    importing
      !IF_CHARG type MCHA-CHARG
    raising
      ZCX_CORE .
  methods GET_SUCCESSOR_OPERATION
    importing
      !IR_OPERATION type ref to ZIF_OPERATION
    returning
      value(RR_SUCCESSOR) type ref to ZIF_OPERATION
    raising
      ZCX_NO_SUCCESSOR .
  methods GET_PREDECESSOR_OPERATION
    importing
      !IR_OPERATION type ref to ZIF_OPERATION
    returning
      value(RR_PREDECESSOR) type ref to ZIF_OPERATION
    raising
      ZCX_NO_PREDECESSOR .
  methods GET_OPERATION
    importing
      !IF_VORNR type VORNR optional
      !IF_SEQUENCE type APLFL default ZIF_OPERATION_SEQUANCE=>CO_STANDARD_SEQUANCE
      !IF_APLZL type CO_APLZL optional
    returning
      value(RR_OPERATION) type ref to ZIF_OPERATION
    raising
      ZCX_OPERATION_NOTFOUND .
  methods GET_FIRST_OPERATION
    importing
      !IF_SEQUENCE type APLFL default ZIF_OPERATION_SEQUANCE=>CO_STANDARD_SEQUANCE
    returning
      value(RR_OPERATION) type ref to ZIF_OPERATION
    raising
      ZCX_OPERATION_NOTFOUND .
  methods GET_LAST_OPERATION
    importing
      !IF_SEQUENCE type APLFL default ZIF_OPERATION_SEQUANCE=>CO_STANDARD_SEQUANCE
    returning
      value(RR_OPERATION) type ref to ZIF_OPERATION
    raising
      ZCX_OPERATION_NOTFOUND .
  methods GET_DELIVERY_OPERATION
    importing
      !IF_SEQUENCE type APLFL default ZIF_OPERATION_SEQUANCE=>CO_STANDARD_SEQUANCE
    returning
      value(RR_OPERATION) type ref to ZIF_OPERATION
    raising
      ZCX_OPERATION_NOTFOUND .
  methods SCHEDULE
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods REFRESH .
  methods DIALOG
    raising
      ZCX_CORE .
  methods START_UPDATE
    raising
      ZCX_ORDER_LOCKED .
  methods CHANGE_PROD_VERSION_DIALOG
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods CHANGE_TOTAL_QUANTITY
    importing
      !IF_VALUE type CAUFVD-GAMNG    "GAMNG
      !IF_GASMG type CAUFVD-GASMG default -1
      !IR_PROTOCOL type ref to ZCL_MSG optional
    raising
      ZCX_CORE .
  methods CHANGE_TOTAL_QUAN_DIALOG
    importing
      !IR_PROTOCOL type ref to ZCL_MSG optional
      !IF_MODE type TF_CHANGE_QUANTITY_MODE optional
    preferred parameter IR_PROTOCOL
    raising
      ZCX_CORE .
  methods RELEASE
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods GET_LEAD_PLNID
    returning
      value(RF_PLNID) type /GIB/DCP_LEAD_PLNID .
  methods GET_UPDATE_KEY
    returning
      value(RF_VBKZ) type VBKZ .
  methods GET_COMPRESSION_TABLE
    returning
      value(RR_COMPRESSION) type ref to Z_OP_COMPRESSION_T .
  methods GET_BASIC_START
    returning
      value(RF_PIT) type Z_PIT .
  methods GET_BASIC_END
    returning
      value(RF_PIT) type Z_PIT .
  methods SCHEDULE_BASIC_DATES
    importing
      !IF_PIT type Z_PIT
      !IS_SCHEDULING_TYPE type T482
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods SCHEDULE_BASIC_DATES_DIALOG
    importing
      !IF_PIT type Z_PIT optional
      !IS_SCHEDULING_TYPE type T482 optional
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods GET_GRANTED_AUTHORITY
    returning
      value(RF_AUTHORITY) type AKTYP .
  methods GET_PRODUCTION_AIDS
    exporting
      !ET_FHM type TT_FHM .
  methods GET_OPERATIONS
    importing
      !IF_SEQUENCE type APLFL default ZIF_OPERATION_SEQUANCE=>CO_STANDARD_SEQUANCE
    exporting
      !ET_OPERATIONS type TT_OPERATIONS .
  methods CHECK_MATERIAL_AVAILABILITY
    importing
      !IR_MISSING_PARTS type ref to DATA optional
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      ZCX_CORE .
  methods CHANGE_TEMP_AUFNR
    importing
      !IF_NEW_AUFNR type AUFNR .
  methods GET_ORDER_AMOUNT
    returning
      value(EF_GAMNG) type GAMNG .
  methods GET_PRODUCTION_VERSIONS
    importing
      !IF_DATE type DATUM default SY-DATUM
    exporting
      !ET_MKAL type CURTO_MKAL_T .
  methods GET_ROUTING_MASTER
    returning
      value(RR_ROUTING_MASTER) type ref to ZIF_ROUTING_MASTER .
  methods GET_ENQUEUE_STATUS
    returning
      value(EF_ENQUEUE) type XFELD .
  methods CHECK_CAPACITY_AVAILABILITY
    importing
      !IF_PROFILE_ID type CY_GESPROF optional
      !IF_NO_DIALOG type FLAG default ABAP_TRUE
      !IR_MSG type ref to ZCL_MSG
    returning
      value(RT_FEHL_KAP) type TT_FEHL_KAP
    raising
      ZCX_CORE .
endinterface.
