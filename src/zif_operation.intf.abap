interface ZIF_OPERATION
  public .

  interfaces ZIF_AMOUNTS .
  interfaces ZIF_JSTATUS .
  interfaces ZIF_LONG_TEXT .

  aliases CO_CLSD
    for ZIF_JSTATUS~CO_CLSD .
  aliases CO_CNF
    for ZIF_JSTATUS~CO_CNF .
  aliases CO_CREF
    for ZIF_JSTATUS~CO_CREF .
  aliases CO_CRTD
    for ZIF_JSTATUS~CO_CRTD .
  aliases CO_DLFL
    for ZIF_JSTATUS~CO_DLFL .
  aliases CO_DLT
    for ZIF_JSTATUS~CO_DLT .
  aliases CO_DLV
    for ZIF_JSTATUS~CO_DLV .
  aliases CO_DSPT
    for ZIF_JSTATUS~CO_DSPT .
  aliases CO_EXTS
    for ZIF_JSTATUS~CO_EXTS .
  aliases CO_FREE
    for ZIF_JSTATUS~CO_FREE .
  aliases CO_ILAS
    for ZIF_JSTATUS~CO_ILAS .
  aliases CO_LKD
    for ZIF_JSTATUS~CO_LKD .
  aliases CO_MSPT
    for ZIF_JSTATUS~CO_MSPT .
  aliases CO_NSCH
    for ZIF_JSTATUS~CO_NSCH .
  aliases CO_NTUP
    for ZIF_JSTATUS~CO_NTUP .
  aliases CO_PCNF
    for ZIF_JSTATUS~CO_PCNF .
  aliases CO_PRT
    for ZIF_JSTATUS~CO_PRT .
  aliases CO_TECO
    for ZIF_JSTATUS~CO_TECO .
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
    tt_activities TYPE STANDARD TABLE OF corutcact WITH DEFAULT KEY .
  types TT_PRT_ITEM type /GIB/DCP_PRT_ITEM_T .
  types:
    tt_operation_phases TYPE TABLE OF cxopr_gr .

  data MR_ORDER type ref to ZIF_ORDER read-only .
  data MR_WORKCENTER type ref to ZCL_ARBID read-only .
  data MS_AFVGD type AFVGD read-only .
  data MT_KBED type CYKBEDD read-only .
  data MF_VORNR type VORNR read-only .
  data:
    mt_fhm TYPE TABLE OF affhd read-only .
  data MR_SEQUANCE type ref to ZIF_OPERATION_SEQUANCE read-only .
  constants CON_MSGTY_WARNING type SYMSGTY value 'W' ##NO_TEXT.
  constants CON_MSGTY_ERROR type SYMSGTY value 'E' ##NO_TEXT.
  constants CON_MSGTY_SUCCESS type SYMSGTY value 'S' ##NO_TEXT.
  constants CON_MSGTY_INFO type SYMSGTY value 'I' ##NO_TEXT.
  data MS_AKT_OPR_SAV type AFVGD read-only .

  methods CHANGE_WORKCENTER
    importing
      !IR_NEW type ref to ZCL_ARBID
      !IF_NO_ORDER_SCHEDULE type XFELD optional
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      /GIB/CX_DCP .
  methods MIDPOINT_SCHEDULE
    importing
      !IF_PIT type /GIB/PIT
      !IF_FORWARD type FLAG default 'X'
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      /GIB/CX_DCP .
  methods GET_SUCCESSOR
    returning
      value(RR_SUCCESSOR) type ref to ZIF_OPERATION
    raising
      ZCX_NO_SUCCESSOR .
  methods GET_PREDECESSOR
    returning
      value(RR_PREDECESSOR) type ref to ZIF_OPERATION
    raising
      ZCX_NO_PREDECESSOR .
  methods REFRESH .
  methods DIALOG
    raising
      /GIB/CX_DCP .
  methods CHANGE_STANDARD_VALUES
    importing
      !IF_VGW01 type VGWRT optional
      !IF_VGE01 type VGWRTEH optional
      !IF_VGW02 type VGWRT optional
      !IF_VGE02 type VGWRTEH optional
      !IF_VGW03 type VGWRT optional
      !IF_VGE03 type VGWRTEH optional
      !IF_VGW04 type VGWRT optional
      !IF_VGE04 type VGWRTEH optional
      !IF_VGW05 type VGWRT optional
      !IF_VGE05 type VGWRTEH optional
      !IF_VGW06 type VGWRT optional
      !IF_VGE06 type VGWRTEH optional
    returning
      value(ER_PROTOCOL) type ref to ZCL_MSG
    raising
      /GIB/CX_DCP .
  methods CHANGE_STANDARD_VALUE
    importing
      !IF_NO type Z_VGWNR
      !IF_VALUE type VGWRT
      !IF_UNIT type VGWRTEH
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      /GIB/CX_DCP .
  methods CHANGE_STANDARD_VALUES_DIALOG
    raising
      /GIB/CX_DCP .
  methods DISPATCH_MIDPOINT
    importing
      !IF_PIT type /GIB/PIT
      !IF_FORWARD type FLAG default 'X'
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      /GIB/CX_DCP .
  methods DEALLOCATE
    returning
      value(RR_PROTOCOL) type ref to ZCL_MSG
    raising
      /GIB/CX_DCP .
  methods GET_EARLIEST_START
    returning
      value(RF_PIT) type /GIB/PIT .
  methods GET_EARLIEST_END
    returning
      value(RF_PIT) type /GIB/PIT .
  methods GET_LATEST_START
    returning
      value(RF_PIT) type /GIB/PIT .
  methods GET_LATEST_END
    returning
      value(RF_PIT) type /GIB/PIT .
  methods IS_MAIN_OPERATION
    returning
      value(RF_ANSWER) type FLAG .
  methods GET_VERIDS_FOR_WORKCENTER
    importing
      !IR_WORKCENTER type ref to ZCL_ARBID
      !IF_TARGET_DATE type SY-DATUM optional
    exporting
      !ET_MKAL type CURTO_MKAL_T .
  methods UPDATE_SUBOBJECTS
    raising
      /GIB/CX_DCP .
  methods SCHEDULE
    importing
      !IF_FORWARD type FLAG default 'X'
      !IF_PIT type /GIB/PIT
    exporting
      !ET_OPERATION_PHASES type TT_OPERATION_PHASES
    changing
      !CS_AFVGD type AFVGD .
  methods GET_FIRST_PRODUCTION_AID
    returning
      value(ES_FHM) type Z_FHMX .
  methods GET_CONFIRMATION_API
    returning
      value(RR_CONFIRMATION_API) type ref to ZIF_CONFIRMATION_API .
  methods IS_DELIVERY_OPERATION
    returning
      value(RF_RESULT) type ABAP_BOOL .
  methods GET_PRODUCTION_AID
    exporting
      !ET_FHM type ZIF_ORDER=>TT_FHM
      !ET_PRT_ITEM type TT_PRT_ITEM .
  methods UPDATE_PRODUCTION_AID
    importing
      !IS_FHM type Z_FHMX .
  methods RELEASE
    importing
      !IR_MSG type ref to OBJECT optional .
  methods GET_TOTAL_ACTIVITIES
    returning
      value(RT_ECTIVITIES) type TT_ACTIVITIES .
  methods BTAB_AFVGD_UPDATE_MAIN
    importing
      !IF_FORWARD type FLAG default 'X'
      !IF_SIMPLE type FLAG default 'X'
    changing
      !CS_AFVGD type AFVGD
      !CF_TABIX_NEW type SY-TABIX .
  methods MESSAGE_TAB_STORE
    importing
      !IF_VORN2 type AFVGD-UVORN
      !IF_MSGNO type SYMSGNO
      !IF_MSGTY type SYMSGTY
      !IF_MSGV1 type SYMSGV1
      !IF_MSGV2 type SYMSGV2
      !IF_MSGV3 type SYMSGV3
      !IF_MSGV4 type SYMSGV4
      !IS_MSG type Z_OPERATION_MSG .
endinterface.
