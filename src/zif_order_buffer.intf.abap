interface ZIF_ORDER_BUFFER
  public .

  interfaces ZIF_ORDER_STACK .

  types:
    TT_AUFNR type TABLE OF aufnr .
  types:
    tt_plnum TYPE TABLE OF plnum .
  types:
    TT_ORDERS type TABLE OF REF TO zif_order .

  data MT_ORDERS type TT_ORDERS read-only .
  data MF_COMMIT_LOCK type CHAR1 read-only .

  class-methods POST
    importing
      !IF_NO_COMMIT_WORK type FLAG optional
      !IF_WAIT type FLAG default 'X'
    exporting
      !ET_CHANGED_ORDERS type CAUFVDN_T
      !ER_MSG type ref to /GIB/IF_MSG_QUEUE .
  class-methods WAS_POST_CALLED
    returning
      value(RF_ANSWER) type FLAG .
  methods ADD_ORDERS
    importing
      !IT_AUFNR type TT_AUFNR
    exporting
      !ET_ORDERS type TT_ORDERS .
  methods ADD_PLANNEDORDERS
    importing
      !IT_PLNUM type TT_PLNUM
      !IF_SHOW_PROGRESS type XFELD default ABAP_TRUE
    exporting
      !ET_PLANNEDORDERS type TT_ORDERS .
  methods GET_ORDER
    importing
      !IF_AUFNR type AUFNR
    returning
      value(RR_ORDER) type ref to ZIF_ORDER .
  methods GET_PLANNEDORDER
    importing
      !IF_PLNUM type PLNUM
    returning
      value(RR_PLANNEDORDER) type ref to ZIF_ORDER .
  methods GET_BY_ID
    importing
      !IF_PLNID type Z_PLNID
      !IF_SART type /GIB/DCP_SART
    returning
      value(RR_ORDER) type ref to ZIF_ORDER .
  methods REFRESH
    importing
      !IF_IGNORE_COMMIT_LOCK type ABAP_BOOL default ABAP_FALSE .
  methods CREATE_PLANNEDORDER
    importing
      !IS_HEADERDATA type BAPIPLAF_I1
    returning
      value(RR_ORDER) type ref to ZIF_ORDER .
  methods SET_COMMIT_LOCK
    importing
      !IF_VALUE type FLAG .
endinterface.
