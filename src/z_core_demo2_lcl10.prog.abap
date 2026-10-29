*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
CLASS lcl_m_operation DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_m.

    METHODS constructor IMPORTING ir_operation TYPE REF TO zif_operation.

  PRIVATE SECTION.
    CONSTANTS co_deallocate             TYPE string VALUE 'DEALLOCATE'.
    CONSTANTS co_reschedule             TYPE string VALUE 'RESCHEDULE'.
    CONSTANTS co_longtext               TYPE string VALUE 'LTEXT'.
    CONSTANTS co_longtext_display       TYPE string VALUE 'LTEXT_DISPLAY'.
    CONSTANTS co_change_workcenter      TYPE string VALUE 'CHANGE_WORKCENTER'.
    CONSTANTS co_change_standard_values TYPE string VALUE 'STANDARD_VALUES'.

    DATA mr_operation TYPE REF TO zif_operation.
    DATA mt_functions TYPE lif_m~tt_functions.

    METHODS build_functions.
    METHODS reschedule.
    METHODS deallocate.
    METHODS change_workcenter.
    METHODS change_standard_values.

ENDCLASS.

CLASS lcl_m_operation IMPLEMENTATION.
  METHOD lif_m~handle_function.
    TRY.
        CASE if_func.
          WHEN co_reschedule.
            reschedule( ).
          WHEN co_change_workcenter.
            change_workcenter( ).
          WHEN co_change_standard_values.
            change_standard_values( ).
          WHEN co_deallocate.
            deallocate( ).
          WHEN co_longtext.
            mr_operation->edit_long_text( ).
          WHEN co_longtext_display.
            mr_operation->display_long_text( ).
        ENDCASE.

      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.
    mr_operation = ir_operation.
    build_functions( ).
  ENDMETHOD.

  METHOD lif_m~double_click.
    TRY.
        mr_operation->dialog( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.

  METHOD lif_m~get_functions.
    et_functions = mt_functions.
  ENDMETHOD.

  METHOD build_functions.

    mt_functions = VALUE #( ( fcode = co_reschedule             text = 'Mittelpunktterminierung' ) ##NO_TEXT
                            ( fcode = co_deallocate             text = 'Ausplanen' ) ##NO_TEXT
                            ( fcode = co_change_workcenter      text = 'Arbeitsplatzwechsel' ) ##NO_TEXT
                            ( fcode = co_change_standard_values text = 'Vorgabewerte ändern' ) ##NO_TEXT
                            ( fcode = co_longtext               text = 'Langtext Ändern' ) ##NO_TEXT
                            ( fcode = co_longtext_display       text = 'Langtext Anzeigen' ) ) ##NO_TEXT.
  ENDMETHOD.

  METHOD change_standard_values.
    TRY.
        mr_operation->change_standard_values_dialog( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
    ENDTRY.
  ENDMETHOD.

  METHOD reschedule.
    DATA lf_pit      TYPE z_pit.
    DATA lf_date     TYPE sy-datum.
    DATA lf_time     TYPE sy-uzeit.
    DATA lr_protocol TYPE REF TO zcl_msg.
    DATA lt_fields   TYPE TABLE OF sval.
    DATA lf_return   TYPE char1.
    DATA lf_forward  TYPE flag.

    APPEND INITIAL LINE TO lt_fields ASSIGNING FIELD-SYMBOL(<ls_field>).
    <ls_field>-tabname   = '/GIB/DCP_MAIN'.
    <ls_field>-fieldname = 'PLDAT'.
    <ls_field>-field_obl = 'X'.
    <ls_field>-value     = mr_operation->ms_afvgd-ssavd.
    APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_field>.
    <ls_field>-tabname   = '/GIB/DCP_MAIN'.
    <ls_field>-fieldname = 'PLZEIT'.
    <ls_field>-field_obl = 'X'.
    <ls_field>-value     = mr_operation->ms_afvgd-ssavz.
    APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_field>.
    <ls_field>-tabname   = 'TCY37'.
    <ls_field>-fieldname = 'FORWARD'.
    <ls_field>-value     = 'X'.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING  popup_title     = 'Neue Termin' ##NO_TEXT
      IMPORTING  returncode      = lf_return
      TABLES     fields          = lt_fields
      EXCEPTIONS error_in_fields = 1
                 OTHERS          = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    CASE lf_return.
      WHEN 'A'." popup canceled
        RETURN.
      WHEN OTHERS.
        LOOP AT lt_fields ASSIGNING <ls_field>.
          CASE <ls_field>-fieldname.
            WHEN 'PLDAT'.
              lf_date = <ls_field>-value.
            WHEN 'PLZEIT'.
              lf_time = <ls_field>-value.
            WHEN 'FORWARD'.
              lf_forward = <ls_field>-value.
          ENDCASE.
        ENDLOOP.
    ENDCASE.

    CALL FUNCTION 'DATE_TIME_CONVERT'
      EXPORTING  date                 = lf_date
                 time                 = lf_time
      IMPORTING  point_in_time        = lf_pit
      EXCEPTIONS date_before_rel_date = 1
                 date_to_big          = 2
                 OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    TRY.
        mr_operation->dispatch_midpoint( if_pit     = lf_pit
                                         if_forward = lf_forward )->show( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
    ENDTRY.
  ENDMETHOD.

  METHOD deallocate.
    TRY.
        mr_operation->deallocate( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
    ENDTRY.
  ENDMETHOD.

  METHOD change_workcenter.
    DATA ls_afvgd      TYPE afvgd.
    DATA lr_workcenter TYPE REF TO zcl_arbid.
    DATA lt_fields     TYPE TABLE OF sval.
    DATA lf_return     TYPE char1.
    FIELD-SYMBOLS <ls_field> TYPE sval.

    ls_afvgd = mr_operation->ms_afvgd.

    APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_field>.
    <ls_field>-tabname    = 'AFVGD'.
    <ls_field>-fieldname  = 'WERKS'.
    <ls_field>-field_attr = '02'.
    <ls_field>-value      = mr_operation->ms_afvgd-werks.
    APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_field>.
    <ls_field>-tabname   = 'AFVGD'.
    <ls_field>-fieldname = 'ARBPL'.
    <ls_field>-field_obl = 'X'.
    <ls_field>-value     = mr_operation->ms_afvgd-arbpl.

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING  popup_title     = 'Arbeitsplatzwechsel' ##NO_TEXT
      IMPORTING  returncode      = lf_return
      TABLES     fields          = lt_fields
      EXCEPTIONS error_in_fields = 1
                 OTHERS          = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    CASE lf_return.
      WHEN 'A'." popup canceled
        RETURN.
      WHEN OTHERS.
        LOOP AT lt_fields ASSIGNING <ls_field>.
          CASE <ls_field>-fieldname.
            WHEN 'ARBPL'.
              ls_afvgd-arbpl = <ls_field>-value.
          ENDCASE.
        ENDLOOP.
    ENDCASE.

    lr_workcenter = zcl_arbid=>get_instance_with_key( if_werks = ls_afvgd-werks
                                                              if_arbpl = ls_afvgd-arbpl ).

    TRY.
        mr_operation->change_workcenter( lr_workcenter ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
