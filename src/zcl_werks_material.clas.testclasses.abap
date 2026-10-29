*"* use this source file for your ABAP unit test classes

*# We make a dummy werks_material object, we dont need the real contents for the test
CLASS ltc_werks_material DEFINITION FOR TESTING
  INHERITING FROM zcl_werks_material.
  PUBLIC SECTION.
    METHODS determine_mapping_wrap
      CHANGING cs_mrp TYPE zif_werks_material~ts_mrp_data.
    METHODS constructor.
    CLASS-METHODS get_cut
      RETURNING VALUE(rr_cut) TYPE REF TO ltc_werks_material.
ENDCLASS.

CLASS ltc_werks_material IMPLEMENTATION.
  METHOD determine_mapping_wrap.
    determine_mapping( CHANGING cs_mrp = cs_mrp ).
  ENDMETHOD.
  METHOD constructor.
*# Not important if there is a real plant named ####, nothing happened
    DATA(lr_werks) = NEW zcl_werks( if_werks = '####' ).
    DATA(lr_material) = zcl_material=>get_instance( if_matnr = '####' ).
    super->constructor( ir_werks = lr_werks
                        ir_matnr = lr_material ).
  ENDMETHOD.
  METHOD get_cut.
    rr_cut = NEW #( ).
  ENDMETHOD.
ENDCLASS.
