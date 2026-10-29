interface ZIF_WERKS_MATERIAL
  public .

  types:
    tt_marc_head TYPE TABLE OF pre01 .
  types:
    BEGIN OF ts_mrp_data,
      matnr  TYPE matnr,
      werks  TYPE werks_d,
      berid  TYPE berid,
      mdps_t TYPE badi_mdpsx,
      mdez_t TYPE badi_mdezx,
      mdkp   TYPE mdkp,
**# Ist obsolet, Mapping wird nun von zentraler Komponente durchgeführt.
    END OF ts_mrp_data .
  types:
    tt_mrp_data TYPE SORTED TABLE OF ts_mrp_data WITH UNIQUE KEY matnr werks berid .

  data MS_MARC type MARC read-only .
  data:
    mt_mkal TYPE TABLE OF mkal read-only .
  data MR_WERKS type ref to ZCL_WERKS read-only .
  data MR_MATNR type ref to ZIF_MATERIAL .
  data MS_MTCOR type MTCOR read-only .
  data MS_MSFCV type MSFCV read-only .
  data MS_TCO43 type TCO43 read-only .

  methods GET_MRP_EXCEPTIONS
    importing
      !IF_BYPASS_BUFFER type FLAG optional
      !IF_BERID type BERID optional
      !IF_REFRESH type XFELD optional
    exporting
      !ET_DISPO_FA type /GIB/DCP_DISPO_FA_T .
  methods GET_MRP_DATA
    importing
      !IF_BERID type BERID optional
      !IF_REFRESH type XFELD default ' '
    exporting
      !ES_MRP_DATA type TS_MRP_DATA .
endinterface.
