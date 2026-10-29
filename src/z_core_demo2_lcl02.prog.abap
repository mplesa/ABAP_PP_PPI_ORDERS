*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_tree_item DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_item DEFINITION.
  PUBLIC SECTION.
    DATA: mr_object            TYPE REF TO object READ-ONLY,
          mr_dragdrop         TYPE REF TO cl_dragdrop READ-ONLY,
          mf_name             TYPE lvc_value READ-ONLY,
          mf_node_key         TYPE lvc_nkey READ-ONLY,
          mf_related_node_key TYPE lvc_nkey READ-ONLY,
          mf_relationship     TYPE int4 READ-ONLY,
          mt_item_settings    TYPE lvc_t_layi READ-ONLY,
          ms_node_settings    TYPE lvc_s_layn READ-ONLY,
          mf_chosen           TYPE flag READ-ONLY,
          mf_expanded         TYPE flag READ-ONLY.

    METHODS: set_object    IMPORTING ir_object TYPE REF TO object,
             set_is_folder IMPORTING if_folder   TYPE flag,
             set_name      IMPORTING if_name     TYPE lvc_value,
             set_is_checkbox IMPORTING if_checkbox TYPE flag,
             set_chosen    IMPORTING if_chosen TYPE flag,
             set_icon      IMPORTING if_icon     TYPE tv_image,
             set_2nd_icon  IMPORTING if_icon     TYPE tv_image,
             set_expander  IMPORTING if_expander TYPE flag,
             set_expanded  IMPORTING if_expanded TYPE flag,
             set_dragdrop  IMPORTING ir_dragdrop TYPE REF TO cl_dragdrop,
             constructor   IMPORTING if_node_key         TYPE lvc_nkey
                                     if_related_node_key TYPE lvc_nkey
                                     if_relationship     TYPE int4.
  PRIVATE SECTION.

ENDCLASS.                    "lcl_tree_item DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_tree_item IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_item IMPLEMENTATION.

  METHOD constructor.
    FIELD-SYMBOLS: <ls_item_settings> TYPE lvc_s_layi.
    APPEND INITIAL LINE TO mt_item_settings ASSIGNING <ls_item_settings>.
    <ls_item_settings>-fieldname = cl_gui_alv_tree=>c_hierarchy_column_name.

    mf_node_key = if_node_key.
    mf_related_node_key = if_related_node_key.
    mf_relationship = if_relationship.
  ENDMETHOD.                    "constructor
  METHOD set_is_checkbox.
    FIELD-SYMBOLS: <ls_item_settings> TYPE lvc_s_layi.

    READ TABLE mt_item_settings ASSIGNING <ls_item_settings>
        WITH KEY fieldname = cl_alv_tree_base=>c_hierarchy_column_name.
    IF sy-subrc <> 0.
      APPEND INITIAL LINE TO mt_item_settings ASSIGNING <ls_item_settings>.
    ENDIF.

    CASE if_checkbox.
      WHEN abap_true.
        <ls_item_settings>-class     = cl_gui_column_tree=>item_class_checkbox.
        <ls_item_settings>-editable  = abap_true.
        <ls_item_settings>-fieldname = cl_alv_tree_base=>c_hierarchy_column_name.
        <ls_item_settings>-chosen    = 'X'.
      WHEN OTHERS.
        <ls_item_settings>-class     = space.
        <ls_item_settings>-editable  = abap_false.
        <ls_item_settings>-fieldname = cl_alv_tree_base=>c_hierarchy_column_name.
    ENDCASE.
  ENDMETHOD.                    "set_is_checkbox
  METHOD set_chosen.
    FIELD-SYMBOLS: <ls_item_settings> TYPE lvc_s_layi.

    READ TABLE mt_item_settings ASSIGNING <ls_item_settings>
        WITH KEY fieldname = cl_alv_tree_base=>c_hierarchy_column_name.
    IF sy-subrc <> 0.
      APPEND INITIAL LINE TO mt_item_settings ASSIGNING <ls_item_settings>.
    ENDIF.
    <ls_item_settings>-chosen = if_chosen.
    mf_chosen = if_chosen.
  ENDMETHOD.                    "set_chosen
  METHOD set_expanded.
    mf_expanded = if_expanded.
  ENDMETHOD.                    "set_expanded
  METHOD set_expander.
    ms_node_settings-expander = if_expander.
  ENDMETHOD.                    "set_expander
  METHOD set_dragdrop.
    DATA: lf_handle TYPE i.
    mr_dragdrop = ir_dragdrop.
    mr_dragdrop->get_handle( IMPORTING handle = lf_handle ).
    ms_node_settings-dragdropid = lf_handle.
  ENDMETHOD.                    "set_dragdrop
  METHOD set_object.
    mr_object = ir_object.
  ENDMETHOD.                    "set_object
  METHOD set_is_folder.
    ms_node_settings-isfolder = if_folder.
  ENDMETHOD.                    "set_is_folder
  METHOD set_name.
    mf_name = if_name.
  ENDMETHOD.                    "set_name
  METHOD set_icon.
    ms_node_settings-exp_image = if_icon.
    ms_node_settings-n_image   = if_icon.
  ENDMETHOD.                    "set_icon
  METHOD set_2nd_icon.
    FIELD-SYMBOLS: <ls_item_settings> TYPE lvc_s_layi.

    READ TABLE mt_item_settings ASSIGNING <ls_item_settings>
        WITH KEY fieldname = cl_alv_tree_base=>c_hierarchy_column_name.
    IF sy-subrc <> 0.
      APPEND INITIAL LINE TO mt_item_settings ASSIGNING <ls_item_settings>.
    ENDIF.
    <ls_item_settings>-t_image = if_icon.
  ENDMETHOD.
ENDCLASS.                    "lcl_tree_item IMPLEMENTATION
