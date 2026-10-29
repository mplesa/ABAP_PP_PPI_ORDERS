*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
CLASS lcl_order_table DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_table.
    METHODS: constructor IMPORTING if_table TYPE string
                                   ir_order TYPE REF TO zif_order.
  PRIVATE SECTION.
    DATA: mr_order TYPE REF TO zif_order,
          mf_table TYPE string.
ENDCLASS.
CLASS lcl_order_table IMPLEMENTATION.
  METHOD lif_table~rebuild.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
    ASSIGN lif_table~mr_table->* TO <lt_table>.
    CLEAR <lt_table>.
    lif_table~get( IMPORTING et_table  = <lt_table> ).
  ENDMETHOD.
  METHOD constructor.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
    mr_order = ir_order.
    mf_table = if_table.
    CREATE DATA lif_table~mr_table TYPE TABLE OF (mf_table).
    ASSIGN lif_table~mr_table->* TO <lt_table>.
    lif_table~get( IMPORTING et_table  = <lt_table> ).

  ENDMETHOD.
  METHOD lif_table~get.
    DATA: lr_plano TYPE REF TO zcl_order_plano.
    CASE mf_table.
      WHEN lif_table~co_kbko.
        APPEND mr_order->ms_kbko TO et_table.
      WHEN lif_table~co_aob.
      WHEN lif_table~co_affl.
        APPEND LINES OF mr_order->mt_affl TO et_table.
      WHEN lif_table~co_mara.
        APPEND mr_order->mr_material->mr_matnr->ms_mara TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_marc.
        APPEND mr_order->mr_material->ms_marc TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_mkal.
        APPEND LINES OF mr_order->mr_material->mt_mkal TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_makt.
        APPEND mr_order->mr_material->mr_matnr->ms_makt TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_afpo.
        APPEND mr_order->ms_afpod TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_caufvd.
        APPEND mr_order->ms_caufvd TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_jstat.
        APPEND LINES OF mr_order->mt_statuses TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_plaf.
        TRY .
            lr_plano ?= mr_order.
            APPEND lr_plano->ms_plaf TO et_table. "#EC CI_FLDEXT_OK
          CATCH cx_sy_move_cast_error.
        ENDTRY.
    ENDCASE.
  ENDMETHOD.
  METHOD lif_table~get_name.
    rf_name = mf_table.
  ENDMETHOD.
ENDCLASS.
