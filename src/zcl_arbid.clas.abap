class ZCL_ARBID definition
  public
  create public .

public section.
  type-pools ABAP .
  type-pools ICON .

  interfaces ZIF_DESCRIPTION .
  interfaces ZIF_OBJID .

  aliases GET_CHILDREN
    for ZIF_OBJID~GET_CHILDREN .
  aliases GET_DESCRIPTION
    for ZIF_DESCRIPTION~GET .
  aliases GET_ICON
    for ZIF_DESCRIPTION~GET_ICON .
  aliases GET_LONG_DESCRIPTION
    for ZIF_DESCRIPTION~GET_LONG .
  aliases GET_SUBTREE
    for ZIF_OBJID~GET_SUBTREE .

  types:
    TT_ARBID TYPE TABLE OF REF TO zcl_arbid .

  data MF_ARBID type OBJEKTID read-only .
  data MS_CRHD type CRHD read-only .
  data MF_DESCRIPTION type KTXT40 read-only .
  data MF_ARBPL type ARBPL read-only .
  data MR_WERKS type ref to ZCL_WERKS read-only .
  data:
    mt_kapids TYPE TABLE OF REF TO zcl_kapid read-only .
  constants CO_OBJTY_WORKCENTER type CR_OBJTY value 'A' ##NO_TEXT.
  data MT_CHILDREN type ZIF_OBJID=>TT_OBJID .
  data MF_ACTIVE_VERSION type KAPVERSAKT .

  methods CONSTRUCTOR
    importing
      !IF_ARBID type OBJEKTID
      !IT_CHILDREN type ZIF_OBJID=>TT_OBJID optional .
  class-methods GET_INSTANCE_WITH_KEY
    importing
      !IF_ARBPL type ARBPL
      !IF_WERKS type WERKS_D
    returning
      value(RR_ARBID) type ref to ZCL_ARBID .
  class-methods GET_INSTANCE
    importing
      !IF_ARBID type OBJEKTID
    returning
      value(RR_ARBID) type ref to ZCL_ARBID .
  methods GET_SCHEDULING_KAPID
    returning
      value(RR_KAPID) type ref to ZCL_KAPID
    raising
      /GIB/CX_DCP_CAPACITY .
  methods GET_CAPA_ASSIGNMENT
    returning
      value(ES_CRCA) type CRCA .
  PROTECTED SECTION.
private section.

  class-data:
    gt_arbid TYPE TABLE OF REF TO zcl_arbid .
  data MS_CRCA type CRCA .
ENDCLASS.

CLASS ZCL_ARBID IMPLEMENTATION.

  METHOD zif_description~get.

    rf_value = ms_crhd-arbpl.
  ENDMETHOD.

  METHOD zif_description~get_icon.
    rf_icon = icon_work_center.
  ENDMETHOD.

  METHOD zif_description~get_long.

    rf_value = get_description( ).
    IF mf_description IS NOT INITIAL.
      CONCATENATE rf_value
                  '-'
                  mf_description
             INTO rf_value.
    ENDIF.

  ENDMETHOD.

  METHOD zif_objid~get_children.
    et_children = mt_children.
  ENDMETHOD.

  METHOD zif_objid~get_subtree.
    APPEND me TO et_subtree.
  ENDMETHOD.

  METHOD constructor.
    DATA: lf_werks TYPE werks_d,
          lt_rcrkk TYPE TABLE OF rcrkk,
          lr_kapid TYPE REF TO zcl_kapid.
    FIELD-SYMBOLS: <ls_rcrkk> TYPE rcrkk.
*# read work center
    CALL FUNCTION 'CR_WORKSTATION_READ'
      EXPORTING
        id        = if_arbid
        msgty     = 'S'
      IMPORTING
        ecrhd     = ms_crhd
        werks     = lf_werks
        ktext     = mf_description
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.

        WHEN OTHERS.

      ENDCASE.
    ENDIF.

    mf_arbid = ms_crhd-objid.
    mf_arbpl = ms_crhd-arbpl.
    mr_werks = zcl_werks=>get_instance( lf_werks ).

    CALL FUNCTION 'CR_CAPACITIES_OF_WORKCENTER'
      EXPORTING
        arbid               = mf_arbid
        arbpl               = mf_arbpl
        werks               = lf_werks
      TABLES
        t_kako              = lt_rcrkk
      EXCEPTIONS
        missing_parameters  = 1
        not_found           = 2
        no_capacities_found = 3
        OTHERS              = 4.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.

        WHEN OTHERS.

      ENDCASE.
    ENDIF.

    LOOP AT lt_rcrkk ASSIGNING <ls_rcrkk>.
      TRY.
          lr_kapid = zcl_kapid=>get_instance( <ls_rcrkk>-kapid ).
        CATCH /gib/cx_dcp_capacity.
          CONTINUE.
      ENDTRY.
      APPEND lr_kapid TO mt_kapids.
    ENDLOOP.

    zif_objid~mf_objid = ms_crhd-objid.
    zif_objid~mf_objty = ms_crhd-objty.
    mt_children = it_children.
    TRY.
        lr_kapid = zcl_kapid=>get_instance( ms_crhd-kapid ).
      CATCH /gib/cx_dcp_capacity.
        EXIT.
    ENDTRY.
    mf_active_version = lr_kapid->ms_kako-versa.
  ENDMETHOD.

  METHOD get_instance.
    READ TABLE gt_arbid WITH KEY table_line->mf_arbid = if_arbid
          INTO rr_arbid.
    IF sy-subrc NE 0.
      CREATE OBJECT rr_arbid
        EXPORTING
          if_arbid = if_arbid.
      APPEND rr_arbid TO gt_arbid.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_with_key.
    DATA: lf_arbid TYPE cr_objid.
    READ TABLE gt_arbid INTO rr_arbid WITH KEY table_line->ms_crhd-arbpl = if_arbpl
                                               table_line->ms_crhd-werks = if_werks.
    IF sy-subrc <> 0.
      CALL FUNCTION 'CR_WORKSTATION_CHECK'
        EXPORTING
          arbpl     = if_arbpl
          werks     = if_werks
        IMPORTING
          arbid     = lf_arbid
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 1.

          WHEN OTHERS.

        ENDCASE.
      ENDIF.

      CREATE OBJECT rr_arbid EXPORTING if_arbid = lf_arbid.
      APPEND rr_arbid TO gt_arbid.
    ENDIF.
  ENDMETHOD.

  METHOD get_scheduling_kapid.
    rr_kapid = zcl_kapid=>get_instance( ms_crhd-kapid ).
  ENDMETHOD.

  METHOD get_capa_assignment.
    IF  ms_crca IS INITIAL.
      SELECT SINGLE * FROM crca INTO ms_crca              "#EC CI_SUBRC
        WHERE objty = ms_crhd-objty                         "#EC WARNOK
          AND objid = ms_crhd-objid
          AND kapid = ms_crhd-kapid
          AND begda <= sy-datum
          AND endda >= sy-datum.
    ENDIF.
    es_crca = ms_crca.

  ENDMETHOD.
ENDCLASS.
