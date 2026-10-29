*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
INTERFACE lif_table.
  CONSTANTS: co_mara TYPE string VALUE 'MARA',
             co_marc TYPE string VALUE 'MARC',
             co_aob  TYPE string VALUE 'PRE_DEC',
             co_kbko TYPE string VALUE 'KBKO',
             co_mkal TYPE string VALUE 'MKAL',
             co_makt TYPE string VALUE 'MAKT',
             co_afpo TYPE string VALUE 'AFPO',
             co_plaf TYPE string VALUE 'PLAF',
             co_crhd TYPE string VALUE 'CRHD',
             co_kako TYPE string VALUE 'KAKO',
             co_kbed TYPE string VALUE 'KBEDD',
             co_afvgd TYPE string VALUE 'AFVGD',
             co_jstat TYPE string VALUE 'JSTAT',
             co_caufvd TYPE string VALUE 'CAUFVD',
             co_affl TYPE string VALUE 'AFFLD'.
  DATA: mr_table TYPE REF TO data.
  METHODS: get_name RETURNING VALUE(rf_name) TYPE string,
           get EXPORTING et_table TYPE STANDARD TABLE,
           rebuild.
ENDINTERFACE.
