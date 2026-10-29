class ZCL_PIT definition
  public
  create public .

public section.

  constants CO_MIN type Z_PIT value -2147483648 ##NO_TEXT.
  constants CO_REL_I_DATE type I value 722816 ##NO_TEXT.
  constants CO_SECONDS_PER_DAY type I value 86400 ##NO_TEXT.
  constants CO_TIME_0000 type SY-UZEIT value '000000' ##NO_TEXT.
  constants CO_TIME_2400 like SY-UZEIT value '240000' ##NO_TEXT.
  class-data CO_DAYS_MAX type Z_PIT read-only value 24855 ##NO_TEXT.
  class-data CO_MAX type Z_PIT read-only value 2147483647 ##NO_TEXT.

  class-methods CLASS_CONSTRUCTOR .
  class-methods CONVERT_DATE_TIME
    importing
      !IF_DATE type SYDATUM
      !IF_TIME type SYUZEIT optional
    returning
      value(RF_PIT) type Z_PIT .
  class-methods CONVERT_PIT
    importing
      !IF_PIT type Z_PIT
      !IF_ENDTERMIN type FLAG optional
    exporting
      !EF_DATE type SYDATUM
      !EF_TIME type SYUZEIT .
  class-methods GET_SY_PIT
    returning
      value(RF_PIT) type Z_PIT .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_PIT IMPLEMENTATION.


  METHOD convert_date_time.
    DATA: lf_cxtp_date TYPE i,
          lf_cxtp_time TYPE i,
          lf_cxtp_days TYPE i.

    lf_cxtp_date = if_date.
    lf_cxtp_time = if_time.

    IF lf_cxtp_date < co_rel_i_date.
      rf_pit = 0.
    ELSE.
*   Zeitpunkt berechnen
*   Prüfen, ob bei der Rechnung Überlauf entsteht.
      lf_cxtp_days = lf_cxtp_date - co_rel_i_date.
      IF lf_cxtp_days >= co_days_max.
        rf_pit = co_days_max * co_seconds_per_day.
      ELSE.
        rf_pit = lf_cxtp_days * co_seconds_per_day + lf_cxtp_time.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD convert_pit.
    DATA: lf_cxtp_date TYPE i,
          lf_cxtp_time TYPE i.

    lf_cxtp_date = if_pit DIV co_seconds_per_day + co_rel_i_date.
    lf_cxtp_time = if_pit MOD co_seconds_per_day.

    IF if_endtermin = space OR lf_cxtp_time <> 0.
      ef_date = lf_cxtp_date.
      ef_time = lf_cxtp_time.
    ELSE.
      lf_cxtp_date = lf_cxtp_date - 1.
      ef_date = lf_cxtp_date.
      ef_time = co_time_2400.
    ENDIF.
  ENDMETHOD.


  METHOD get_sy_pit.
    rf_pit = convert_date_time( if_date = sy-datum
                                if_time = sy-uzeit ).
  ENDMETHOD.


  METHOD class_constructor.
* Calculation CO_MAX (Maximum PIT)
    DATA(lr_max) = cl_abap_exceptional_values=>get_max_value( co_max ).
    ASSIGN lr_max->* TO FIELD-SYMBOL(<lf_max>).
    IF <lf_max> IS ASSIGNED.
      co_max = <lf_max>.
    ELSE.
* Whatever went wrong, we fall back to the "old" value of max int4
      co_max = 2147483647.
    ENDIF.

* It should be cut at 31.12.9999, 23:59:59 as SAP did it
    IF co_max > 253086767999.
      co_max = 253086767999.
    ENDIF.

* Now calculate how many days these are since 01.01.1980
    co_days_max = co_max DIV co_seconds_per_day.
  ENDMETHOD.
ENDCLASS.
