interface ZIF_CORE_CONSTANTS
  public .

* Order categories (SART)
* TODO: values to be confirmed
  constants:
    begin of co_sart,
      plano   type char1 value 'P',
      prodo   type char1 value 'F',
      process type char1 value 'B',
      iho     type char1 value 'I',
      network type char1 value 'N',
    end of co_sart .
* TODO: values to be confirmed
  constants co_linetype_plano type char1 value 'P' ##NO_TEXT.
endinterface.
