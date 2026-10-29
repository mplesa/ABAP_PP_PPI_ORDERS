*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
CLASS lcl_toolbar DEFINITION.
  PUBLIC SECTION.
    DATA: mt_functions TYPE TABLE OF REF TO /gib/cl_dcp_function.
    METHODS: constructor IMPORTING ir_container TYPE REF TO cl_gui_container OPTIONAL
                                   ir_toolbar TYPE REF TO cl_gui_toolbar OPTIONAL,
             add_function RETURNING VALUE(rr_function) TYPE REF TO /gib/cl_dcp_function,
             add_separator RETURNING VALUE(rr_separator) TYPE REF TO /gib/cl_dcp_function,
             refresh,
             free.
    EVENTS: function_selected EXPORTING VALUE(ef_fcode) TYPE ui_func,
            dropdown_clicked EXPORTING VALUE(ef_fcode) TYPE  ui_func
                                       VALUE(ef_posx)  TYPE  i
                                       VALUE(ef_posy)  TYPE  i.
  PRIVATE SECTION.
    DATA: mf_counter TYPE numc10,
          mr_toolbar TYPE REF TO cl_gui_toolbar,
          mr_container TYPE REF TO cl_gui_container.
    METHODS: set_handlers IMPORTING if_activation TYPE flag,
             on_function_selected FOR EVENT function_selected OF cl_gui_toolbar
                                  IMPORTING fcode,
             on_dropdown_clicked FOR EVENT dropdown_clicked OF cl_gui_toolbar
                                 IMPORTING fcode posx posy.
ENDCLASS.                    "lcl_toolbar DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_toolbar IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_toolbar IMPLEMENTATION.
  METHOD on_function_selected.
    RAISE EVENT function_selected EXPORTING ef_fcode = fcode.
  ENDMETHOD.                    "on_function_selected
  METHOD on_dropdown_clicked.
    RAISE EVENT dropdown_clicked EXPORTING ef_fcode = fcode
                                           ef_posx  = posx
                                           ef_posy  = posy.
  ENDMETHOD.                    "on_dropdown_clicked
  METHOD set_handlers.
    SET HANDLER on_function_selected FOR mr_toolbar ACTIVATION if_activation.
    SET HANDLER on_dropdown_clicked FOR mr_toolbar ACTIVATION if_activation.
  ENDMETHOD.                    "set_handlers
  METHOD free.
    mr_toolbar->free( ).
  ENDMETHOD.                    "free
  METHOD refresh.
    DATA: lr_function TYPE REF TO /gib/cl_dcp_function.

    mr_toolbar->delete_all_buttons( ).
    SORT mt_functions BY table_line->mf_position.

    LOOP AT mt_functions INTO lr_function.
      mr_toolbar->add_button(     "#EC CI_SUBRC
        EXPORTING
          fcode            = lr_function->mf_fcode
          icon             = lr_function->mf_icon
          is_disabled      = lr_function->mf_disabled
          butn_type        = lr_function->mf_butn_type
          text             = lr_function->mf_text
          quickinfo        = lr_function->mf_quickinfo
        EXCEPTIONS
          cntl_error       = 1
          cntb_btype_error = 2
          cntb_error_fcode = 3
          OTHERS           = 4 ).
    ENDLOOP.
  ENDMETHOD.                    "refresh
  METHOD constructor.
    DATA: lr_function TYPE REF TO /gib/cl_dcp_function,
          ls_icon TYPE icon.
    FIELD-SYMBOLS: <ls_button> TYPE stb_button.
    mr_container = ir_container.
    IF ir_toolbar IS BOUND.
      mr_toolbar = ir_toolbar.
      LOOP AT mr_toolbar->m_table_button ASSIGNING <ls_button>.
        CASE <ls_button>-butn_type.
          WHEN 3.
            lr_function = add_separator( ).
            lr_function->set_position( sy-tabix ).
          WHEN OTHERS.
            lr_function = add_function( ).
            lr_function->set_position( sy-tabix ).
            lr_function->set_fcode( <ls_button>-function ).
            SELECT SINGLE id FROM icon INTO ls_icon WHERE id = <ls_button>-icon.  "#EC CI_SUBRC
            lr_function->set_icon( ls_icon-id ).
            lr_function->set_text( <ls_button>-text ).
            lr_function->set_quickinfo( <ls_button>-quickinfo ).
        ENDCASE.

      ENDLOOP.
    ELSE.
      CREATE OBJECT mr_toolbar
        EXPORTING
          parent = mr_container.
    ENDIF.

    set_handlers( abap_true ).

  ENDMETHOD.                    "constructor
  METHOD add_function.
    ADD 1 TO mf_counter.
    CREATE OBJECT rr_function.
    APPEND rr_function TO mt_functions.
  ENDMETHOD.                    "add_function
  METHOD add_separator.
    rr_separator = add_function( ).
    rr_separator->set_butn_type( /gib/cl_dcp_function=>co_separator ).
  ENDMETHOD.                    "add_separator
ENDCLASS.                    "lcl_toolbar IMPLEMENTATION
