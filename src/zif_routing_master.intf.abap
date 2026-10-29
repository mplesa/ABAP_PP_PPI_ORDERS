INTERFACE zif_routing_master
  PUBLIC .

  TYPES:
    BEGIN OF ts_plko,
      plnty TYPE plko-plnty,
      plnnr TYPE plko-plnnr,
      plnal TYPE plko-plnal,
      datuv TYPE plko-datuv,
      loekz TYPE plko-loekz,
      losvn TYPE plko-losvn,
      losbs TYPE plko-losbs,
    END OF ts_plko .
  TYPES:
    BEGIN OF ts_plpo,
      plnkn TYPE plpo-plnkn,
      vornr TYPE plpo-vornr,
      zaehl TYPE plpo-zaehl,
      arbid TYPE plpo-arbid,
      werks TYPE plpo-werks,
      steus TYPE plpo-steus,
    END OF ts_plpo .
  TYPES:
    BEGIN OF ts_plas,
      plnfl TYPE plas-plnfl,
      plnkn TYPE plas-plnkn,
      zaehl TYPE plas-zaehl,
    END OF ts_plas .
  TYPES:
    BEGIN OF ts_plfl,
      plnfl TYPE plfl-plnfl,
      zaehl TYPE plfl-zaehl,
      losvn TYPE plfl-losvn,
      losbs TYPE plfl-losbs,
    END OF ts_plfl .
  TYPES:
    BEGIN OF ts_plfh,
      plnkn  TYPE plfh-plnkn,
      plnnr  TYPE plfh-plnnr,
      psnfh  TYPE psnfh,
      pzlfh  TYPE plfh-pzlfh,
      zaehl  TYPE plfh-zaehl,
      datuv  TYPE plfh-datuv,
      objty  TYPE plfh-objty,
      objid  TYPE plfh-objid,
      objct  TYPE plfh-objct,
      plnal  TYPE plfh-plnal,
      plnfl  TYPE plfh-plnfl,
      steuf  TYPE plfh-steuf,
      txtsp  TYPE plfh-txtsp,
      ktsch  TYPE plfh-ktsch,
      txtz1  TYPE plfh-txtz1,
      mgvgw  TYPE plfh-mgvgw,
      mgeinh TYPE plfh-mgeinh,
    END OF ts_plfh .
  TYPES:
    tt_plpo TYPE TABLE OF ts_plpo WITH EMPTY KEY
                    WITH NON-UNIQUE SORTED KEY vza COMPONENTS vornr zaehl arbid
                    WITH NON-UNIQUE SORTED KEY vka COMPONENTS vornr plnkn arbid
                    WITH NON-UNIQUE SORTED KEY wva COMPONENTS werks vornr arbid .
  TYPES:
    tt_plko TYPE TABLE OF ts_plko .
  TYPES:
    tt_plas TYPE TABLE OF ts_plas .
  TYPES:
    tt_plfl TYPE TABLE OF ts_plfl .
  TYPES:
    tt_plfh TYPE TABLE OF ts_plfh .

  DATA mf_plnty TYPE plnty .
  DATA mf_plnnr TYPE plnnr .
  DATA mf_plnal TYPE plnal .

  METHODS is_workcenter_from_routing
    IMPORTING
      !if_vornr                    TYPE vornr
      !if_zaehl                    TYPE cim_count OPTIONAL
      !if_arbid                    TYPE objektid
      !if_plnkn                    TYPE plnkn OPTIONAL
    RETURNING
      VALUE(rf_is_from_workcenter) TYPE abap_bool .
  METHODS clear_buffer .
  METHODS get_data
    EXPORTING
      !et_plko             TYPE tt_plko
      !et_plfl             TYPE tt_plfl
      !et_plpo             TYPE tt_plpo
      !et_plas             TYPE tt_plas
      !et_plfh             TYPE tt_plfh
    RETURNING
      VALUE(rf_data_found) TYPE abap_bool .
ENDINTERFACE.
