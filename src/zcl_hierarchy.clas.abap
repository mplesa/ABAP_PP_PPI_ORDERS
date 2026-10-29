class ZCL_HIERARCHY definition
  public
  create public .

public section.

  interfaces ZIF_DESCRIPTION .
  interfaces ZIF_OBJID .

  aliases MF_HIERID
    for ZIF_OBJID~MF_OBJID .
  aliases GET_CHILDREN
    for ZIF_OBJID~GET_CHILDREN .
  aliases GET_DESCRIPTION
    for ZIF_DESCRIPTION~GET .
  aliases GET_ICON
    for ZIF_DESCRIPTION~GET_ICON .
  aliases GET_LONG_DESCRIPTION
    for ZIF_DESCRIPTION~GET_LONG .
  aliases GET_SUBTREE
    for ZIF_OBJID~GET_SUBTREE .

  data MS_CRHH type CRHH read-only .
  data:
    mt_hierarchy_structure TYPE TABLE OF rcr06_a read-only .
  data MF_DESCRIPTION type CR_KTEXT read-only .
  data MR_WERKS type ref to ZCL_WERKS read-only .
  class ZCL_ARBID definition load .
  data MT_WORKCENTERS type ZCL_ARBID=>TT_ARBID read-only .
  data:
    mt_nodes TYPE TABLE OF REF TO zcl_arbid_node .

  class-methods GET_INSTANCE_WITH_KEY
    importing
      !IF_HNAME type CR_HNAME
      !IF_WERKS type WERKS_D
    returning
      value(RR_HIERARCHY) type ref to ZCL_HIERARCHY .
  class-methods GET_INSTANCE
    importing
      !IF_HIERID type CR_OBJID
    returning
      value(RR_HIERARCHY) type ref to ZCL_HIERARCHY .
  methods CONSTRUCTOR
    importing
      !IF_HIERID type CR_OBJID .
protected section.
private section.

  types:
    tt_objid TYPE TABLE OF cr_objid .

  class-data:
    gt_hierarchy TYPE TABLE OF REF TO zcl_hierarchy .
  interface ZIF_OBJID load .
  data MT_CHILDREN type ZIF_OBJID=>TT_OBJID .

  methods ADD_NODE_CHILDREN
    importing
      !IR_NODE type ref to ZCL_ARBID_NODE .
  methods BUILD_WORKCENTERS .
  methods BUILD_CHILDREN .
  methods GET_NODE_CHILDREN_IDS
    importing
      !IF_OBJID type CR_OBJID
    exporting
      !ET_OBJID type TT_OBJID .
  methods BUILD_NODES .
ENDCLASS.

CLASS ZCL_HIERARCHY IMPLEMENTATION.

  METHOD ZIF_DESCRIPTION~get.

  ENDMETHOD.

  METHOD ZIF_DESCRIPTION~get_icon.

  ENDMETHOD.

 METHOD ZIF_DESCRIPTION~get_long.

  ENDMETHOD.

  METHOD ZIF_OBJID~get_children.

  ENDMETHOD.

  METHOD ZIF_OBJID~get_subtree.

  ENDMETHOD.

  METHOD add_node_children.
    DATA: lt_children TYPE TABLE OF REF TO zif_objid,
          lr_arbid    TYPE REF TO zcl_arbid,
          lr_node     TYPE REF TO zcl_arbid_node,
          lt_objid    TYPE tt_objid,
          lf_objid    TYPE cr_objid.

*#we asume the node itself is also a workcenter
    lr_arbid = zcl_arbid=>get_instance( ir_node->mf_arbid ).
    APPEND lr_arbid TO lt_children.

    get_node_children_ids( EXPORTING if_objid = ir_node->mf_arbid
                           IMPORTING et_objid = lt_objid ).
    LOOP AT lt_objid INTO lf_objid.
      READ TABLE mt_nodes INTO lr_node WITH KEY table_line->mf_arbid = lf_objid.
      IF sy-subrc = 0.
        APPEND lr_node TO lt_children.
      ELSE.
        lr_arbid = zcl_arbid=>get_instance( lf_objid ).
        APPEND lr_arbid TO lt_children.
      ENDIF.
    ENDLOOP.

    ir_node->set_children( lt_children ).
  ENDMETHOD.

  METHOD build_children.
    DATA: ls_hierarchy TYPE rcr06_a,
          lr_node      TYPE REF TO zcl_arbid_node,
          lr_arbid     TYPE REF TO zcl_arbid.

*#only the top level nodes are required
    LOOP AT mt_hierarchy_structure INTO ls_hierarchy WHERE objid_up IS INITIAL.
      READ TABLE mt_nodes INTO lr_node WITH KEY table_line->mf_arbid = ls_hierarchy-objid.
      IF sy-subrc = 0.
        APPEND lr_node TO mt_children.
      ELSE.
        lr_arbid = zcl_arbid=>get_instance( ls_hierarchy-objid ).
        APPEND lr_arbid TO mt_children.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_nodes.
    DATA: lt_hierarchy TYPE TABLE OF rcr06_a,
          ls_hierarchy TYPE rcr06_a,
          lr_node      TYPE REF TO zcl_arbid_node.

*#first find and istantiate all the workcenter nodes
    lt_hierarchy = mt_hierarchy_structure.
    SORT lt_hierarchy BY objid_up DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_hierarchy COMPARING objid_up.
    DELETE lt_hierarchy WHERE objid_up IS INITIAL.

    LOOP AT lt_hierarchy INTO ls_hierarchy.
      CREATE OBJECT lr_node
        EXPORTING
          if_arbid = ls_hierarchy-objid_up.
      APPEND lr_node TO mt_nodes.
    ENDLOOP.

    LOOP AT mt_nodes INTO lr_node.
      add_node_children( lr_node ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_workcenters.
    DATA: ls_hierarchy TYPE rcr06_a,
          lr_arbid     TYPE REF TO zcl_arbid.

    LOOP AT mt_hierarchy_structure INTO ls_hierarchy WHERE objty = zif_objid=>co_type_workcenter.
      lr_arbid = zcl_arbid=>get_instance( ls_hierarchy-objid ).
      COLLECT lr_arbid INTO mt_workcenters.
    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.
    mf_hierid = if_hierid.

    SELECT SINGLE * FROM crhh INTO CORRESPONDING FIELDS OF ms_crhh
              WHERE objty = zif_objid=>co_type_hierarchy
                AND objid = if_hierid.

    zif_objid~mf_objty = ms_crhh-objty.

    .
    mr_werks = zcl_werks=>get_instance( ms_crhh-werks ).

    CALL FUNCTION 'CR_HIERARCHY_DISOLVE' "#EC CI_SUBRC
      EXPORTING
        objid_hy                = ms_crhh-objid
      TABLES
        t_struc                 = mt_hierarchy_structure
      EXCEPTIONS
        hierarchy_not_found     = 1
        object_not_in_hierarchy = 2
        OTHERS                  = 3.

    CALL FUNCTION 'CR_HIERARCHY_READ' "#EC CI_SUBRC
      EXPORTING
        objid               = ms_crhh-objid
      IMPORTING
        ktext               = mf_description
      EXCEPTIONS
        hierarchy_not_found = 1
        OTHERS              = 2.

    build_workcenters( ).
    build_nodes( ).
    build_children( ).
  ENDMETHOD.

  METHOD get_instance.
    READ TABLE gt_hierarchy WITH KEY table_line->mf_hierid = if_hierid
          INTO rr_hierarchy.
    IF sy-subrc NE 0.
      CREATE OBJECT rr_hierarchy
        EXPORTING
          if_hierid = if_hierid.
      APPEND rr_hierarchy TO gt_hierarchy.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_with_key.
    DATA: lf_hierid TYPE cr_objid.

    READ TABLE gt_hierarchy INTO rr_hierarchy WITH KEY table_line->ms_crhh-name = if_hname
                                                       table_line->ms_crhh-werks = if_werks.
    IF sy-subrc <> 0.
      SELECT SINGLE objid FROM crhh INTO lf_hierid "#EC CI_NOORDER
             WHERE objty = zif_objid=>co_type_hierarchy "#EC CI_SUBRC
               AND name  = if_hname
               AND werks = if_werks.

      CREATE OBJECT rr_hierarchy EXPORTING if_hierid = lf_hierid.
      APPEND rr_hierarchy TO gt_hierarchy.
    ENDIF.

  ENDMETHOD.

  METHOD get_node_children_ids.
    DATA: ls_hierarchy TYPE rcr06_a.

    LOOP AT mt_hierarchy_structure INTO ls_hierarchy WHERE objid_up = if_objid.
      APPEND ls_hierarchy-objid TO et_objid.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
