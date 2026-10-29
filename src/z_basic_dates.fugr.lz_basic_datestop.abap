FUNCTION-POOL Z_BASIC_DATES.      "MESSAGE-ID ..

TABLES: caufvd.
CLASS lcl_basic_schedule DEFINITION.
  PUBLIC SECTION.
    DATA: mf_title        TYPE cua_tit_tx,
          mf_date         TYPE sydatum,
          mf_time         TYPE syuzeit,
          mf_user_command TYPE sy-ucomm,
          mr_caufvd       TYPE REF TO caufvd.

    CONSTANTS: BEGIN OF co_scheduling_type,
                 forward TYPE termkz VALUE '1',
               END OF co_scheduling_type.
    METHODS: constructor IMPORTING if_pit             TYPE /gib/pit
                                   if_scheduling_type TYPE termkz
                                   if_title           TYPE cua_tit_tx,
      get_scheduling_type_entry RETURNING VALUE(value) TYPE t482,
      is_time_of_day_required RETURNING VALUE(value) TYPE char1,
      get_pit RETURNING VALUE(value) TYPE /gib/pit,
      get_scheduling_type RETURNING VALUE(value) TYPE termkz.
ENDCLASS.
CLASS lcl_basic_schedule IMPLEMENTATION.
  METHOD constructor.

    mf_title = if_title.
    IF mf_title IS INITIAL.
      mf_title = 'Ecktermine'(001).
    ENDIF.

    DATA(lf_pit) = if_pit.
    IF lf_pit IS INITIAL.
      lf_pit = /gib/cl_pit=>get_sy_pit( ).
    ENDIF.
    /gib/cl_pit=>convert_pit( EXPORTING if_pit = lf_pit
                              IMPORTING ef_date = mf_date
                                        ef_time = mf_time ).

    get REFERENCE OF caufvd INTO mr_caufvd.
    mr_caufvd->terkz = if_scheduling_type.
    IF mr_caufvd->terkz IS INITIAL.
      mr_caufvd->terkz = co_scheduling_type-forward.
    ENDIF.

  ENDMETHOD.
  METHOD get_scheduling_type_entry.
    READ TABLE zcl_order=>gt_scheduling_type INTO value WITH TABLE KEY termkz = mr_caufvd->terkz.
  ENDMETHOD.
  METHOD get_pit.
    value = /gib/cl_pit=>convert_date_time( if_date = mf_date if_time = mf_time ).
  ENDMETHOD.
  METHOD get_scheduling_type.
    value = mr_caufvd->terkz.
  ENDMETHOD.
  METHOD is_time_of_day_required.
    IF get_scheduling_type_entry( )-eck_uhrzt IS INITIAL."date with time
      value = 0."no
    ELSE.
      value = 1."yes
    ENDIF.
  ENDMETHOD.
ENDCLASS.

DATA: gr_data TYPE REF TO lcl_basic_schedule.
