class ZCL_SCREEN definition
  public
  create public .

*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods CALL_POPUP
    importing
      !IF_COL1 type I default 5
      !IF_LIN1 type I default 5 .
  methods CALL .
  methods CONSTRUCTOR
    importing
      !IR_FLOW type ref to ZIF_SCREEN_FLOW optional .
  methods SET_FLOW
    importing
      !IR_FLOW type ref to ZIF_SCREEN_FLOW .
  methods GET_FLOW
    returning
      value(RR_FLOW) type ref to ZIF_SCREEN_FLOW .
  methods CALL_DEFAULT .
protected section.
*"* do not include other source files here!!!
private section.
*"* do not include other source files here!!!

  data MR_FLOW type ref to ZIF_SCREEN_FLOW .
ENDCLASS.

CLASS ZCL_SCREEN IMPLEMENTATION.

METHOD call.
  CALL FUNCTION 'Z_SCREEN'
    EXPORTING
      ir_flow = mr_flow.
ENDMETHOD.

  METHOD call_popup.
    CALL FUNCTION 'Z_POPUPSCREEN'
      EXPORTING
        ir_flow = mr_flow
        if_col1 = if_col1
        if_lin1 = if_lin1.
  ENDMETHOD.

METHOD constructor.
  IF ir_flow IS BOUND.
    mr_flow = ir_flow.
    mr_flow->mr_screen = me.
  ENDIF.
ENDMETHOD.

method GET_FLOW.
  rr_flow = mr_flow.
endmethod.

METHOD set_flow.
  IF mr_flow IS BOUND.
    CLEAR mr_flow->mr_screen.
  ENDIF.
  mr_flow = ir_flow.
  mr_flow->mr_screen = me.
ENDMETHOD.

METHOD CALL_DEFAULT.
  CALL FUNCTION 'Z_SCREEN_DEFAULT'
    EXPORTING
      ir_flow = mr_flow.
ENDMETHOD.
ENDCLASS.
