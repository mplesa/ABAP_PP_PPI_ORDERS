interface ZIF_OBJID
  public .

  interfaces ZIF_DESCRIPTION .

  types:
    tt_objid type table of ref to zif_objid .

  constants CO_TYPE_WORKCENTER type CR_OBJTY value 'A'. "#EC NOTEXT
  constants CO_TYPE_WORKCENTER_ALIAS type CR_OBJTY value 'AA'. "#EC NOTEXT
  constants CO_TYPE_HIERARCHY type CR_OBJTY value 'H'. "#EC NOTEXT
  constants CO_TYPE_PRODUCTION_TOOL type CR_OBJTY value 'FH'. "#EC NOTEXT
  data MF_OBJID type CR_OBJID read-only .
  data MF_OBJTY type CR_OBJTY read-only .

  methods GET_CHILDREN
    exporting
      !ET_CHILDREN type TT_OBJID .
  methods GET_SUBTREE
    exporting
      !ET_SUBTREE type TT_OBJID .
endinterface.
