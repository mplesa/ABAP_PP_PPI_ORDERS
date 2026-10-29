*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_flow DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_flow DEFINITION.
  PUBLIC SECTION.
    INTERFACES /gib/if_dc_screen_flow.
    METHODS constructor IMPORTING ir_order TYPE REF TO zif_order.
  PRIVATE SECTION.
    DATA: mr_order     TYPE REF TO zif_order,
          mr_container TYPE REF TO cl_gui_container,
          mr_nav       TYPE REF TO lcl_c_nav.
    METHODS: on_finished FOR EVENT finished OF if_os_transaction,
      on_save_requested FOR EVENT save_requested OF if_os_transaction,
      on_save_prepared FOR EVENT save_prepared OF if_os_transaction.
ENDCLASS.                    "lcl_flow DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_flow IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_flow IMPLEMENTATION.
  METHOD on_finished.

  ENDMETHOD.
  METHOD on_save_requested.

  ENDMETHOD.
  METHOD on_save_prepared.

  ENDMETHOD.
  METHOD constructor.
    DATA: lr_plano TYPE REF TO zcl_order_plano,
          lf_plnid TYPE string.

    mr_order = ir_order.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = mr_order->mf_plnid
      IMPORTING
        output = lf_plnid.
    TRY .
        lr_plano ?= mr_order.
        /gib/if_dc_screen_flow~mf_screen_title = |{ sy-title }: { 'Planauftrag'(003) } { lf_plnid }|.
      CATCH cx_sy_move_cast_error.
        /gib/if_dc_screen_flow~mf_screen_title = |{ sy-title }: { 'Auftrag'(002) } { lf_plnid }|.
    ENDTRY.
  ENDMETHOD.                    "constructor

  METHOD /gib/if_dc_screen_flow~at_screen_initialisation.
    DATA: lr_container TYPE REF TO cl_gui_docking_container.
    mr_container = ir_container.

*# create container for navigation tree
    CREATE OBJECT lr_container
      EXPORTING
        side                        = cl_gui_docking_container=>dock_at_left
        ratio                       = 20
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    CREATE OBJECT mr_nav TYPE lcl_c_nav
      EXPORTING
        ir_order            = mr_order
        ir_container        = lr_container
        ir_detail_container = mr_container.

    mr_nav->lif_c~display( ).

  ENDMETHOD.
  METHOD /gib/if_dc_screen_flow~at_pbo.
  ENDMETHOD.
  METHOD /gib/if_dc_screen_flow~at_pai.
    CASE if_ucomm.
      WHEN /gib/if_dc_screen_flow~co_ucomm_save.
        zcl_order_buffer=>post( ).

      WHEN /gib/if_dc_screen_flow~co_ucomm_back
        OR /gib/if_dc_screen_flow~co_ucomm_cancel
        OR /gib/if_dc_screen_flow~co_ucomm_exit.
        LEAVE TO SCREEN 0.
    ENDCASE.
  ENDMETHOD.
  METHOD /gib/if_dc_screen_flow~at_screen_destroy.
    mr_nav->lif_c~destroy( ).
    CLEAR mr_nav.
    FREE mr_nav.
  ENDMETHOD.
  METHOD /gib/if_dc_screen_flow~at_batch.
  ENDMETHOD.
ENDCLASS.                    "lcl_flow IMPLEMENTATION
