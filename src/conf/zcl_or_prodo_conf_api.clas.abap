class ZCL_OR_PRODO_CONF_API definition
  public
  inheriting from ZCL_ORDER_CONF_API
  create public .

public section.
protected section.

  methods POST_TIME_EVENTS
    redefinition .
  methods POST_TIME_TICKETS
    redefinition .
private section.
ENDCLASS.

CLASS ZCL_OR_PRODO_CONF_API IMPLEMENTATION.

  method POST_TIME_EVENTS.
  endmethod.

  METHOD post_time_tickets.
  ENDMETHOD.
ENDCLASS.
