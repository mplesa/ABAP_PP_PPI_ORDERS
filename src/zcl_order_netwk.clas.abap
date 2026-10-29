CLASS zcl_order_netwk DEFINITION
  PUBLIC
  INHERITING FROM zcl_order_prodo
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    METHODS build_pegged_requirement_head
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_ORDER_NETWK IMPLEMENTATION.

  METHOD build_pegged_requirement_head.
    ms_pegged_requirement_head-delkz = zif_pegged_requirement=>co_prodo.
    ms_pegged_requirement_head-delnr = ms_caufvd-aufnr.
    ms_pegged_requirement_head-delps = 1.
    ms_pegged_requirement_head-matnr = ms_caufvd-matnr.
    ms_pegged_requirement_head-werks = ms_caufvd-werks.
  ENDMETHOD.
ENDCLASS.
