class ZCL_KAPID definition
  public
  final
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

  types:
    BEGIN OF ts_kapm,
              ezkap TYPE /gib/dcp_ezkap.
            INCLUDE TYPE kapm.
    TYPES: END OF ts_kapm .
  types:
    tt_kapm TYPE TABLE OF ts_kapm .

  data MR_KAPART type ref to ZCL_KAPART read-only .
  data MS_KAKO type KAKO read-only .
  data MS_KAKO_HEADER type RCRKK read-only .
  data MF_KAPID type KAPID read-only .
  data MF_DESCRIPTION type KAPTEXT read-only .

  methods GET_SINGLE_CAPACITY
    importing
      !IF_EZKAP type /GIB/DCP_EZKAP
    returning
      value(ES_KAPM) type TS_KAPM .
  methods CONSTRUCTOR
    importing
      !IF_KAPID type KAPID
    raising
      /GIB/CX_DCP_CAPACITY .
  class-methods GET_INSTANCE
    importing
      !IF_KAPID type KAPID
    returning
      value(RR_KAPID) type ref to ZCL_KAPID
    raising
      /GIB/CX_DCP_CAPACITY .
  methods UNIT_CONVERSION
    importing
      !IF_UNIT_IN type MEINS
      !IF_UNIT_OUT type MEINS
      !IF_VALUE type NUMERIC
    exporting
      !EF_VALUE type NUMERIC .
protected section.
private section.

  class-data:
    gt_kapids TYPE TABLE OF REF TO zcl_kapid .
  data MT_KAPM type TT_KAPM .

  methods READ_SINGLE_CAPACITIES
    raising
      /GIB/CX_DCP .
ENDCLASS.

CLASS ZCL_KAPID IMPLEMENTATION.

  METHOD ZIF_DESCRIPTION~GET.
    rf_value = mr_kapart->get_description( ).
  ENDMETHOD.

  METHOD ZIF_DESCRIPTION~GET_ICON.
    rf_icon = icon_wd_context.
  ENDMETHOD.

  METHOD ZIF_DESCRIPTION~GET_LONG.
    DATA: lf_string TYPE string.

    rf_value = mr_kapart->get_long_description( ).

    IF mf_description IS NOT INITIAL.
      CONCATENATE rf_value
                  '('
                  mf_description
                  ')'
             INTO rf_value.
    ENDIF.
  ENDMETHOD.

  METHOD constructor.
    CALL FUNCTION 'CR_CAPACITY_READ'
      EXPORTING
        kapid              = if_kapid
        msgty              = 'S'
        req_rcrkk          = 'X'
      IMPORTING
        ekako              = ms_kako
        works              = ms_kako_header
      EXCEPTIONS
        OTHERS             = 0.

    mf_kapid = if_kapid.
    ms_kako = ms_kako.
    mf_kapid = ms_kako-kapid.
    mf_description = ms_kako_header-ktext.
    mr_kapart = zcl_kapart=>get_instance( ms_kako-kapar ).
  ENDMETHOD.

  METHOD get_instance.
    READ TABLE gt_kapids INTO rr_kapid WITH KEY table_line->mf_kapid = if_kapid.
    IF sy-subrc <> 0.
      CREATE OBJECT rr_kapid
        EXPORTING
          if_kapid = if_kapid.
      APPEND rr_kapid TO gt_kapids.
    ENDIF.
  ENDMETHOD.

  METHOD get_single_capacity.
    CLEAR es_kapm.
    IF mt_kapm IS INITIAL.
      TRY.
          read_single_capacities( ).
        CATCH /gib/cx_dcp.
      ENDTRY.
    ENDIF.

    READ TABLE mt_kapm INTO es_kapm
      WITH KEY ezkap = if_ezkap.
    IF sy-subrc <> 0.
      es_kapm-ezkap = if_ezkap.
      es_kapm-name = if_ezkap.
      APPEND es_kapm TO mt_kapm.
    ENDIF.

  ENDMETHOD.

  METHOD read_single_capacities.
    DATA: lt_kapm  TYPE TABLE OF kapm,
          ls_kapme TYPE ts_kapm.    "KAPM extended

    CLEAR: mt_kapm.
    CALL FUNCTION 'CR_SINGLE_CAPACITIES'
      EXPORTING
        up_kapid             = ms_kako-kapid
      TABLES
        tab_single           = lt_kapm
      EXCEPTIONS
        not_found            = 1
        no_single_capacities = 2
        OTHERS               = 3.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE /gib/cx_dcp_capacity
          EXPORTING
            textid = /gib/cx_dcp_capacity=>invalid_capa_id
            kapid  = ms_kako-kapid.

      WHEN OTHERS.
        RAISE EXCEPTION TYPE /gib/cx_dcp_capacity
          EXPORTING
            textid = /gib/cx_dcp_capacity=>no_single_capa_available
            kapid  = ms_kako-kapid.

    ENDCASE.

    LOOP AT lt_kapm ASSIGNING FIELD-SYMBOL(<ls_kapm>).
      CLEAR: ls_kapme.
      ls_kapme-ezkap = sy-tabix.
      MOVE-CORRESPONDING <ls_kapm> TO ls_kapme.
      APPEND ls_kapme TO mt_kapm.
    ENDLOOP.

  ENDMETHOD.

  METHOD unit_conversion.
    TRY.
        CALL FUNCTION 'CR_CAPACITY_UNIT_CONVERSION'
          EXPORTING
            input                = if_value
            kapid                = mf_kapid
            unit_in              = if_unit_in
            unit_out             = if_unit_out
          IMPORTING
            output               = ef_value
          EXCEPTIONS
            capacity_not_found   = 1
            conversion_not_found = 2
            unit_in_not_found    = 3
            unit_out_not_found   = 4
            OTHERS               = 5.
        IF sy-subrc <> 0 AND sy-msgid IS NOT INITIAL.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      CATCH cx_sy_conversion_overflow.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
