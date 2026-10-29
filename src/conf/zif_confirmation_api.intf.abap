
interface ZIF_CONFIRMATION_API
  public .

  types:
    tt_pernr TYPE TABLE OF co_pernr .
  types:
    BEGIN OF ts_pp_operation_key,
      conf_no   TYPE  co_rueck,
      orderid   TYPE  aufnr,
      sequence  TYPE  plnfolge,
      operation TYPE  vornr,
      sub_oper  TYPE  uvorn,
      work_cntr TYPE  arbpl,
    END OF ts_pp_operation_key .
  types:
    BEGIN OF ts_pi_operaton_key,
      conf_no      TYPE  co_rueck,
      orderid      TYPE  aufnr,
      phase        TYPE  vornr,
      sec_resource TYPE  uvorn,
      resource     TYPE  arbpl,
    END OF ts_pi_operaton_key .
  types:
    BEGIN OF ts_confirmation,
           counter    TYPE co_rmzhl,
           recordtype TYPE co_satza,
           pernr      TYPE co_pernr,
           new        TYPE flag,
           record     TYPE REF TO zif_confirmation,
         END OF ts_confirmation .
  types:
    tt_confirmation_sort TYPE SORTED TABLE OF ts_confirmation WITH UNIQUE KEY counter recordtype pernr .

  methods POST
    importing
      !IF_COMMIT_WORK type FLAG default ABAP_TRUE
      !IF_WAIT type FLAG optional
    returning
      value(RR_MSG) type ref to ZCL_MSG .
  methods CREATE_TIME_TICKET
    importing
      !IS_TIME_TICKET type ZIF_CONFIRMATION=>TS_TIME_TICKET
    returning
      value(RR_CONFIRMATION) type ref to ZIF_CONFIRMATION .
  methods CREATE_TIME_EVENT
    importing
      !IS_TIME_EVENT type ZIF_CONFIRMATION=>TS_TIME_EVENT
    returning
      value(RR_CONFIRMATION) type ref to ZIF_CONFIRMATION .
  methods GET_TIME_TICKET_PROPOSAL
    importing
      !IS_PROPOSE type BAPI_PP_CONF_PROP
      !IS_TIME_TICKET type ZIF_CONFIRMATION=>TS_TIME_TICKET
    returning
      value(RR_PROPOSAL) type ref to ZCL_CONF_PROPOSAL .
  methods GET_TIME_EVENT_PROPOSAL
    importing
      !IS_TIME_EVENT type ZIF_CONFIRMATION=>TS_TIME_EVENT
    returning
      value(RR_PROPOSAL) type ref to ZCL_CONF_PROPOSAL .
  methods CANCEL_LAST
    importing
      !IF_PERNR type CO_PERNR optional .
  methods REFRESH .
  methods GET_LAST
    importing
      !IF_PERNR type CO_PERNR optional
    returning
      value(RR_LAST) type ref to ZIF_CONFIRMATION .
    methods GET_LAST_NOT_CANCELLED
    importing
      !IF_PERNR type CO_PERNR optional
    returning
      value(RR_LAST) type ref to ZIF_CONFIRMATION .
  methods GET_GOODS_MOVEMENT_TABLE
    exporting
      !ET_GOODS_MOVEMENT type BAPI2017_GM_ITEM_CREATE_T
      !ET_LINK_CONF_GOODSMOV type BAPI_LINK_CONF_GOODSMOV_TT .
  methods GET_AFRUD_TABLE
    exporting
      !ET_AFRUD type TY_T_AFRUD .
  methods GET_ACTIVE_PERNR_TABLE
    exporting
      !ET_PERNR type TT_PERNR .
endinterface.
