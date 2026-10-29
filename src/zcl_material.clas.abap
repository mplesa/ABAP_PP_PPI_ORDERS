class ZCL_MATERIAL definition
  public
  create public .

public section.
  type-pools ABAP .
  type-pools ICON .

  interfaces ZIF_LONG_TEXT .
  interfaces ZIF_MATERIAL .

  aliases MS_MAKT
    for ZIF_MATERIAL~MS_MAKT .
  aliases MS_MARA
    for ZIF_MATERIAL~MS_MARA .
  aliases EDIT_LONG_TEXT
    for ZIF_MATERIAL~EDIT_LONG_TEXT .
  aliases HAS_LONG_TEXT
    for ZIF_MATERIAL~HAS_LONG_TEXT .
  aliases UNIT_CONVERSION
    for ZIF_MATERIAL~UNIT_CONVERSION .

  types:
    begin of ts_material,
           matnr type matnr,
           material type ref to zif_material,
         end of ts_material .
  types:
    tt_material type SORTED TABLE OF ts_material with UNIQUE key matnr .

  data MS_MDKP type MDKP read-only .

  methods CONSTRUCTOR
    importing
      !IF_MATNR type MATNR .
  class-methods GET_INSTANCE
    importing
      !IF_MATNR type MATNR
    returning
      value(RR_MATNR) type ref to ZIF_MATERIAL .
  methods READ_STOCK_REQUIREMENTS
    importing
      !IR_MATERIAL type ref to ZIF_WERKS_MATERIAL
      !IF_BERID type BERID .
  class-methods ADD_TO_BUFFER
    importing
      !IT_MARA_HEAD type ZIF_MATERIAL=>TT_MARA_HEAD .
protected section.
private section.

  data MF_MATNR type MATNR .
  class-data GT_MATERIALS type TT_MATERIAL .
  data MF_LONG_TEXT type FLAG .
  data MF_LONG_TEXT_CHECKED type FLAG .

  methods READ_MARA .
  methods READ_MAKT .
ENDCLASS.

CLASS ZCL_MATERIAL IMPLEMENTATION.

  METHOD zif_long_text~display.
*/... must be implemented
  ENDMETHOD.

  METHOD zif_long_text~edit.
*/... must be implemented
  ENDMETHOD.

  METHOD zif_long_text~has_long_text.
    DATA: ls_stxh TYPE stxh.

    IF mf_long_text_checked IS INITIAL.

      SELECT  SINGLE tdobject FROM stxh INTO ls_stxh   "#EC DBACCESS_OK
                      WHERE tdobject = 'MATERIAL'
                        AND tdname   = mf_matnr
                        AND tdid     = 'GRUN'
                        AND tdspras  = sy-langu.
      IF sy-subrc = 0.
        mf_long_text_checked = abap_true.
        mf_long_text = abap_true.
      ENDIF.
    ENDIF.

    rf_answer = mf_long_text.

  ENDMETHOD.

  METHOD zif_material~unit_conversion.

    DATA: lr_menge TYPE REF TO data.

    FIELD-SYMBOLS: <lf_amount> TYPE any.

    CREATE DATA lr_menge LIKE cf_amount.
    ASSIGN lr_menge->* TO <lf_amount>.

    IF if_unit_from = if_unit_to.
      RETURN.
    ENDIF.
    <lf_amount> = cf_amount.
    IF if_unit_from <> ms_mara-meins.
*# switch to base unit
      CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
        EXPORTING
          input                = <lf_amount>
          kzmeinh              = abap_true     "amount from alternative unit to base unit
          matnr                = mf_matnr
          meinh                = if_unit_from         "ALTERNATIVE MATERIAL UNIT
          meins                = ms_mara-meins       "BASIS MATERIAL UNIT
        IMPORTING
          output               = <lf_amount>
        EXCEPTIONS
          conversion_not_found = 1
          input_invalid        = 2
          material_not_found   = 3
          meinh_not_found      = 4
          meins_missing        = 5
          no_meinh             = 6
          output_invalid       = 7
          overflow             = 8
          OTHERS               = 9.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_unit_conversion.
      ENDIF.
    ENDIF.
    IF if_unit_to <> ms_mara-meins.
*# switch to alternative unit
      CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
        EXPORTING
          input                = <lf_amount>
          kzmeinh              = abap_false     "amount from base unit to alternative unit
          matnr                = mf_matnr
          meinh                = if_unit_to            "ALTERNATIVE MATERIAL UNIT
          meins                = ms_mara-meins         "BASIS MATERIAL UNIT
        IMPORTING
          output               = <lf_amount>
        EXCEPTIONS
          conversion_not_found = 1
          input_invalid        = 2
          material_not_found   = 3
          meinh_not_found      = 4
          meins_missing        = 5
          no_meinh             = 6
          output_invalid       = 7
          overflow             = 8
          OTHERS               = 9.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_unit_conversion.
      ENDIF.
    ENDIF.
*# if no RETURN happend, we have the new amount, otherwise it stays as it is
    cf_amount = <lf_amount>.

  ENDMETHOD.

  METHOD constructor.
    mf_matnr = if_matnr.
    read_mara( ).
    read_makt( ).
  ENDMETHOD.

  METHOD get_instance.

    READ TABLE gt_materials ASSIGNING FIELD-SYMBOL(<ls_material>) WITH TABLE KEY matnr = if_matnr.
    IF sy-subrc = 0.
      rr_matnr = <ls_material>-material.
    ELSE.
      CREATE OBJECT rr_matnr TYPE zcl_material
        EXPORTING
          if_matnr = if_matnr.
      INSERT VALUE #( matnr = if_matnr
                      material = rr_matnr ) INTO TABLE gt_materials.

    ENDIF.
  ENDMETHOD.

  METHOD read_makt.
    CHECK mf_matnr IS NOT INITIAL.
    CALL FUNCTION 'MAKT_SINGLE_READ'
      EXPORTING
        matnr     = mf_matnr
        spras     = sy-langu
      IMPORTING
        wmakt     = ms_makt
      EXCEPTIONS
        not_found = 1.
    IF sy-subrc <> 0.
      CLEAR: ms_makt.
      ms_makt-matnr = mf_matnr.
    ENDIF.

  ENDMETHOD.

  METHOD read_mara.
    CALL FUNCTION 'MARA_SINGLE_READ'
      EXPORTING
        matnr             = mf_matnr
      IMPORTING
        wmara             = ms_mara
      EXCEPTIONS
        lock_on_material  = 1
        lock_system_error = 2
        wrong_call        = 3
        not_found         = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD read_stock_requirements.
    IF ms_mdkp IS INITIAL.
      CALL FUNCTION 'MD_STOCK_REQUIREMENTS_LIST_API'      "#EC CI_USAGE_OK[2438110]
        EXPORTING                                         "#EC CI_USAGE_OK[2227579]
          matnr  = ir_material->mr_matnr->ms_mara-matnr   "#EC CI_USAGE_OK[2227532]
          werks  = ir_material->mr_werks->mf_werks        "#EC CI_USAGE_OK[3211383]
          berid  = if_berid
        IMPORTING
          e_mdkp = ms_mdkp
        EXCEPTIONS
          OTHERS = 0.

    ENDIF.

  ENDMETHOD.

METHOD add_to_buffer.
  CHECK it_mara_head IS NOT INITIAL.

  DATA: lt_makt_head TYPE zif_material=>tt_makt_head.
  DATA(lt_mara_head) = it_mara_head."FUBA will change the Importing table

  LOOP AT lt_mara_head ASSIGNING FIELD-SYMBOL(<ls_mara_head>).
    APPEND INITIAL LINE TO lt_makt_head REFERENCE INTO DATA(lr_makt_head).
    lr_makt_head->matnr = <ls_mara_head>-matnr.
    lr_makt_head->spras = sy-langu.
  ENDLOOP.

  CALL FUNCTION 'MARA_ARRAY_READ'
    TABLES
      ipre03               = lt_mara_head
    EXCEPTIONS
      enqueue_mode_changed = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'MAKT_ARRAY_READ'
    TABLES
      ipre09               = lt_makt_head
    EXCEPTIONS
      enqueue_mode_changed = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDMETHOD.
ENDCLASS.
