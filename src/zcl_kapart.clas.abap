class ZCL_KAPART definition
  public
  create protected .

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

  types TT_KAPART TYPE TABLE OF REF TO zcl_kapart .

  class-data GT_KAPARTS type Z_KAPART_T read-only .
  data MS_KAPART type Z_KAPART_S read-only .
  data MF_KAPART type KAPART read-only .

  class-methods GET_INSTANCE
    importing
      !IF_KAPART type KAPART
    returning
      value(RR_KAPART) type ref to ZCL_KAPART .
  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR
    importing
      !IF_KAPART type KAPART .
protected section.
PRIVATE SECTION.

  TYPES: BEGIN OF ts_instance,
          kapart TYPE kapart,
          instance TYPE REF TO zcl_kapart,
         END OF ts_instance.

  CLASS-DATA:
    gt_instances TYPE TABLE OF ts_instance.
ENDCLASS.

CLASS ZCL_KAPART IMPLEMENTATION.

  METHOD ZIF_DESCRIPTION~GET.
    CONCATENATE '('
                mf_kapart
                ')'
           INTO rf_value.
  ENDMETHOD.

  METHOD zif_description~get_icon.
    rf_icon = icon_systemtype.
  ENDMETHOD.

  METHOD ZIF_DESCRIPTION~GET_LONG.

    CONCATENATE mf_kapart
                '-'
                ms_kapart-text
           INTO rf_value.
  ENDMETHOD.

  METHOD class_constructor.
    DATA: lt_tc26t TYPE TABLE OF tc26t.
    FIELD-SYMBOLS: <ls_kapart> TYPE z_kapart_s,
                   <ls_tc26t>  TYPE tc26t.

    SELECT * FROM tc26 INTO CORRESPONDING FIELDS OF TABLE gt_kaparts ORDER BY PRIMARY KEY. "#EC CI_SUBRC
    SELECT * FROM tc26t INTO TABLE lt_tc26t WHERE spras = sy-langu "#EC CI_SUBRC
                                            ORDER BY PRIMARY KEY.
    LOOP AT gt_kaparts ASSIGNING <ls_kapart>.
      READ TABLE lt_tc26t WITH KEY kapar = <ls_kapart> ASSIGNING <ls_tc26t>.
      IF sy-subrc EQ 0.
        <ls_kapart>-text = <ls_tc26t>-txt.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD CONSTRUCTOR.
    READ TABLE gt_kaparts WITH KEY kapar = if_kapart INTO ms_kapart.
    mf_kapart = ms_kapart-kapar.
  ENDMETHOD.

  METHOD GET_INSTANCE.
    FIELD-SYMBOLS: <ls_instance> TYPE ts_instance.

    READ TABLE gt_instances WITH KEY kapart = if_kapart ASSIGNING <ls_instance>.
    IF sy-subrc = 0.
      rr_kapart = <ls_instance>-instance.
    ELSE.
      APPEND INITIAL LINE TO gt_instances ASSIGNING <ls_instance>.
      CREATE OBJECT rr_kapart
        EXPORTING
          if_kapart = if_kapart.
      <ls_instance>-kapart = if_kapart.
      <ls_instance>-instance = rr_kapart.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
