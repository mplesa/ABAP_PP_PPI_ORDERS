INTERFACE zif_confirmation
  PUBLIC .

  TYPES:
    BEGIN OF ts_ticket,
      recordtype         TYPE co_satza,
      logdate            TYPE ldate,
      logtime            TYPE ltime,
      fin_conf           TYPE aueru_vs,
      clear_res          TYPE ausbu,
      postg_date         TYPE buchdatum,
      dev_reason         TYPE co_agrnd,
      conf_text          TYPE co_rtext,

      conf_quan_unit     TYPE ru_vorme,
      conf_quan_unit_iso TYPE isocd_unit,
      yield              TYPE ru_lmnga,

      scrap              TYPE ru_xmnga,

      rework             TYPE ru_rmnga, "only for PP

      plant              TYPE werks_d,
      capa_category      TYPE kapart, "only for PP
      split              TYPE cy_split, "only for PP
      pers_no            TYPE co_pernr,
      timeid_no          TYPE dzausw,
      wagetype           TYPE lohnart,
      ex_created_by      TYPE ru_exnam,
      ex_created_date    TYPE ru_exerd,
      ex_created_time    TYPE ru_exerz,
      ex_ident           TYPE ru_extid_char,
    END OF ts_ticket .
  TYPES:
    BEGIN OF ts_activity,
      conf_acti_unit1     TYPE  co_ismngeh,
      conf_acti_unit1_iso TYPE  isocd_unit,
      conf_activity1      TYPE  ru_ismng,
      no_remn_acti1       TYPE  co_leikz,
      conf_acti_unit2     TYPE  co_ismngeh,
      conf_acti_unit2_iso TYPE  isocd_unit,
      conf_activity2      TYPE  ru_ismng,
      no_remn_acti2       TYPE  co_leikz,
      conf_acti_unit3     TYPE  co_ismngeh,
      conf_acti_unit3_iso TYPE  isocd_unit,
      conf_activity3      TYPE  ru_ismng,
      no_remn_acti3       TYPE  co_leikz,
      conf_acti_unit4     TYPE  co_ismngeh,
      conf_acti_unit4_iso TYPE  isocd_unit,
      conf_activity4      TYPE  ru_ismng,
      no_remn_acti4       TYPE  co_leikz,
      conf_acti_unit5     TYPE  co_ismngeh,
      conf_acti_unit5_iso TYPE  isocd_unit,
      conf_activity5      TYPE  ru_ismng,
      no_remn_acti5       TYPE  co_leikz,
      conf_acti_unit6     TYPE  co_ismngeh,
      conf_acti_unit6_iso TYPE  isocd_unit,
      conf_activity6      TYPE  ru_ismng,
      no_remn_acti6       TYPE  co_leikz,
      target_acti1        TYPE  ru_target_activity,
      target_acti2        TYPE  ru_target_activity,
      target_acti3        TYPE  ru_target_activity,
      target_acti4        TYPE  ru_target_activity,
      target_acti5        TYPE  ru_target_activity,
      target_acti6        TYPE  ru_target_activity,
    END OF ts_activity .
  TYPES:
    BEGIN OF ts_business_process,
      conf_bus_proc_unit1     TYPE  ru_iprze,
      conf_bus_proc_unit1_iso TYPE  isocd_unit,
      conf_buss_proc1         TYPE  ru_iprzs,
      no_remn_bus_proc1       TYPE  ru_iprzk,
      target_bus_proc1        TYPE  ru_target_bus_proc,
    END OF ts_business_process .
  TYPES:
    BEGIN OF ts_time_event.
      INCLUDE TYPE ts_ticket AS ticket.
      INCLUDE TYPE ts_activity AS activity.
      INCLUDE TYPE ts_business_process AS business_process.
  TYPES: END OF ts_time_event .
  TYPES:
    BEGIN OF ts_time_ticket.
      INCLUDE                 TYPE ts_ticket AS ticket.
      INCLUDE                 TYPE ts_activity AS activity.
      INCLUDE                 TYPE ts_business_process AS business_process.
  TYPES:
      exec_start_date         TYPE  ru_isdd,
      exec_start_time         TYPE  ru_isdz,
      setup_fin_date          TYPE  ru_ierd,
      setup_fin_time          TYPE  ru_ierz,
      proc_start_date         TYPE  ru_isbd,
      proc_start_time         TYPE  ru_isbz,
      proc_fin_date           TYPE  ru_iebd,
      proc_fin_time           TYPE  ru_iebz,
      teardown_start_date     TYPE  ru_isad,
      teardown_start_time     TYPE  ru_isaz,
      exec_fin_date           TYPE  ru_iedd,
      exec_fin_time           TYPE  ru_iedz,
      fcst_fin_date           TYPE  co_pedd,
      fcst_fin_time           TYPE  co_pedz,
      std_unit1               TYPE  vgwrteh,
      std_unit1_iso           TYPE  isocd_unit,
      forcast_std_val1        TYPE  co_schaetz,
      std_unit2               TYPE  vgwrteh,
      std_unit2_iso           TYPE  isocd_unit,
      forcast_std_val2        TYPE  co_schaetz,
      std_unit3               TYPE  vgwrteh,
      std_unit3_iso           TYPE  isocd_unit,
      forcast_std_val3        TYPE  co_schaetz,
      std_unit4               TYPE  vgwrteh,
      std_unit4_iso           TYPE  isocd_unit,
      forcast_std_val4        TYPE  co_schaetz,
      std_unit5               TYPE  vgwrteh,
      std_unit5_iso           TYPE  isocd_unit,
      forcast_std_val5        TYPE  co_schaetz,
      std_unit6               TYPE  vgwrteh,
      forcast_std_val6        TYPE  co_schaetz,
      forcast_bus_proc_unit1  TYPE  opre1,
      forc_bus_proc_unit1_iso TYPE  isocd_unit,
      forcast_bus_proc_val1   TYPE  oprz1,
      suitability             TYPE  qualf,
      no_of_employee          TYPE  anzms,
      wagegroup               TYPE  lohngrp,
      break_unit              TYPE  dzeier,
      break_unit_iso          TYPE  isocd_unit,
      break_time              TYPE  iserh,
      wip_batch               TYPE  co_wipbbatch,
      vendrbatch              TYPE  lichn,

      me_sfc_id               TYPE  co_mes_int_sfcid, "only for PP
      me_2nd_conf_qty         TYPE  co_mes_second_conf_qty, "only for PP
    END OF ts_time_ticket .

  CONSTANTS:
    BEGIN OF co_time_event_type,
      start     TYPE char2 VALUE '10',
      partial   TYPE char2 VALUE '20',
      interrupt TYPE char2 VALUE '30',
      finish    TYPE char2 VALUE '40',
    END OF co_time_event_type .
  CONSTANTS:
    BEGIN OF co_time_event_record_type,
      setup      TYPE char1 VALUE 'R',
      processing TYPE char1 VALUE 'B',
      teardown   TYPE char1 VALUE 'A',
      activity   TYPE char1 VALUE 'V',
    END OF co_time_event_record_type .
  CONSTANTS co_time_event_record_types TYPE string VALUE 'RBAV' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF co_time_event,
      setup_start               TYPE co_satza VALUE 'R10',
      setup_partial             TYPE co_satza VALUE 'R20',
      setup_interrupt           TYPE co_satza VALUE 'R30',
      setup_finish              TYPE co_satza VALUE 'R40',

      processing_start          TYPE co_satza VALUE 'B10',
      processing_partial        TYPE co_satza VALUE 'B20',
      processing_interrupt      TYPE co_satza VALUE 'B30',
      processing_finish         TYPE co_satza VALUE 'B40',

      teardown_start            TYPE co_satza VALUE 'A10',
      teardown_partial          TYPE co_satza VALUE 'A20',
      teardown_interrupt        TYPE co_satza VALUE 'A30',
      teardown_finish           TYPE co_satza VALUE 'A40',

      activity_confirmation     TYPE co_satza VALUE 'V00',
      partial_variable_activity TYPE co_satza VALUE 'V20',
      finish_variable_activity  TYPE co_satza VALUE 'V40',
    END OF co_time_event .
  CONSTANTS co_time_ticket_record_types TYPE string VALUE 'LIT' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF co_time_ticket,
      automatic_final_confirmation TYPE co_satza VALUE 'L00',
      partial_confirmation         TYPE co_satza VALUE 'L20',
      partial_confirmation_pm      TYPE co_satza VALUE 'I20',
      partial_confirmation_ps      TYPE co_satza VALUE 'T20',
      final_confirmation           TYPE co_satza VALUE 'L40',
      final_confirmation_pm        TYPE co_satza VALUE 'I40',
      final_confirmation_ps        TYPE co_satza VALUE 'T40',
    END OF co_time_ticket .

  METHODS get_afrud_entry
    RETURNING
      VALUE(rs_afrud) TYPE afrud .
  METHODS get_ticket
    RETURNING
      VALUE(rs_ticket) TYPE ts_ticket .
  METHODS get_activity
    RETURNING
      VALUE(rs_activity) TYPE ts_activity .
  METHODS get_business_process
    RETURNING
      VALUE(rs_business_process) TYPE ts_business_process .
  METHODS get_time_event
    RETURNING
      VALUE(rs_time_event) TYPE ts_time_event .
  METHODS get_time_ticket
    RETURNING
      VALUE(rs_time_ticket) TYPE ts_time_ticket .
  METHODS set_afrud
    IMPORTING
      !is_afrud TYPE afrud .
  METHODS set_time_ticket
    IMPORTING
      !is_time_ticket TYPE ts_time_ticket .
  METHODS set_time_event
    IMPORTING
      !is_time_event TYPE ts_time_event .
ENDINTERFACE.
