class ZCL_ARBID_NODE definition
  public
  inheriting from ZCL_ARBID
  create public .

public section.

  interface ZIF_OBJID load .
  methods SET_CHILDREN
    importing
      !IT_CHILDREN type ZIF_OBJID=>TT_OBJID .

  methods ZIF_DESCRIPTION~GET_ICON
    redefinition .
  methods ZIF_OBJID~GET_SUBTREE
    redefinition .
protected section.
private section.
ENDCLASS.

CLASS ZCL_ARBID_NODE IMPLEMENTATION.

  METHOD zif_description~get_icon.
    rf_icon = icon_insert_relation.
  ENDMETHOD.

  METHOD zif_objid~get_subtree.
    DATA: lr_objid TYPE REF TO zif_objid.

    LOOP AT mt_children INTO lr_objid.
      lr_objid->get_subtree( IMPORTING et_subtree = et_subtree ).
    ENDLOOP.

  ENDMETHOD.

  method SET_CHILDREN.
    APPEND LINES OF it_children TO mt_children.
  endmethod.
ENDCLASS.
