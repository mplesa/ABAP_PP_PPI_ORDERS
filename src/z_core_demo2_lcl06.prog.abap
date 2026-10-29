*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
CLASS lcl_operation_table DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_table.

    METHODS: constructor IMPORTING if_table     TYPE string
                                   ir_operation TYPE REF TO zif_operation.

  PRIVATE SECTION.
    DATA: mr_operation TYPE REF TO zif_operation,
          mf_table     TYPE string.
ENDCLASS.
CLASS lcl_operation_table IMPLEMENTATION.
  METHOD lif_table~rebuild.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
    ASSIGN lif_table~mr_table->* TO <lt_table>.
    CLEAR <lt_table>.
    lif_table~get( IMPORTING et_table  = <lt_table> ).
  ENDMETHOD.
  METHOD constructor.
    FIELD-SYMBOLS: <lt_table> TYPE ANY TABLE.
    mr_operation = ir_operation.
    mf_table = if_table.
    CREATE DATA lif_table~mr_table TYPE TABLE OF (mf_table).
    ASSIGN lif_table~mr_table->* TO <lt_table>.
    lif_table~get( IMPORTING et_table  = <lt_table> ).
  ENDMETHOD.
  METHOD lif_table~get.
    DATA: lr_kapid TYPE REF TO zcl_kapid.
    CASE mf_table.
      WHEN lif_table~co_crhd.
        APPEND mr_operation->mr_workcenter->ms_crhd TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_kako.
        LOOP AT mr_operation->mr_workcenter->mt_kapids INTO lr_kapid.
          APPEND lr_kapid->ms_kako TO et_table. "#EC CI_FLDEXT_OK
        ENDLOOP.
      WHEN lif_table~co_kbed.
        APPEND LINES OF mr_operation->mt_kbed TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_afvgd.
        APPEND mr_operation->ms_afvgd TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_jstat.
        APPEND LINES OF mr_operation->mt_statuses TO et_table. "#EC CI_FLDEXT_OK
      WHEN lif_table~co_affl.
        APPEND mr_operation->mr_sequance->ms_affl TO et_table. "#EC CI_FLDEXT_OK
    ENDCASE.
  ENDMETHOD.
  METHOD lif_table~get_name.
    rf_name = mf_table.
  ENDMETHOD.
ENDCLASS.
