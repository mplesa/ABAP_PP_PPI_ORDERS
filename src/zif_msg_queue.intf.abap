interface ZIF_MSG_QUEUE
  public .

  types:
    TT_TYPE_RA type range of symsgty .
  types:
    begin of TS_MSG,
      type    type symsgty,
      id      type symsgid,
      no      type symsgno,
      v1      type symsgv,
      v2      type symsgv,
      v3      type symsgv,
      v4      type symsgv,
      message type bapi_msg,
    end of TS_MSG .
  types:
    TT_MSG type standard table of TS_MSG with default key .

  constants CO_ERROR type SYMSGTY value 'E' ##NO_TEXT.
  constants CO_SUCCESS type SYMSGTY value 'S' ##NO_TEXT.
  constants CO_STATUS type SYMSGTY value 'S' ##NO_TEXT.
  constants CO_INFO type SYMSGTY value 'I' ##NO_TEXT.
  constants CO_WARNING type SYMSGTY value 'W' ##NO_TEXT.
  constants CO_ABEND type SYMSGTY value 'A' ##NO_TEXT.
  constants CO_BATCH_LIST_TYPE_JOBLOG type CHAR1 value 'J' ##NO_TEXT.
  constants CO_BATCH_LIST_TYPE_SPOOL type CHAR1 value 'L' ##NO_TEXT.
  constants CO_BATCH_LIST_TYPE_BOTH type CHAR1 value 'B' ##NO_TEXT.

  methods ADD_MSG
    importing
      !IF_MID type SY-MSGID optional
      !IF_NUM type SY-MSGNO
      !IF_PA1 type ANY optional
      !IF_PA2 type ANY optional
      !IF_PA3 type ANY optional
      !IF_PA4 type ANY optional
      !IF_TYP type SY-MSGTY default 'S'
      !IF_NO_DUPLICATE type XFLAG optional
      !IF_ERDAT type ERDAT optional
      !IF_ERZEIT type ERZEIT optional .
  methods ADD_SYMSG
    importing
      !IF_NO_DUPLICATE type XFELD optional .
  methods ADD_BAPIRETURN
    importing
      !IT_BAPIRET2 type BAPIRET2_T .
  methods ADD_EXCEPTION_MSG
    importing
      !IR_EXCEPTION type ref to CX_ROOT
      !IF_MSGTY type MSGTY default 'E'
      !IF_NO_DUPLICATE type XFELD default ' ' .
  methods ADD_BDCMSGCOLL
    importing
      !IT_MSG type WDKMSG_TTY .
  methods ADD_TEXT
    importing
      !IT_TEXT type TABLE
      !IF_MSGTYP type SY-MSGTY default 'S' .
  methods ADD_MSG_QUEUE
    importing
      !IR_MSG type ref to ZIF_MSG_QUEUE
      !IF_NO_DUPLICATE type XFELD default ' ' .
  methods GET_COUNT
    returning
      value(EF_COUNT) type SY-TABIX .
  methods GET_MAX_SEVERITY
    returning
      value(EF_MSG_TYPE) type SY-MSGTY .
  methods GET_MSG_TAB
    importing
      !IF_SPRAS type SY-LANGU default SY-LANGU
    returning
      value(ET_MSG) type TT_MSG .
  methods GET_BAPIRETURN
    exporting
      !ET_MSG type BAPIRET2_T .
  methods HAS_TYPE
    importing
      !IF_TYPE type SY-MSGTY optional
      !IT_TYPE_RA type TT_TYPE_RA optional
    returning
      value(EF_HAS_TYPE) type XFELD .
  methods HAS_ERROR
    returning
      value(EF_ERROR) type XFELD .
  methods DELETE_MSG
    importing
      !IF_MSGID type MSGID
      !IF_MSGNO type MSGNO .
  methods SHOW
    importing
      !IF_USE_GRID type XFELD default 'X'
      !IT_TYPE_FILTER type TT_TYPE_RA optional
      !IF_TITLE type C optional
      !IF_BATCH_LIST_TYPE type CHAR1 default 'J'
      !IF_END_JOB_ON_ERROR type XFELD optional
    returning
      value(EF_CANCEL) type XFELD .
  methods RESET .
endinterface.
