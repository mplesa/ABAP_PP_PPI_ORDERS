class ZCL_WERKS definition
  public
  create public .

public section.
  type-pools ABAP .
  type-pools ICON .

  interfaces ZIF_DESCRIPTION .

  aliases GET_DESCRIPTION
    for ZIF_DESCRIPTION~GET .
  aliases GET_ICON
    for ZIF_DESCRIPTION~GET_ICON .
  aliases GET_LONG_DESCRIPTION
    for ZIF_DESCRIPTION~GET_LONG .

  data MS_HEADER type T001W read-only .
  data MF_WERKS type WERKS_D read-only .

  methods CONSTRUCTOR
    importing
      !IF_WERKS type WERKS_D .
  class-methods GET_INSTANCE
    importing
      !IF_WERKS type WERKS_D
    returning
      value(RR_WERKS) type ref to ZCL_WERKS .
  methods GET_AVAIL_FIX_PLANNEDORDERS
    returning
      value(RF_FIX) type ABAP_BOOL .
protected section.
private section.

  class-data:
    gt_werks TYPE TABLE OF REF TO zcl_werks .
ENDCLASS.

CLASS ZCL_WERKS IMPLEMENTATION.

  METHOD ZIF_DESCRIPTION~GET.

    CONCATENATE '['
                mf_werks
                ']'
           INTO rf_value.
  ENDMETHOD.

  METHOD zif_description~get_icon.
    rf_icon = icon_plant."icon_header.
  ENDMETHOD.

  METHOD ZIF_DESCRIPTION~GET_LONG.

    rf_value = get_description( ).

    IF ms_header-name1 IS NOT INITIAL.
      CONCATENATE rf_value
                  '-'
                  ms_header-name1
             INTO rf_value.
    ELSEIF ms_header-name2 IS NOT INITIAL.
      CONCATENATE rf_value
                  '-'
                  ms_header-name2
             INTO rf_value.
    ENDIF.

  ENDMETHOD.

  METHOD CONSTRUCTOR.
    mf_werks = if_werks.
    SELECT SINGLE * FROM t001w INTO ms_header "#EC CI_SUBRC
       WHERE werks = mf_werks.
  ENDMETHOD.

  METHOD GET_INSTANCE.
    READ TABLE gt_werks INTO rr_werks WITH KEY table_line->mf_werks = if_werks.
    IF sy-subrc <> 0.
      CREATE OBJECT rr_werks
        EXPORTING
          if_werks = if_werks.
      APPEND rr_werks TO gt_werks.
    ENDIF.
  ENDMETHOD.

  METHOD get_avail_fix_plannedorders.
    rf_fix = zcl_order_buffer=>gf_avail_fix_plannedorders.
  ENDMETHOD.
ENDCLASS.
