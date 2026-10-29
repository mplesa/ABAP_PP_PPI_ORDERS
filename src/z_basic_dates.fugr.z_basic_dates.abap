FUNCTION z_basic_dates.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IF_TITLE) TYPE  CUA_TIT_TX OPTIONAL
*"  CHANGING
*"     REFERENCE(CF_SCHEDULING_TYPE) TYPE  TERMKZ
*"  RAISING
*"----------------------------------------------------------------------
  gr_data = NEW #( if_title = if_title
                   if_pit = cf_pit
                   if_scheduling_type = cf_scheduling_type  ).

  CALL SCREEN 100 STARTING AT 20 05.

  cf_pit = gr_data->get_pit( ).
  cf_scheduling_type = gr_data->get_scheduling_type( ).
  CLEAR: caufvd,
         gr_data.
ENDFUNCTION.
