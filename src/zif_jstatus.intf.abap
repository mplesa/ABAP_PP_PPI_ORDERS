interface ZIF_JSTATUS
  public .

  data MT_STATUSES type TTJSTAT .
  constants CO_DSPT type J_STATUS value 'I0117' ##NO_TEXT.
  constants CO_PCNF type J_STATUS value 'I0010' ##NO_TEXT.
  constants CO_NSCH type J_STATUS value 'I0243' ##NO_TEXT.
  constants CO_NTUP type J_STATUS value 'I0118' ##NO_TEXT.
  constants CO_PRT type J_STATUS value 'I0007' ##NO_TEXT.
  constants CO_CNF type J_STATUS value 'I0009' ##NO_TEXT.
  constants CO_DLV type J_STATUS value 'I0012' ##NO_TEXT.
  constants CO_LKD type J_STATUS value 'I0043' ##NO_TEXT.
  constants CO_DLT type J_STATUS value 'I0013' ##NO_TEXT.
  constants CO_TECO type J_STATUS value 'I0045' ##NO_TEXT.
  constants CO_CLSD type J_STATUS value 'I0046' ##NO_TEXT.
  constants CO_DLFL type J_STATUS value 'I0076' ##NO_TEXT.
  constants CO_MSPT type J_STATUS value 'I0004' ##NO_TEXT.
  constants CO_FREE type J_STATUS value 'I0002' ##NO_TEXT.
  constants CO_CRTD type J_STATUS value 'I0001' ##NO_TEXT.
  constants CO_CREF type J_STATUS value 'I0270' ##NO_TEXT.
  constants CO_ILAS type J_STATUS value 'I0281' ##NO_TEXT.
  constants CO_EXTS type J_STATUS value 'I0484' ##NO_TEXT.
  constants CO_UMGP type J_STATUS value 'I0037' ##NO_TEXT.
  constants CO_MANC type J_STATUS value 'I0420' ##NO_TEXT.
  constants CO_MACM type J_STATUS value 'I0340' ##NO_TEXT.
  constants CO_APG type J_STATUS value 'I0322' ##NO_TEXT.
  constants CO_NCMP type J_STATUS value 'I0015' ##NO_TEXT.
  constants CO_NFHM type J_STATUS value 'I0180' ##NO_TEXT.
  constants CO_INAK type J_STATUS value 'I0320' ##NO_TEXT.
*! Teilfreigabe
  constants CO_TREL type J_STATUS value 'I0042' ##NO_TEXT.
  constants CO_INITIAL_ORDER_NUMBER type J_STONR value '00' ##NO_TEXT.
  constants CO_PREL type J_STATUS value 'I0042' ##NO_TEXT.

  methods HAS_STATUS
    importing
      !IF_STATUS type J_STATUS
    returning
      value(RF_ANSWER) type FLAG .
  methods SET_STATUS
    importing
      !IF_STATUS type J_STATUS
    raising
      ZCX_CORE .
  methods REMOVE_STATUS
    importing
      !IF_STATUS type J_STATUS
    raising
      ZCX_CORE .
  methods GET_STATUS_TEXT
    exporting
      !EF_STTXT type /GIB/DCP_ORDER_STTXT
      !EF_USTXT type /GIB/DCP_ASTTX .
endinterface.
