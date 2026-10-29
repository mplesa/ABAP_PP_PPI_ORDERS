INTERFACE zif_operation_sequance
  PUBLIC .

  TYPES tt_affl TYPE TABLE OF affld.

  DATA ms_affl TYPE affld READ-ONLY .
  CONSTANTS co_standard_sequance TYPE plnfolge VALUE '000000' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF co_type,
      standard    VALUE '0',
      parallel    VALUE '1',
      alternative VALUE '2',
    END OF co_type .
  CONSTANTS:
    BEGIN OF co_alignment,
      earliest_date TYPE cp_auschl VALUE '1',
      latest_date   TYPE cp_auschl VALUE '2',
    END OF co_alignment .
  CONSTANTS:
    BEGIN OF co_relationship,
      start  TYPE cp_tschl VALUE '1',
      finish TYPE cp_tschl VALUE '2',
    END OF co_relationship .
  DATA mr_order TYPE REF TO zif_order READ-ONLY .

  METHODS get_operations
    EXPORTING
      !et_operations TYPE zif_order=>tt_operations .
  METHODS get_successor_operation
    IMPORTING
      !ir_operation       TYPE REF TO zif_operation
    RETURNING
      VALUE(rr_successor) TYPE REF TO zif_operation
    RAISING
      zcx_no_successor .
  METHODS get_predecessor_operation
    IMPORTING
      !ir_operation         TYPE REF TO zif_operation
    RETURNING
      VALUE(rr_predecessor) TYPE REF TO zif_operation
    RAISING
      zcx_no_predecessor .
  METHODS get_operation
    IMPORTING
      !if_vornr           TYPE vornr
      !if_aplzl           TYPE co_aplzl OPTIONAL
    RETURNING
      VALUE(rr_operation) TYPE REF TO zif_operation
    RAISING
      zcx_operation_notfound .
  METHODS get_first_operation
    RETURNING
      VALUE(rr_operation) TYPE REF TO zif_operation
    RAISING
      zcx_operation_notfound .
  METHODS get_last_operation
    RETURNING
      VALUE(rr_operation) TYPE REF TO zif_operation
    RAISING
      zcx_operation_notfound .
ENDINTERFACE.
