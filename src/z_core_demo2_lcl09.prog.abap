*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

CLASS lcl_m_order DEFINITION.
  PUBLIC SECTION.
    CONSTANTS co_schedule              TYPE string VALUE 'SCHEDULE'.
    CONSTANTS co_schedule_basic        TYPE string VALUE 'SCHEDULE_BASIC'.
    CONSTANTS co_material_availability TYPE string VALUE 'MATERIAL_AVAILABILITY'.
    CONSTANTS co_capacity_availability TYPE string VALUE 'CAPACITY_AVAILABILITY'.
    CONSTANTS co_tcode                 TYPE string VALUE 'TCODE'.
    CONSTANTS co_select_version        TYPE string VALUE 'SELECT_VERID'.
    CONSTANTS co_virtual_order         TYPE string VALUE 'VIRTUAL'.
    CONSTANTS co_gantt                 TYPE string VALUE 'GANTT'.
    CONSTANTS co_prodversion           TYPE string VALUE 'PRODVERSION'.
    CONSTANTS co_convert               TYPE string VALUE 'CONVERT'.
    CONSTANTS co_longtext              TYPE string VALUE 'LTEXT'.
    CONSTANTS co_longtext_display      TYPE string VALUE 'LTEXT_DISPLAY'.
    CONSTANTS co_totalamount           TYPE string VALUE 'TOTALAMOUNT'.
    CONSTANTS co_release               TYPE string VALUE 'RELEASE'.

    INTERFACES lif_m.

    DATA mr_virtual TYPE REF TO zif_order READ-ONLY.

    METHODS constructor IMPORTING ir_order TYPE REF TO zif_order.

  PRIVATE SECTION.
    DATA mr_order     TYPE REF TO zif_order.

    DATA mt_functions TYPE lif_m~tt_functions.

    METHODS build_functions.
    METHODS build_virtual_from_plano.
    METHODS call_tcode           IMPORTING ir_order TYPE REF TO zif_order.
    METHODS schedule             IMPORTING ir_order TYPE REF TO zif_order.
    METHODS schedule_basic_dates IMPORTING ir_order TYPE REF TO zif_order.
    METHODS material_availability.
    METHODS capacity_availability.
    METHODS select_version.
    METHODS display_gantt.
    METHODS convert_planned.

ENDCLASS.

CLASS lcl_m_order IMPLEMENTATION.
  METHOD convert_planned.
    DATA lr_plano  TYPE REF TO zcl_order_plano.
    DATA lr_prodo  TYPE REF TO zcl_order_prodo.
    DATA aufnr     TYPE aufnr.
    DATA converted TYPE boolean.

    build_virtual_from_plano( ).
    TRY.
        lr_plano ?= mr_order.
        lr_prodo ?= mr_virtual.

        CALL FUNCTION 'CO_WORK210_ORDER_CONVERT'
          EXPORTING
            iv_plnum             = lr_plano->ms_plaf-plnum
            iv_autyp             = lr_prodo->ms_caufvd-autyp
            iv_auart             = lr_prodo->ms_caufvd-auart
          IMPORTING
            ev_aufnr             = aufnr
            ev_converted         = converted
          EXCEPTIONS
            category_not_allowed = 1
            order_not_found      = 2
            no_order_type        = 3
            error_in_plaf        = 4
            error_in_number      = 5
            internal_error       = 6
            OTHERS               = 7.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE zcl_msg=>co_status NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        MESSAGE aufnr TYPE zcl_msg=>co_status.
      CATCH cx_sy_move_cast_error.

    ENDTRY.
  ENDMETHOD.

  METHOD lif_m~handle_function.
    DATA lr_exc TYPE REF TO zcx_core.
    DATA lr_msg TYPE REF TO zcl_msg.

    TRY.
        CASE if_func.
          WHEN co_schedule.
            schedule( mr_order ).
          WHEN co_schedule_basic.
            schedule_basic_dates( mr_order ).
          WHEN co_tcode.
            mr_order->dialog( ).
          WHEN co_select_version.
            select_version( ).
          WHEN co_gantt.
            display_gantt( ).
          WHEN co_convert.
            convert_planned( ).
          WHEN co_prodversion.
            lr_msg = mr_order->change_prod_version_dialog( ).
            lr_msg->show( ).
          WHEN co_longtext.
            mr_order->edit_long_text( ).
          WHEN co_longtext_display.
            mr_order->display_long_text( ).
          WHEN co_totalamount.
            mr_order->change_total_quan_dialog( ).
          WHEN co_release.
            lr_msg = mr_order->release( ).
            lr_msg->show( ).
          WHEN co_material_availability.
            material_availability( ).
          WHEN co_capacity_availability.
            capacity_availability( ).
        ENDCASE.
      CATCH zcx_core INTO lr_exc.
        MESSAGE lr_exc TYPE zcl_msg=>co_status DISPLAY LIKE zcl_msg=>co_error.
    ENDTRY.
  ENDMETHOD.

  METHOD select_version.
    DATA lr_exc TYPE REF TO zcx_core.

    TRY.
        CALL FUNCTION 'Z_VERID_SELECT'
          EXPORTING
            it_mkal  = mr_order->mr_material->mt_mkal
            ir_order = mr_order.

      CATCH zcx_core INTO lr_exc.
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.

  METHOD display_gantt.
    CALL FUNCTION 'CO_ZF_GANTT_GRAPH'
      EXPORTING
        caufvd_imp = mr_order->ms_caufvd
        trtyp      = 'A'.
  ENDMETHOD.

  METHOD constructor.
    mr_order = ir_order.
    build_functions( ).
    build_virtual_from_plano( ).
  ENDMETHOD.

  METHOD lif_m~double_click.
    call_tcode( mr_order ).
  ENDMETHOD.

  METHOD lif_m~get_functions.
    et_functions = mt_functions.
  ENDMETHOD.

  METHOD build_functions.

    mt_functions = VALUE #( ( fcode = co_schedule              text = 'Auftrag Terminieren' )      ##NO_TEXT
                            ( fcode = co_schedule_basic        text = 'Eckterminierung' )          ##NO_TEXT
                            ( fcode = co_material_availability text = 'Verfügbarkeit Material' )   ##NO_TEXT
                            ( fcode = co_capacity_availability text = 'Verfügbarkeit Kapazität' )   ##NO_TEXT
                            ( fcode = co_release               text = 'Auftragsfreigabe' )         ##NO_TEXT
                            ( fcode = co_tcode                 text = 'Auftrag Transaktion' )      ##NO_TEXT
                            ( fcode = co_gantt                 text = 'Auftrag Gantt' )            ##NO_TEXT
                            ( fcode = co_select_version        text = 'Fertigungsversionen' )      ##NO_TEXT
                            ( fcode = co_prodversion           text = 'Fertigungsversion Ändern' ) ##NO_TEXT
                            ( fcode = co_longtext              text = 'Langtext Ändern' )          ##NO_TEXT
                            ( fcode = co_longtext_display      text = 'Langtext Anzeigen' )        ##NO_TEXT
                            ( fcode = co_totalamount           text = 'Gesamtmenge Ändern' ) )     ##NO_TEXT.

    TRY.
        DATA(lr_plano) = CAST zcl_order_plano( mr_order ).
        mt_functions = VALUE #( BASE mt_functions
                                ( fcode = co_virtual_order text = 'Virtuelle Auftrag' )   ##NO_TEXT
                                ( fcode = co_convert       text = 'Auftrag umsetzen' ) ) ##NO_TEXT.

      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.

  METHOD build_virtual_from_plano.
    DATA lr_plano TYPE REF TO zcl_order_plano.

    CHECK mr_virtual IS NOT BOUND.

    TRY.
        lr_plano ?= mr_order.
        mr_virtual ?= zcl_order_prodo=>factory( lr_plano->ms_caufvd-aufnr ).
      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.

  METHOD call_tcode.
    " TODO: parameter IR_ORDER is never used (ABAP cleaner)

    TRY.
        mr_order->dialog( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.

  METHOD schedule.
    " TODO: parameter IR_ORDER is never used (ABAP cleaner)

    TRY.
        DATA(lr_msg) = mr_order->schedule( ).
        lr_msg->show( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.

  METHOD schedule_basic_dates.
    " TODO: parameter IR_ORDER is never used (ABAP cleaner)

    TRY.
        mr_order->schedule_basic_dates_dialog( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.

  METHOD material_availability.
    TRY.
        mr_order->check_material_availability( )->set_use_grid( abap_true )->show( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.
  METHOD capacity_availability.
    TRY.
        DATA(lr_msg) = NEW zcl_msg( ).
        mr_order->check_capacity_availability( if_no_dialog = space ir_msg = lr_msg ).
        lr_msg->set_use_grid( abap_true )->show( ).
      CATCH zcx_core INTO DATA(lr_exc).
        MESSAGE lr_exc TYPE zcl_msg=>co_status.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
