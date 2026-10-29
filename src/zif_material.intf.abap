INTERFACE zif_material
  PUBLIC .

  INTERFACES zif_long_text .

  ALIASES display_long_text
    FOR zif_long_text~display .
  ALIASES edit_long_text
    FOR zif_long_text~edit .
  ALIASES has_long_text
    FOR zif_long_text~has_long_text .

  TYPES: tt_makt_head TYPE TABLE OF pre09,
         tt_mara_head TYPE TABLE OF pre03.

  DATA ms_mara TYPE mara READ-ONLY .
  DATA ms_makt TYPE makt READ-ONLY .

  METHODS unit_conversion
    IMPORTING
      !if_unit_from TYPE meins
      !if_unit_to   TYPE meins
    CHANGING
      !cf_amount    TYPE any
    RAISING
      zcx_unit_conversion .
ENDINTERFACE.
