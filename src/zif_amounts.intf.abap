interface ZIF_AMOUNTS
  public .

  methods GET_UNIT
    returning
      value(RF_UNIT) type MEINS .
  methods GET
    returning
      value(RF_AMOUNT) type Z_AMOUNT .
  methods GET_NET
    returning
      value(RF_AMOUNT) type Z_AMOUNT .
  methods GET_GROSS
    returning
      value(RF_AMOUNT) type Z_AMOUNT .
  methods GET_OPEN
    returning
      value(RF_AMOUNT) type Z_AMOUNT .
endinterface.
