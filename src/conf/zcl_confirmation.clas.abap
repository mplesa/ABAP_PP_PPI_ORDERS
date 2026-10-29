class ZCL_CONFIRMATION definition
  public
  create public .

public section.

  interfaces ZIF_CONFIRMATION .
protected section.

  data MS_AFRUD type AFRUD .
private section.

  aliases CO_TIME_EVENT
    for ZIF_CONFIRMATION~CO_TIME_EVENT .
  aliases CO_TIME_EVENT_TYPE
    for ZIF_CONFIRMATION~CO_TIME_EVENT_TYPE .
  aliases CO_TIME_TICKET
    for ZIF_CONFIRMATION~CO_TIME_TICKET .
  aliases GET_ACTIVITY
    for ZIF_CONFIRMATION~GET_ACTIVITY .
  aliases GET_AFRUD_ENTRY
    for ZIF_CONFIRMATION~GET_AFRUD_ENTRY .
  aliases GET_BUSINESS_PROCESS
    for ZIF_CONFIRMATION~GET_BUSINESS_PROCESS .
  aliases GET_TICKET
    for ZIF_CONFIRMATION~GET_TICKET .
  aliases GET_TIME_EVENT
    for ZIF_CONFIRMATION~GET_TIME_EVENT .
  aliases GET_TIME_TICKET
    for ZIF_CONFIRMATION~GET_TIME_TICKET .
ENDCLASS.

CLASS ZCL_CONFIRMATION IMPLEMENTATION.

METHOD zif_confirmation~get_activity.
  DATA(ls_time_event)  = get_time_event( ).
  ls_time_event-activity = rs_activity.
ENDMETHOD.

  METHOD zif_confirmation~get_afrud_entry.
    rs_afrud = ms_afrud.
  ENDMETHOD.

METHOD zif_confirmation~get_business_process.
  DATA(ls_time_event)  = get_time_event( ).
  ls_time_event-business_process = rs_business_process.
ENDMETHOD.

METHOD zif_confirmation~get_ticket.

  IF ms_afrud-satza CA zif_confirmation=>co_time_event_record_types.
    rs_ticket = get_time_event( )-ticket.
  ELSE."should allways be TIME TICKET
    rs_ticket = get_time_ticket( )-ticket.
  ENDIF.

ENDMETHOD.

METHOD zif_confirmation~get_time_event.
*the only difference between PP and PI is the KEY wich is managed by
*the confirmation API
  DATA: ls_bapi_pp_timeevent TYPE bapi_pp_timeevent.
  CALL FUNCTION 'MAP2E_AFRUD_TO_PP_TIMEEVENT'
    EXPORTING
      afrud             = ms_afrud
    CHANGING
      bapi_pp_timeevent = ls_bapi_pp_timeevent.
  MOVE-CORRESPONDING ls_bapi_pp_timeevent TO rs_time_event.
ENDMETHOD.

METHOD zif_confirmation~get_time_ticket.
*the only difference between PP and PI is the KEY wich is managed by
*the confirmation API
  DATA: ls_bapi_pp_timeticket TYPE bapi_pp_timeticket.
  CALL FUNCTION 'MAP2E_AFRUD_TO_PP_TIMETICKET'
    EXPORTING
      afrud              = ms_afrud
    CHANGING
      bapi_pp_timeticket = ls_bapi_pp_timeticket.
  MOVE-CORRESPONDING ls_bapi_pp_timeticket TO rs_time_ticket.
ENDMETHOD.

METHOD zif_confirmation~set_afrud.
  ms_afrud = is_afrud.
ENDMETHOD.

METHOD zif_confirmation~set_time_event.
*the only difference between PP and PI is the KEY wich is managed by
*the confirmation API
  DATA ls_bapi_pp_timeevent TYPE bapi_pp_timeevent.
  MOVE-CORRESPONDING is_time_event TO ls_bapi_pp_timeevent.

  CALL FUNCTION 'MAP2I_PP_TIMEEVENT_TO_AFRUD'
    EXPORTING
      bapi_pp_timeevent         = ls_bapi_pp_timeevent
    CHANGING
      afrud                     = ms_afrud
    EXCEPTIONS
      error_converting_iso_code = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMETHOD.

METHOD zif_confirmation~set_time_ticket.
*the only difference between PP and PI is the KEY wich is managed by
*the confirmation API
  DATA ls_bapi_pp_timeticket TYPE bapi_pp_timeticket.
  MOVE-CORRESPONDING is_time_ticket TO ls_bapi_pp_timeticket.
  CALL FUNCTION 'MAP2I_PP_TIMETICKET_TO_AFRUD'
    EXPORTING
      bapi_pp_timeticket        = ls_bapi_pp_timeticket
    CHANGING
      afrud                     = ms_afrud
    EXCEPTIONS
      error_converting_iso_code = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDMETHOD.
ENDCLASS.
