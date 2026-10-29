interface ZIF_DESCRIPTION
  public .

  constants CO_LONG_SEPARATOR type STRING value '-->' ##NO_TEXT.

  methods GET
    returning
      value(RF_VALUE) type CHAR64 .
  methods GET_LONG
    returning
      value(RF_VALUE) type STRING .
  methods GET_ICON
    returning
      value(RF_ICON) type TV_IMAGE .
endinterface.
