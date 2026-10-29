class ZCL_OPERATION_PRODO definition
  public
  inheriting from ZCL_OPERATION
  create public .

public section.

  methods ZIF_OPERATION~IS_MAIN_OPERATION
    redefinition .
  methods ZIF_OPERATION~UPDATE_PRODUCTION_AID
    redefinition .
protected section.

  methods FILTER_PRODUCTION_AIDS
    redefinition .
private section.
ENDCLASS.

CLASS ZCL_OPERATION_PRODO IMPLEMENTATION.

  METHOD zif_operation~is_main_operation.
*#If the SUMNR is not initial it means that the operation is a subboperation
    IF ms_afvgd-sumnr IS INITIAL .
      rf_answer = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD filter_production_aids.
    DELETE ct_fhm
      WHERE aplzl <> ms_afvgd-aplzl.

  ENDMETHOD.

  METHOD zif_operation~update_production_aid.
    DATA: ls_affhd TYPE affhd.

    MOVE-CORRESPONDING is_fhm TO ls_affhd.

    CALL FUNCTION 'CF_BT_CO_FHM_UPDATE'
      EXPORTING
        affhd_imp = ls_affhd
        tabix_imp = is_fhm-indbt.

  ENDMETHOD.
ENDCLASS.
