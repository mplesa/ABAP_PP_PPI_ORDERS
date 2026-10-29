class ZCL_MSG definition
  public
  create public .

*"* do not include other source files here!!!
*"* do not include other source files here!!!
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  interfaces /GIB/IF_MSG_QUEUE .

  constants CO_ERROR type SYMSGTY value 'E' ##NO_TEXT.
  constants CO_SUCCESS type SYMSGTY value 'S' ##NO_TEXT.
  constants CO_STATUS type SYMSGTY value 'S' ##NO_TEXT.
  constants CO_INFO type SYMSGTY value 'I' ##NO_TEXT.
  constants CO_WARNING type SYMSGTY value 'W' ##NO_TEXT.
  constants CO_ABEND type SYMSGTY value 'A' ##NO_TEXT.
  data M_ERR_OCC type XFELD read-only .
  data M_EXIT_CODE type XFELD read-only .

  methods GET_COUNT
    returning
      value(COUNT) type SY-TABIX .
  methods CONSTRUCTOR
    importing
      !MID type SY-MSGID default /GIB/CL_DCP_TYCO=>CO_MESSAGE_ID
      !TITLE type C optional .
  methods SET
    importing
      !MID type SY-MSGID default SPACE
      !NUM type SY-MSGNO
      !PA1 type C default SPACE
      !PA2 type C default SPACE
      !PA3 type C default SPACE
      !PA4 type C default SPACE
      !TYP type SY-MSGTY default 'S'
      !NO_DUPLICATE type XFLAG optional
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods SET_T100
    importing
      !IR_T100 type ref to IF_T100_MESSAGE
      !TYP type SY-MSGTY default 'S'
      !NO_DUPLICATE type XFLAG optional
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods SHOW
    importing
      !TITLE type C optional
      !IF_BATCH_LIST_TYPE type C default 'J'
    preferred parameter TITLE
    returning
      value(COUNT) type SY-TABIX .
  methods RESET
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods GET_MSG_TAB
    returning
      value(RT_MSG_TAB) type MSG_TAB_TYPE .
  methods APPEND
    importing
      !IR_MSG type ref to ZCL_MSG
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods GET_BAPIRET2_TAB
    returning
      value(RT_BAPIRET2) type BAPIRET2_T .
  methods ADD_BAPIRET2_TAB
    importing
      !IT_BAPIRET2 type BAPIRET2_T
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods SET_USE_GRID
    importing
      !IF_VALUE type FLAG
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods REMOVE_MSG_TYPE
    importing
      !IF_TYPE type SYMSGTY
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods SY_SET
    importing
      value(NO_DUPLICATE) type XFELD optional
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods SET_ALL_AS_TYPE
    importing
      !IF_TYPE type SY-MSGTY default 'S'
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods SET_EXC
    importing
      !IR_EXC type ref to CX_ROOT
      !TYP type SY-MSGTY default 'E'
      !NO_DUPLICATE type XFLAG optional
    returning
      value(RR_ME) type ref to ZCL_MSG .
  methods HAS_TYPE
    importing
      !IF_TYPE type SY-MSGTY default 'S'
    returning
      value(RF_ANSWER) type FLAG .
  methods SET_EXIT_CODE
    importing
      !IF_EXIT_CODE type CHAR1
    returning
      value(RR_ME) type ref to ZCL_MSG .
  class-methods EVALUATE_OBJECT
    importing
      !IR_OBJECT_REFERENCE type ref to OBJECT
    returning
      value(RR_MSG_OBJECT) type ref to ZCL_MSG .
protected section.

  data M_MID type SY-MSGID .
  data M_TITLE type SY-TITLE .
  data M_MSG_TAB type MSG_TAB_TYPE .
  data MF_USE_GRID type FLAG .

  methods P_SHOW_LIST
    importing
      !TITLE type C optional
      !IF_BATCH_LIST_TYPE type C default 'J'
    returning
      value(L_EXIT_COMMAND) type BAL_S_EXCM .
*"* do not include other source files here!!!
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_MSG IMPLEMENTATION.

  METHOD /gib/if_msg_queue~add_bapireturn.
    add_bapiret2_tab( it_bapiret2 ).

  ENDMETHOD.

  METHOD /gib/if_msg_queue~add_bdcmsgcoll.
    DATA: ls_msg TYPE bdcmsgcoll,
          lf_msgno TYPE sy-msgno.

    LOOP AT it_msg INTO ls_msg.
      lf_msgno = ls_msg-msgnr.
      set( mid          = ls_msg-msgid
           num          = lf_msgno
           pa1          = ls_msg-msgv1
           pa2          = ls_msg-msgv2
           pa3          = ls_msg-msgv3
           pa4          = ls_msg-msgv4
           typ          = ls_msg-msgtyp
           no_duplicate = ' '     ).

    ENDLOOP.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~add_exception_msg.
    set_exc( ir_exc = ir_exception
             typ          = if_msgty
             no_duplicate = if_no_duplicate ).

  ENDMETHOD.

  method /GIB/IF_MSG_QUEUE~ADD_MSG.
    set( mid          = if_mid
        num          = if_num
        pa1          = if_pa1
        pa2          = if_pa2
        pa3          = if_pa3
        pa4          = if_pa4
        typ          = if_typ
        no_duplicate = if_no_duplicate    ).

  endmethod.

  METHOD /gib/if_msg_queue~add_msg_queue.
    DATA: lt_msg TYPE /gib/dcv_msg_t,
          ls_msg TYPE /gib/dcv_msg_s.

    IF NOT ir_msg IS INITIAL.
      lt_msg = ir_msg->get_msg_tab( ).
    ENDIF.
    LOOP AT lt_msg INTO ls_msg.
      set( mid = ls_msg-id
           num = ls_msg-no
           typ = ls_msg-type
           pa1 = ls_msg-v1
           pa2 = ls_msg-v2
           pa3 = ls_msg-v3
           pa4 = ls_msg-v4
           no_duplicate = if_no_duplicate ).
    ENDLOOP.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~add_symsg.
    sy_set(  if_no_duplicate   ).

  ENDMETHOD.

  METHOD /gib/if_msg_queue~add_text.
    DATA: lf_text TYPE text255.

    FIELD-SYMBOLS: <ls_text> TYPE any.

    LOOP AT it_text ASSIGNING <ls_text>.
      lf_text = <ls_text>.
      /gib/if_msg_queue~add_msg( if_mid = '/GIB/DCV'
                                 if_num          = '998'
                                 if_pa1          = lf_text(50)
                                 if_pa2          = lf_text+50(50)
                                 if_pa3          = lf_text+100(50)
                                 if_pa4          = lf_text+150(50)
                                 if_typ          = if_msgtyp
                                 if_no_duplicate = ' '        ).
    ENDLOOP.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~delete_msg.
    DELETE m_msg_tab
      WHERE id = if_msgid
        AND no = if_msgno.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~get_bapireturn.
    et_msg = get_bapiret2_tab( ).

  ENDMETHOD.

  METHOD /gib/if_msg_queue~get_count.
    ef_count = get_count( ).

  ENDMETHOD.

  METHOD /gib/if_msg_queue~get_max_severity.
    IF /gib/if_msg_queue~has_error( ) = abap_true.
      ef_msg_type = 'E'.
      EXIT.
    ENDIF.
    IF /gib/if_msg_queue~has_type( if_type = /gib/if_msg_queue=>co_warning ) = abap_true.
      ef_msg_type = /gib/if_msg_queue=>co_warning.
      EXIT.
    ENDIF.
    IF /gib/if_msg_queue~has_type( if_type = /gib/if_msg_queue=>co_info ) = abap_true
    OR /gib/if_msg_queue~has_type( if_type = /gib/if_msg_queue=>co_status ) = abap_true.
      ef_msg_type = /gib/if_msg_queue=>co_status.
      EXIT.
    ENDIF.
    ef_msg_type = space.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~get_msg_tab.
    DATA: ls_msg TYPE /gib/dcv_msg_s.

    FIELD-SYMBOLS: <ls_msg> TYPE /gib/dcv_msg_s.

    MOVE-CORRESPONDING m_msg_tab TO et_msg.
    LOOP AT et_msg ASSIGNING <ls_msg>.
      SELECT SINGLE text FROM t100 INTO <ls_msg>-message
        WHERE sprsl = if_spras
          AND arbgb = <ls_msg>-id
          AND msgnr = <ls_msg>-no.
      IF sy-subrc = 0.
        REPLACE ALL OCCURRENCES OF '&1' IN <ls_msg>-message WITH <ls_msg>-v1.
        IF sy-subrc = 4.
          REPLACE '&' IN <ls_msg>-message WITH <ls_msg>-v1.
        ENDIF.
        REPLACE ALL OCCURRENCES OF '&2' IN <ls_msg>-message WITH <ls_msg>-v2.
        IF sy-subrc = 4.
          REPLACE '&' IN <ls_msg>-message WITH <ls_msg>-v2.
        ENDIF.
        REPLACE ALL OCCURRENCES OF '&3' IN <ls_msg>-message WITH <ls_msg>-v3.
        IF sy-subrc = 4.
          REPLACE '&' IN <ls_msg>-message WITH <ls_msg>-v3.
        ENDIF.
        REPLACE ALL OCCURRENCES OF '&4' IN <ls_msg>-message WITH <ls_msg>-v4.
        IF sy-subrc = 4.
          REPLACE '&' IN <ls_msg>-message WITH <ls_msg>-v4.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~has_error.
    LOOP AT m_msg_tab TRANSPORTING NO FIELDS
      WHERE type = /gib/if_msg_queue=>co_error
         OR type = /gib/if_msg_queue=>co_abend
         OR type = 'X'.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ef_error = abap_true.
    ELSE.
      ef_error = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~has_type.
    DATA(lt_type_ra) = it_type_ra.
    IF if_type IS SUPPLIED.
      APPEND INITIAL LINE TO lt_type_ra ASSIGNING FIELD-SYMBOL(<ls_type_ra>).
      <ls_type_ra>-sign = 'I'.
      <ls_type_ra>-option = 'EQ'.
      <ls_type_ra>-low = if_type.
    ENDIF.
    LOOP AT m_msg_tab TRANSPORTING NO FIELDS
      WHERE type IN lt_type_ra .
    ENDLOOP.
    IF sy-subrc = 0.
      ef_has_type = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD /gib/if_msg_queue~reset.
    reset( ).

  ENDMETHOD.

  METHOD /gib/if_msg_queue~show.
    CLEAR ef_cancel.
    DATA(lt_msg) = m_msg_tab.    "save for later
    DELETE m_msg_tab
      WHERE type NOT IN it_type_filter.

    set_use_grid( if_use_grid ).
    show( title = if_title
          if_batch_list_type = if_batch_list_type ).
    ef_cancel = m_exit_code.
    m_msg_tab = lt_msg.   "restore

    IF /gib/if_msg_queue~has_error( ) = abap_true
      AND sy-batch = abap_true
      AND if_end_job_on_error = abap_true.
      MESSAGE e316(/gib/dcv)..
    ENDIF.

  ENDMETHOD.

  METHOD add_bapiret2_tab.
    rr_me = me.
    DATA: ls_bapiret2 TYPE bapiret2.

    LOOP AT it_bapiret2 INTO ls_bapiret2.
      set( mid          = ls_bapiret2-id
           num          = ls_bapiret2-number
           pa1          = ls_bapiret2-message_v1
           pa2          = ls_bapiret2-message_v2
           pa3          = ls_bapiret2-message_v3
           pa4          = ls_bapiret2-message_v4
           typ          = ls_bapiret2-type
           no_duplicate = ' ' ).
    ENDLOOP.
  ENDMETHOD.

  METHOD append.
    rr_me = me.
    DATA lt_msg_tab TYPE msg_tab_type.

    CHECK ir_msg IS BOUND.
    lt_msg_tab = ir_msg->get_msg_tab( ).
    APPEND LINES OF lt_msg_tab TO m_msg_tab.

  ENDMETHOD.

  METHOD constructor .
*--- init values ---
    m_mid   = mid.
    m_title = title.
*--- initialize MessageQueue ---
    CALL METHOD reset.
  ENDMETHOD.

  METHOD evaluate_object.
    IF ir_object_reference IS BOUND.
      TRY .
           rr_msg_object ?= ir_object_reference.
        CATCH cx_sy_move_cast_error.
          CREATE OBJECT rr_msg_object.
      ENDTRY.
    ELSE.
      CREATE OBJECT rr_msg_object.
    ENDIF.
  ENDMETHOD.

  METHOD get_bapiret2_tab.
    FIELD-SYMBOLS: <ls_bapiret2> TYPE bapiret2,
                   <ls_msg>      TYPE iwerrormsg.

    LOOP AT m_msg_tab ASSIGNING <ls_msg>.
      APPEND INITIAL LINE TO rt_bapiret2 ASSIGNING <ls_bapiret2>.
      CALL FUNCTION '/GIB/DCP_FILL_BAPIRET2'
        EXPORTING
          if_msgty  = <ls_msg>-type
          if_msgno  = <ls_msg>-no
          if_msgid  = <ls_msg>-id
          if_par1   = <ls_msg>-v1
          if_par2   = <ls_msg>-v2
          if_par3   = <ls_msg>-v3
          if_par4   = <ls_msg>-v4
        IMPORTING
          ew_return = <ls_bapiret2>.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_count .

    DATA: lw_msg_tab LIKE LINE OF m_msg_tab.

    DESCRIBE TABLE m_msg_tab LINES count.
    CLEAR m_err_occ.
    LOOP AT m_msg_tab INTO lw_msg_tab WHERE type EQ 'E'
                                      OR    type EQ 'A'
                                      OR    type EQ 'X'.
      m_err_occ = 'X'.
      EXIT.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_msg_tab.
    rt_msg_tab = m_msg_tab.
  ENDMETHOD.

  METHOD has_type.
    READ TABLE m_msg_tab WITH KEY type = if_type TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      rf_answer = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD p_show_list .

    DATA : l_title  TYPE sy-title,
           l_msg_wa TYPE msg_type.

    IF title IS INITIAL.
      l_title = m_title.
    ELSE.
      l_title = title.
    ENDIF.

*    --- USE MESSAGES_... functions ---

*    --- first: reset ---
    CALL FUNCTION 'MESSAGES_INITIALIZE'.

    LOOP AT m_msg_tab INTO l_msg_wa.
*    --- second: fill message queue
      CALL FUNCTION 'MESSAGE_STORE'
        EXPORTING
          arbgb                  = l_msg_wa-id
          msgty                  = l_msg_wa-type
          msgv1                  = l_msg_wa-v1
          msgv2                  = l_msg_wa-v2
          msgv3                  = l_msg_wa-v3
          msgv4                  = l_msg_wa-v4
          txtnr                  = l_msg_wa-no
          zeile                  = sy-tabix
        EXCEPTIONS
          message_type_not_valid = 1
          not_active             = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 1.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          WHEN OTHERS.

        ENDCASE.
      ENDIF.

      IF sy-subrc <> 0. ENDIF. "--- hide errors ----
    ENDLOOP.
*   --- third: show dialog box ---
    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        object             = l_title
        batch_list_type    = if_batch_list_type
        i_use_grid         = mf_use_grid
      IMPORTING
        e_exit_command     = l_exit_command
      EXCEPTIONS
        inconsistent_range = 1
        no_messages        = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

*    --- last: reset ---
    CALL FUNCTION 'MESSAGES_INITIALIZE'.

  ENDMETHOD.

  METHOD remove_msg_type.
    rr_me = me.
    DELETE m_msg_tab WHERE type = if_type.
  ENDMETHOD.

  METHOD reset .
    rr_me = me.
*    --- initialize message Queue ---
    CLEAR m_msg_tab.

  ENDMETHOD.

  METHOD set .
    DATA msg_tab_wa TYPE msg_type.
    rr_me = me.
    IF NOT num IS INITIAL.
      msg_tab_wa-no = num.
*      --- if message ID is initial set default ---
      IF mid IS INITIAL.
        msg_tab_wa-id  = m_mid.
      ELSE.
        msg_tab_wa-id = mid.
      ENDIF.
*      --- message type has to be set ! ( else DUMP ) ---
      IF typ IS INITIAL.
        msg_tab_wa-type  = 'E'.
      ELSE.
        msg_tab_wa-type = typ.
      ENDIF.
*      --- message parameter ---
      msg_tab_wa-v1 = pa1.
      msg_tab_wa-v2 = pa2.
      msg_tab_wa-v3 = pa3.
      msg_tab_wa-v4 = pa4.

      IF NOT no_duplicate IS INITIAL.
        READ TABLE m_msg_tab WITH KEY no = num
                          id = mid
                          type = typ
                          v1 = pa1
                          v2 = pa2
                          v3 = pa3
                          v4 = pa4
                          TRANSPORTING NO FIELDS.
        CHECK sy-subrc <> 0 .
      ENDIF.

      APPEND msg_tab_wa TO m_msg_tab.

    ENDIF.

  ENDMETHOD.

  METHOD set_all_as_type.
    rr_me = me.
    FIELD-SYMBOLS: <ls_msg> TYPE iwerrormsg.
    CHECK if_type IS NOT INITIAL.

    LOOP AT m_msg_tab ASSIGNING <ls_msg>.
      <ls_msg>-type = if_type.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_exc.
    rr_me = me.
    DATA: lr_t100  TYPE REF TO if_t100_message.
    DATA: lf_string TYPE string,
          lf_char200(200) TYPE c,
          lf_pa1    TYPE symsgv,
          lf_pa2    TYPE symsgv,
          lf_pa3    TYPE symsgv,
          lf_pa4    TYPE symsgv.

    CHECK ir_exc IS BOUND.

    TRY .
        lr_t100 ?= ir_exc.
        set_t100( ir_t100 = lr_t100
                  typ     = typ
                  no_duplicate = no_duplicate ).
      CATCH cx_sy_move_cast_error.

        lf_string = ir_exc->get_text( ).
        lf_char200 = lf_string.
        lf_pa1 = lf_char200(50).
        lf_pa2 = lf_char200+50(50).
        lf_pa3 = lf_char200+100(50).
        lf_pa4 = lf_char200+150(50).

        set( num  = '998'"&1&2&3&4
             typ = typ
             pa1 = lf_pa1
             pa2 = lf_pa2
             pa3 = lf_pa3
             pa4 = lf_pa4
             no_duplicate = no_duplicate ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_exit_code.
    rr_me = me.
    m_exit_code = if_exit_code.
  ENDMETHOD.

  METHOD set_t100.
    rr_me = me.
    DATA: lf_pa1 TYPE symsgv,
          lf_pa2 TYPE symsgv,
          lf_pa3 TYPE symsgv,
          lf_pa4 TYPE symsgv.

    DATA: lt_params TYPE sotr_params,
          ls_param  TYPE sotr_param.

    cl_message_helper=>get_text_params( EXPORTING obj = ir_t100
                                        IMPORTING params = lt_params ).

    READ TABLE lt_params INTO ls_param WITH KEY param = ir_t100->t100key-attr1.
    IF sy-subrc = 0.
      lf_pa1 = ls_param-value.
    ENDIF.
    READ TABLE lt_params INTO ls_param WITH KEY param = ir_t100->t100key-attr2.
    IF sy-subrc = 0.
      lf_pa2 = ls_param-value.
    ENDIF.
    READ TABLE lt_params INTO ls_param WITH KEY param = ir_t100->t100key-attr3.
    IF sy-subrc = 0.
      lf_pa3 = ls_param-value.
    ENDIF.
    READ TABLE lt_params INTO ls_param WITH KEY param = ir_t100->t100key-attr4.
    IF sy-subrc = 0.
      lf_pa4 = ls_param-value.
    ENDIF.

    set( mid          = ir_t100->t100key-msgid
         num          = ir_t100->t100key-msgno
         pa1          = lf_pa1
         pa2          = lf_pa2
         pa3          = lf_pa3
         pa4          = lf_pa4
         typ          = typ
         no_duplicate = no_duplicate ).

  ENDMETHOD.

  METHOD set_use_grid.
    rr_me = me.
    mf_use_grid = if_value.
  ENDMETHOD.

  METHOD show .

    DATA : msg_tab_wa TYPE msg_type.

    DATA: lt_exit_command TYPE bal_s_excm.

    CLEAR m_exit_code.

    CALL METHOD get_count
      RECEIVING
        count = count.

    CASE count.
      WHEN 0.  " --- do nothing ---

      WHEN OTHERS. " --- show dialog box ---
        lt_exit_command = p_show_list( title = title
                                       if_batch_list_type = if_batch_list_type ).
        m_exit_code = lt_exit_command-cancel.
    ENDCASE.

  ENDMETHOD.

METHOD sy_set .
  rr_me = me.
  set( mid = sy-msgid
       num = sy-msgno
       pa1 = sy-msgv1
       pa2 = sy-msgv2
       pa3 = sy-msgv3
       pa4 = sy-msgv4
       typ = sy-msgty
       no_duplicate = no_duplicate ).
ENDMETHOD.
ENDCLASS.
