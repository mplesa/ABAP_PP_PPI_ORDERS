interface ZIF_PEGGED_REQUIREMENT
  public .

  types:
    tt_t457t TYPE TABLE OF t457t .

  class-data GT_T457T type TT_T457T read-only .
  constants CO_PRODO type DELKZ value 'FE'. "#EC NOTEXT
  constants CO_PLANO type DELKZ value 'PA'. "#EC NOTEXT
  constants CO_PROCESS type DELKZ value 'BR'. "#EC NOTEXT
  constants CO_NETZPLAN type DELKZ value 'NE'. "#EC NOTEXT
  constants CO_MAINTENANCE type DELKZ value 'IH'. "#EC NOTEXT

  methods DISPLAY .
  methods GET
    exporting
      !EF_DATE type SY-DATUM
      !EF_NAME type CHAR40 .
endinterface.
