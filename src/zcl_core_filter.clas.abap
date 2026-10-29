class ZCL_CORE_FILTER definition
  public
  create public .

public section.

  types:
    TT_ORDERS TYPE TABLE OF z_plnid .
  types:
    TT_AREAS TYPE TABLE OF /gib/dcp_area .

  methods GET
    returning
      value(RT_FILTER) type /GIB/DCP_CM25_FILTER_T .
  methods SET_WERKS
    importing
      !IF_WERKS type WERKS_D .
  methods SET_KAPAR
    importing
      !IF_KAPAR type KAPART .
  methods ADD_AREAS
    importing
      !IT_AREAS type TT_AREAS .
  methods ADD_ORDERS
    importing
      !IT_ORDERS type TT_ORDERS .
  methods ADD_PLANNED_ORDERS
    importing
      !IT_PLANNED_ORDERS type TT_ORDERS .
  methods ADD_AREA
    importing
      !IF_AREA type /GIB/DCP_AREA .
protected section.
private section.

  data MF_WERKS type WERKS_D .
  data MF_KAPAR type KAPART .
  data:
    MT_ORDERS type TABLE OF AUFNR .
  data:
    MT_PLANNED_ORDERS type TABLE OF PLNUM .
  data:
    MT_AREAS TYPE TABLE OF /gib/dcp_area .
ENDCLASS.

CLASS ZCL_CORE_FILTER IMPLEMENTATION.

  METHOD ADD_AREA.

    APPEND if_area TO mt_areas.

  ENDMETHOD.

  METHOD ADD_AREAS.

    APPEND LINES OF it_areas TO mt_areas.

  ENDMETHOD.

  METHOD ADD_ORDERS.

    APPEND LINES OF it_orders TO mt_orders.

  ENDMETHOD.

  METHOD ADD_PLANNED_ORDERS.

    APPEND LINES OF it_planned_orders TO mt_planned_orders.

  ENDMETHOD.

  METHOD GET.

    FIELD-SYMBOLS: <lf_aufnr> TYPE aufnr,
                   <lf_plnum> TYPE plnum,
                   <lf_area>  TYPE /gib/dcp_area.

*# you can also set filter for single production(AUFPL) or planedorders(PLNUM)
    FIELD-SYMBOLS: <ls_filter> TYPE cyfil_tab.
*# create filter for werks
    APPEND INITIAL LINE TO rt_filter ASSIGNING <ls_filter>.
    <ls_filter>-filgru = '00'.
    <ls_filter>-feld   = 'CRHDWERKS'."con_field_crhd_crhdwerks.
    <ls_filter>-sign   = 'I'.
    <ls_filter>-option = 'EQ'.
    <ls_filter>-low    = mf_werks.
    IF mt_orders IS NOT INITIAL.
      LOOP AT mt_orders ASSIGNING <lf_aufnr>.
*# create filter for area
        APPEND INITIAL LINE TO rt_filter ASSIGNING <ls_filter>.
        <ls_filter>-filgru = '00'.
        <ls_filter>-feld   = 'AUFNR'."con_field_crhd_arbpl.
        <ls_filter>-sign   = 'I'.
        <ls_filter>-option = 'EQ'.
        <ls_filter>-low    = <lf_aufnr>.
      ENDLOOP.
    ELSEIF mt_planned_orders IS NOT INITIAL.
      LOOP AT mt_planned_orders ASSIGNING <lf_plnum>.
*# create filter for area
        APPEND INITIAL LINE TO rt_filter ASSIGNING <ls_filter>.
        <ls_filter>-filgru = '00'.
        <ls_filter>-feld   = 'PLNUM'."con_field_crhd_arbpl.
        <ls_filter>-sign   = 'I'.
        <ls_filter>-option = 'EQ'.
        <ls_filter>-low    = <lf_plnum>.
      ENDLOOP.
    ELSE.
      LOOP AT mt_areas ASSIGNING <lf_area>.
*# create filter for area
        APPEND INITIAL LINE TO rt_filter ASSIGNING <ls_filter>.
        <ls_filter>-filgru = '00'.
        <ls_filter>-feld   = 'ARBPL'."con_field_crhd_arbpl.
        <ls_filter>-sign   = 'I'.
        <ls_filter>-option = 'EQ'.
        <ls_filter>-low    = <lf_area>.
      ENDLOOP.
    ENDIF.

    IF mf_kapar IS NOT INITIAL.
*# create filter for area
      APPEND INITIAL LINE TO rt_filter ASSIGNING <ls_filter>.
      <ls_filter>-filgru = '00'.
      <ls_filter>-feld   = 'KAPAR'."con_field_kako_kapar.
      <ls_filter>-sign   = 'I'.
      <ls_filter>-option = 'EQ'.
      <ls_filter>-low    = mf_kapar.
    ENDIF.
*# this says only operations without status RÜEK
    APPEND INITIAL LINE TO rt_filter ASSIGNING <ls_filter>.
    <ls_filter>-filgru = '01'.
    <ls_filter>-feld   = 'AFVGSELID'."con_field_afvg_afvgselid.
    <ls_filter>-sign   = 'I'.
    <ls_filter>-option = 'EQ'.
    <ls_filter>-low    = 'SAP009'." this says only operations without status RÜEK

  ENDMETHOD.

  METHOD SET_KAPAR.

    mf_kapar = if_kapar.

  ENDMETHOD.

  METHOD SET_WERKS.

    mf_werks = if_werks.

  ENDMETHOD.
ENDCLASS.
