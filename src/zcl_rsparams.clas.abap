class ZCL_RSPARAMS definition
  public
  create protected .

public section.

  data MT_PARAMETERS type TY_RSPARAMS read-only .
  constants:
    begin of co_kind,
                  parameter type rsscr_kind value 'P',
                  select_option type rsscr_kind value 'S',
                 end of co_kind .
  constants:
    begin of co_sign,
                  including type tvarv_sign value 'I',
                  excluding type  tvarv_sign value 'E',
                 end of co_sign .
  constants:
    begin of co_option,
                  between       type tvarv_opti value 'BT',
                  equal         type tvarv_opti value 'EQ',
                  not_equal     type tvarv_opti value 'NE',
                  greater_equal type tvarv_opti value 'GE',
                  greater_then  type tvarv_opti value 'GT',
                  lower_equal   type tvarv_opti value 'LE',
                  lower_then    type tvarv_opti value 'LT',
                  contains      TYPE tvarv_opti VALUE 'CP',
                 end of co_option .
  data MT_PARAMETER_DETAILS type KKBLO_SELDIS read-only .

  methods CONSTRUCTOR
    importing
      !IT_PARAMETES type TY_RSPARAMS
      !IT_PARAMETER_DETAILS type KKBLO_SELDIS optional .
  class-methods CLASS_CONSTRUCTOR .
  class-methods TABLE_FACTORY
    importing
      !IT_PARAMETES type TY_RSPARAMS
    returning
      value(RR_PARAMETERS) type ref to ZCL_RSPARAMS .
  class-methods REPORT_FACTORY
    importing
      !IF_REPID type SYREPID default SY-CPROG
    returning
      value(RR_PARAMETERS) type ref to ZCL_RSPARAMS .
  methods GET_PARAMETER
    importing
      !IF_PARAMETER_NAME type RSSCR_NAME
    exporting
      !EF_PARAMETER type ANY .
  methods GET_SELECT_OPTION
    importing
      !IF_SELECT_OPTION_NAME type RSSCR_NAME
    exporting
      !ET_RANGE type RSELOPTION .
  methods READ_UI5_SELECTIONS .
  methods SET_PARAMETER_VALUE
    importing
      !IF_PARAMETER_NAME type RSSCR_NAME
      !IF_PARAMETER type ANY .
  class-methods RESOLVE_UI5_SLEECTIONS .
  methods SET_RANGE_VALUE
    importing
      !IF_NAME type RSSCR_NAME
      !IT_VALUE type RSELOPTION .
  methods GET_RANGE
    importing
      !IF_NAME type RSSCR_NAME
    returning
      value(RT_VALUE) type RSELOPTION .
  methods GET_PARAM
    importing
      !IF_NAME type RSSCR_NAME
    returning
      value(RF_VALUE) type RSPARAMS-LOW .
protected section.
private section.
ENDCLASS.

CLASS ZCL_RSPARAMS IMPLEMENTATION.

  method class_constructor.
*    FUBA
*    RS_REPORTSELECTIONS_INFO
*    K_KKB_SELECTIONS_READ
  endmethod.

  METHOD constructor.
    mt_parameters = it_parametes.
    mt_parameter_details = it_parameter_details.

    read_ui5_selections( ).

  ENDMETHOD.

  METHOD get_parameter.
    CLEAR ef_parameter.
    READ TABLE mt_parameters INTO DATA(ls_parameter)
      WITH KEY selname = if_parameter_name
               kind    = co_kind-parameter.
    IF sy-subrc = 0.
      ef_parameter = ls_parameter-low.
    ENDIF.
  ENDMETHOD.

  METHOD get_select_option.
    CLEAR et_range.
    LOOP AT mt_parameters INTO DATA(ls_parameter) WHERE selname = if_select_option_name
                                                    AND kind   = co_kind-select_option
                                                    AND sign   IS NOT INITIAL
                                                    AND option IS NOT INITIAL.
      APPEND INITIAL LINE TO et_range ASSIGNING FIELD-SYMBOL(<ls_range>).
      MOVE-CORRESPONDING ls_parameter TO <ls_range>.
    ENDLOOP.

  ENDMETHOD.

  METHOD read_ui5_selections.
    CONSTANTS: co_complex_selections(18) TYPE c VALUE 'COMPLEX_SELECTIONS',
               co_fieldname_transaction  TYPE char12 VALUE '~TRANSACTION'.

    CONSTANTS: BEGIN OF co_attribute,
                 operation TYPE char12 VALUE 'SOPERATOR',
                 value1    TYPE char12 VALUE 'OVALUE1',
                 value2    TYPE char12 VALUE 'OVALUE2',
               END OF co_attribute.
*##changes 10.02.2021
    DATA: lt_new_parameters TYPE ty_rsparams,
          is_in_flp         TYPE abap_bool,
          context           TYPE TABLE OF savwctxt,
          data_tab          TYPE TABLE OF char100,
          fieldindex        TYPE i,
          lt_string         TYPE TABLE OF string,
          lf_string         TYPE string,
          lf_parameter(18)  TYPE c.
    FIELD-SYMBOLS: <lt_attributes> TYPE ANY TABLE.

    CALL FUNCTION 'WEBGUI_IS_IN_FLP' "#EC CI_SUBRC
      IMPORTING
        is_in_flp         = is_in_flp
      EXCEPTIONS
        its_not_available = 1
        OTHERS            = 2.
    CHECK ( sy-subrc = 0 AND is_in_flp = abap_true ).

    DATA: lf_url(8192).
    CALL FUNCTION 'ITS_GET_URL' "#EC CI_SUBRC
      IMPORTING
        url               = lf_url
      EXCEPTIONS
        its_not_available = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'ITS_IMPORT_CONTEXT' "#EC CI_SUBRC
      TABLES
        context           = context
      EXCEPTIONS
        its_not_available = 1
        OTHERS            = 2.
    CHECK sy-subrc = 0.

    READ TABLE context WITH KEY fieldname = co_fieldname_transaction INTO DATA(ls_context).
    CHECK sy-subrc = 0.

    fieldindex = ls_context-fieldindex.
    CALL FUNCTION 'ALEWEB_GET_CONTEXT' "#EC CI_SUBRC
      EXPORTING
        fieldname             = ls_context-fieldname
        fieldindex            = fieldindex
      TABLES
        data_tab              = data_tab
      EXCEPTIONS
        invalid_index         = 1
        system_failure        = 2
        its_not_available     = 3
        communication_failure = 4
        OTHERS                = 5.
    IF sy-subrc = 0.
      "build a string from the data_tab table
      LOOP AT data_tab INTO DATA(ls_structure).
        lf_string = lf_string && ls_structure.
      ENDLOOP.

      REPLACE ' ' WITH ';' INTO lf_string.

      "split the components
      SPLIT lf_string AT ';' INTO TABLE lt_string.
      LOOP AT lt_string INTO lf_string.
        "find the COMPLEX_SELECTIONS component and leave it in LF_STRING
        lf_parameter = lf_string.
        IF lf_parameter = co_complex_selections.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    REPLACE co_complex_selections IN lf_string WITH space.
    REPLACE '=' IN lf_string WITH space.
    CONDENSE lf_string.

    DATA(lr_data) = /ui2/cl_json=>generate( json = lf_string ).
    ASSIGN lr_data->* TO FIELD-SYMBOL(<ls_data_structure>).

    LOOP AT mt_parameters INTO DATA(ls_parameter) ."WHERE kind = co_kind-select_option.
      ASSIGN COMPONENT ls_parameter-selname OF STRUCTURE <ls_data_structure> TO FIELD-SYMBOL(<lr_attributes>).
      CHECK sy-subrc = 0.
      ASSIGN <lr_attributes>->* TO <lt_attributes>.

      LOOP AT <lt_attributes> ASSIGNING FIELD-SYMBOL(<lr_attribute>).
        ASSIGN <lr_attribute>->* TO FIELD-SYMBOL(<ls_attribute>).

        DATA(ls_new_parameter) = ls_parameter.
        CLEAR ls_new_parameter.
        ls_new_parameter-selname = ls_parameter-selname.
        ls_new_parameter-kind    = co_kind-select_option.

        ls_new_parameter-sign = co_sign-including.
        ASSIGN COMPONENT co_attribute-value1 OF STRUCTURE <ls_attribute> TO FIELD-SYMBOL(<lr_field>).
        IF sy-subrc = 0.
          ASSIGN <lr_field>->* TO FIELD-SYMBOL(<lf_field>).
          IF sy-subrc = 0.
            ls_new_parameter-low = <lf_field>.
          ENDIF.
        ENDIF.

*##changes 10.02.2021
        ASSIGN COMPONENT co_attribute-value2 OF STRUCTURE <ls_attribute> TO <lr_field>.
        IF sy-subrc = 0.
          ASSIGN <lr_field>->* TO <lf_field>.
          IF sy-subrc = 0.
            ls_new_parameter-high = <lf_field>.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT co_attribute-operation OF STRUCTURE <ls_attribute> TO <lr_field>.
        IF sy-subrc = 0.
          ASSIGN <lr_field>->* TO <lf_field>.
          IF sy-subrc = 0.
            CASE <lf_field>.
              WHEN 'Contains'.
                ls_new_parameter-option = co_option-contains.
                ls_new_parameter-low    = '*' && ls_new_parameter-low && '*'.
              WHEN 'StartsWith'.
                ls_new_parameter-option = co_option-contains.
                ls_new_parameter-low    = ls_new_parameter-low && '*'.
              WHEN 'EndsWith'.
                ls_new_parameter-option = co_option-contains.
                ls_new_parameter-low    = '*' && ls_new_parameter-low.
              WHEN 'Empty'.
                ls_new_parameter-low = 'Empty'."in order not to remove if empty
                CONTINUE."do not add the parameter to new parameters
*#changes 10.02.2021
              WHEN 'NE'.
                ls_new_parameter-sign   = co_sign-excluding.
                ls_new_parameter-option = co_option-equal.
                IF ls_new_parameter-low IS INITIAL.
                  CONTINUE."we do not need a excluding nothing
                ENDIF.
*##changes 10.02.2021
              WHEN OTHERS.
                ls_new_parameter-option = <lf_field>.
            ENDCASE.
          ENDIF.
        ENDIF.

        APPEND ls_new_parameter TO lt_new_parameters.

      ENDLOOP."@<LT_ATTRIBUTES>

*#remove empty select options
      IF ls_parameter-sign   IS INITIAL AND
         ls_parameter-option IS INITIAL AND
         ls_parameter-low    IS INITIAL AND
         ls_parameter-high   IS INITIAL.
        DELETE mt_parameters.
      ENDIF.
    ENDLOOP."@MT_PARAMETERS

    IF lt_new_parameters IS NOT INITIAL.
      APPEND LINES OF lt_new_parameters TO  mt_parameters.
      SORT mt_parameters BY kind selname.
    ENDIF.

  ENDMETHOD.

  METHOD report_factory.
    DATA: lt_isetab_full TYPE kkblo_seldis,
          lt_selopt      TYPE ty_rsparams,
          lt_selopt_ext  TYPE ty_rsparams.

    CALL FUNCTION 'K_KKB_SELECTIONS_READ'
      EXPORTING
        v_program      = if_repid
      TABLES
        et_isetab_full = lt_isetab_full
        et_selopt      = lt_selopt
        et_selopt_ext  = lt_selopt_ext
      .

    APPEND LINES OF lt_selopt_ext TO lt_selopt.
    rr_parameters = NEW zcl_rsparams( it_parametes = lt_selopt it_parameter_details = lt_isetab_full ).
  ENDMETHOD.

  METHOD resolve_ui5_sleections.
    DATA: lt_values TYPE TABLE OF rsselread.

    CALL FUNCTION 'RS_SELECTIONSCREEN_UPDATE'
      EXPORTING
        program       = sy-cprog
        dynnr         = sy-dynnr
      TABLES
        updatevalues  = lt_values
      EXCEPTIONS
        no_high_field = 1
        OTHERS        = 2.

  ENDMETHOD.

  METHOD set_parameter_value.
    READ TABLE mt_parameters REFERENCE INTO DATA(lr_parameter) WITH KEY selname = if_parameter_name
                                                                        kind    = co_kind-parameter.
    IF sy-subrc = 0.
      lr_parameter->low = if_parameter.
    ELSE.
      APPEND INITIAL LINE TO mt_parameters REFERENCE INTO lr_parameter.
      lr_parameter->kind    = co_kind-parameter.
      lr_parameter->selname = if_parameter_name.
      lr_parameter->low     = if_parameter.
    ENDIF.
  ENDMETHOD.

  method table_factory.
    rr_parameters = new zcl_rsparams( it_parametes ).
  endmethod.

  METHOD get_param.
    get_parameter( EXPORTING if_parameter_name = if_name
                   IMPORTING ef_parameter      = rf_value ).
  ENDMETHOD.

  METHOD get_range.
    get_select_option( EXPORTING if_select_option_name = if_name
                       IMPORTING et_range               = rt_value ).
  ENDMETHOD.

  method SET_RANGE_VALUE.
  delete mt_parameters WHERE selname = if_name
                         AND kind    = co_kind-select_option.
  APPEND LINES OF it_value TO mt_parameters.
  endmethod.
ENDCLASS.
