class ZCL_SERVICES definition
  public
  abstract
  final
  create public .

*"* do not include other source files here!!!
public section.

  class-methods GET_PA_FROM_SEL
    importing
      !IF_SELNAME type RSSCR_NAME
      !IT_SELOPT type RSPARAMS_TT
    returning
      value(RF_VAL) type STRING .
  class-methods SHOW_PROGRESS_BAR
    importing
      !IF_TEXT type TEXT132
      !IF_MAX type SYTABIX
      !IF_COUNT type SYTABIX
      !IF_RESET type XFELD .
  class-methods GET_DD02T
    importing
      !IF_TABLE type TABNAME
    returning
      value(RF_TEXT) type DDTEXT .
  class-methods CREATE_ICON
    importing
      value(IF_ICONID) type NAV_ICONID
      value(IF_TEXT) type NAV_ICONTEXT optional
      value(IF_INFO) type NAV_QUICK optional
    returning
      value(RF_RESULT) type TEXT30 .
  class-methods IS_TIME_UNIT
    importing
      !IF_UNIT type T006-MSEHI
    returning
      value(RF_ANSWER) type FLAG .
  class-methods CONVERSION_TIME
    importing
      value(IF_VALUE_IN) type ANY
      value(IF_UNIT_IN) type T006-MSEHI
    changing
      value(EF_UNIT_OUT) type T006-MSEHI
      value(EF_VALUE_OUT) type ANY .
  class-methods CONVERSION_VALUE
    importing
      !IF_VALUE_IN type ANY
      !IF_UNIT_IN type T006-MSEHI
      !IF_UNIT_OUT type T006-MSEHI
    exporting
      value(EF_VALUE_OUT) type ANY
    raising
      ZCX_CORE .
  class-methods GET_UNIT_FOR_SECONDS
    returning
      value(RF_UNIT_FOR_SECONDS) type MSEHI .
  class-methods GET_UNIT_DIMENSION
    importing
      !IF_UNIT type T006-MSEHI
    returning
      value(EF_DIMENSION) type T006-DIMID
    raising
      ZCX_CORE .
    "! Checks if an additional internal session for a SUBMIT is available.<br>
    "! See SAP Note 1229222 (https://me.sap.com/notes/1229222)
    "! @parameter rf_int_session_is_available | abap_true if an additional session is available
  class-methods INTERNAL_SESSION_IS_AVAILABLE
    returning
      value(RF_INT_SESSION_IS_AVAILABLE) type ABAP_BOOL .
  PROTECTED SECTION.
*"* do not include other source files here!!!
private section.

*"* do not include other source files here!!!
  class-data GF_UNIT_FOR_SECONDS type MSEHI .
  class-data GF_NEXT_PROGRESS_STEP type NUMC3 .
ENDCLASS.

CLASS ZCL_SERVICES IMPLEMENTATION.

  METHOD conversion_time .

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = if_value_in
        unit_in              = if_unit_in
        unit_out             = ef_unit_out
      IMPORTING
        output               = ef_value_out
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.
    CASE sy-subrc.
      WHEN 1 OR 2 OR 5 OR 6 OR 9.
        ef_unit_out  = if_unit_in.
        ef_value_out = if_value_in.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

  ENDMETHOD.

  METHOD create_icon.
    DATA: lf_result TYPE string.

    CALL FUNCTION 'ICON_CREATE' "#EC CI_SUBRC
      EXPORTING
        name                  = if_iconid
        text                  = if_text
        info                  = if_info
        add_stdinf            = space
      IMPORTING
        result                = lf_result
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.

    ENDIF.

    rf_result = lf_result.
*# if the result string was bigger then 30 characters then adjust it!
    IF strlen( if_info ) GT 24.
      rf_result+29 = '@'.
    ENDIF.

  ENDMETHOD.

  METHOD get_dd02t.
    DATA: ls_dd02t TYPE dd02t.
    SELECT SINGLE ddtext FROM dd02t INTO CORRESPONDING FIELDS OF ls_dd02t WHERE tabname EQ if_table AND ddlanguage EQ sy-langu. "#EC CI_NOORDER
    IF sy-subrc NE 0.
      SELECT SINGLE ddtext FROM dd02t INTO ls_dd02t WHERE tabname EQ if_table AND ddlanguage EQ 'E'. "#EC CI_NOORDER
    ENDIF.
    rf_text = ls_dd02t-ddtext.
  ENDMETHOD.

  METHOD get_pa_from_sel.
    FIELD-SYMBOLS: <ls_selopt> TYPE rsparams.

    READ TABLE it_selopt WITH KEY selname = if_selname ASSIGNING <ls_selopt>.
    CHECK sy-subrc = 0.

    rf_val = <ls_selopt>-low.
  ENDMETHOD.

  METHOD is_time_unit.
    DATA: lf_msehi TYPE t006-msehi.

    SELECT SINGLE msehi FROM t006 INTO lf_msehi
      WHERE msehi = if_unit
        AND dimid = 'TIME'.
    IF sy-subrc = 0.
      rf_answer = 'X'.
    ENDIF.
  ENDMETHOD.

  METHOD show_progress_bar.
*# Prozent-Schrittweite setzen / Define Percentage steps
    CONSTANTS: co_percentage_step(3)  TYPE n VALUE '010'.

    DATA: lf_percentage TYPE i,
          lf_percent(3) TYPE c,
          lf_text       TYPE text132.

*# Prozentsatz ausrechnen / calculate percentage
    IF if_count = 0.
      EXIT.

*# Letzter Eintrag / last entry
    ELSEIF if_count = if_max.
      lf_percentage     = 100.
      gf_next_progress_step = 0.
    ELSE.

      TRY.
          lf_percentage = ( if_count * 100 ) DIV if_max.
        CATCH cx_sy_zerodivide.
          lf_percentage = 0.
      ENDTRY.
      IF lf_percentage < gf_next_progress_step.
        EXIT.
      ELSE.
        gf_next_progress_step = lf_percentage + co_percentage_step.
      ENDIF.
    ENDIF.

*# Text zusammenfügen / build text
    IF lf_percentage >= 100.
      lf_percent = 100.
    ELSE.
      WRITE lf_percentage TO lf_percent LEFT-JUSTIFIED.
    ENDIF.
    lf_text = if_text.

    REPLACE '&' IN lf_text WITH lf_percent.
    CONDENSE lf_text.

*# Nachricht ausgeben / display message
    IF lf_percentage = 0. lf_percentage = 1. ENDIF.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lf_percentage
        text       = lf_text.

*# Reset durchführen / reset progress Bar
    IF if_reset = 'X'.
      gf_next_progress_step = 0.
    ENDIF.
  ENDMETHOD.

  METHOD get_unit_for_seconds.

*# get the unit for seconds only once and store it in class-static
    IF gf_unit_for_seconds IS INITIAL.
      CALL FUNCTION 'TIME_UNITS'
        IMPORTING
          second          = gf_unit_for_seconds
        EXCEPTIONS
          si_unit_missing = 1
          OTHERS          = 2.

      IF sy-subrc <> 0.
        gf_unit_for_seconds = 'S'.
      ENDIF.
    ENDIF.

    rf_unit_for_seconds = gf_unit_for_seconds.

  ENDMETHOD.

  METHOD get_unit_dimension.
    SELECT SINGLE dimid FROM t006 INTO ef_dimension
     WHERE msehi = if_unit.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_invalid_unit
        EXPORTING
          unit = if_unit.
    ENDIF.

  ENDMETHOD.

  METHOD internal_session_is_available.
    DATA(lf_mode_available) = abap_false.
    CALL FUNCTION 'DY_IS_EXTRA_IMODE_AVAILABLE'
      IMPORTING
        answer = lf_mode_available.

    rf_int_session_is_available = lf_mode_available.
  ENDMETHOD.

  METHOD conversion_value .

    CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
      EXPORTING
        input                = if_value_in
        unit_in              = if_unit_in
        unit_out             = if_unit_out
      IMPORTING
        output               = ef_value_out
      EXCEPTIONS
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        OTHERS               = 10.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_core USING MESSAGE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
