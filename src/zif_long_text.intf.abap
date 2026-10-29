interface ZIF_LONG_TEXT
  public .

  methods HAS_LONG_TEXT
    returning
      value(RF_ANSWER) type FLAG .
  methods EDIT
    raising
      /GIB/CX_DCP .
  methods DISPLAY .
endinterface.
