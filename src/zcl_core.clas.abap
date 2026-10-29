class ZCL_CORE definition
  public
  create public .

public section.

  types:
    BEGIN OF ts_operation,
            plnid TYPE z_plnid,
            vornr TYPE /gib/dcp_vornr_first,
            kbed TYPE  kbedd,
            afvg TYPE  afvgd,
            afko TYPE  caufvd,
            plaf TYPE  plaf,
            sauf TYPE  sauf,
            crhd TYPE  rcrhd_a,
            kako TYPE  rkako_a,
            pers TYPE  person,
            mara TYPE  cymara,
             END OF ts_operation .
  types:
    tt_operations TYPE TABLE OF ts_operation .

  data MT_OPERATIONS type TT_OPERATIONS .

  methods CONSTRUCTOR
    importing
      !IR_PROFILE type ref to ZCL_CORE_PROFILE
      !IR_FILTER type ref to ZCL_CORE_FILTER .
  methods RESCHEDULE
    importing
      !IT_ORDERS type /GIB/DCP_MODEL_T .
  methods RESCHEDULE_ORDER
    importing
      !IS_ORDER type /GIB/DCP_MODEL_S .
  methods READ_PROTOCOL .
  methods GET_BAPIRET2
    returning
      value(RT_BAPIRET2) type BAPIRET2_T .
  class-methods BUILD_CAPA_REQUIREMENT_GROUPS .
  methods POST .
  class-methods CLASS_CONSTRUCTOR .
  methods FREE .
protected section.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ts_relation,
            plnid TYPE z_plnid,
            vornr TYPE /gib/dcp_vornr_first,
            sart  TYPE /gib/dcp_sart,
            kbed  TYPE cykbed_tab,
           END OF ts_relation .

  CONSTANTS con_structure_crhd TYPE cy_strukt VALUE 'CRHD'. "#EC NOTEXT
  CONSTANTS con_structure_kako TYPE cy_strukt VALUE 'KAKO'. "#EC NOTEXT
  CONSTANTS con_structure_einzkap TYPE cy_strukt VALUE 'EINZKAP'. "#EC NOTEXT
  CONSTANTS con_structure_afko TYPE cy_strukt VALUE 'AFKO'. "#EC NOTEXT
  CONSTANTS con_structure_auko TYPE cy_strukt VALUE 'AUKO'. "#EC NOTEXT
  CONSTANTS con_structure_aufk TYPE cy_strukt VALUE 'AUFK'. "#EC NOTEXT
  CONSTANTS con_structure_afpo TYPE cy_strukt VALUE 'AFPO'. "#EC NOTEXT
  CONSTANTS con_structure_afih TYPE cy_strukt VALUE 'AFIH'. "#EC NOTEXT
  CONSTANTS con_structure_iloa TYPE cy_strukt VALUE 'ILOA'. "#EC NOTEXT
  CONSTANTS con_structure_afvg TYPE cy_strukt VALUE 'AFVG'. "#EC NOTEXT
  CONSTANTS con_structure_plaf TYPE cy_strukt VALUE 'PLAF'. "#EC NOTEXT
  CONSTANTS con_structure_kbed TYPE cy_strukt VALUE 'KBED'. "#EC NOTEXT
  CONSTANTS con_structure_sauf TYPE cy_strukt VALUE 'SAUF'. "#EC NOTEXT
  CONSTANTS con_structure_mara TYPE cy_strukt VALUE 'MARA'. "#EC NOTEXT
  CONSTANTS con_structure_pers TYPE cy_strukt VALUE 'PERS'. "#EC NOTEXT
  CONSTANTS con_structure_per_tab TYPE cy_strukt VALUE 'PER_TAB'. "#EC NOTEXT
  CONSTANTS con_structure_per_bed TYPE cy_strukt VALUE 'PER_BED'. "#EC NOTEXT
  CONSTANTS con_structure_per_eina TYPE cy_strukt VALUE 'PER_EINA'. "#EC NOTEXT
  CONSTANTS con_structure_bed_gru TYPE cy_strukt VALUE 'BED_GRU'. "#EC NOTEXT
  CONSTANTS con_structure_gru_eina TYPE cy_strukt VALUE 'GRU_EINA'. "#EC NOTEXT
  CONSTANTS con_field_kbed_status TYPE cy_feld VALUE 'KBEDSELAV'. "#EC NOTEXT
  CONSTANTS con_status_eingeplant TYPE cy_grwert VALUE 'SAP001'. "#EC NOTEXT
  CONSTANTS con_status_ausgeplant TYPE cy_grwert VALUE 'SAP002'. "#EC NOTEXT
  CONSTANTS con_structure_cyfi TYPE dfies-tabname VALUE 'CYFI2'. "#EC NOTEXT
  DATA mr_profile TYPE REF TO zcl_core_profile .
  DATA mr_filter TYPE REF TO zcl_core_filter .
  DATA:
    mt_objects    TYPE TABLE OF cygru_ein .
  DATA:
    mt_relations  TYPE TABLE OF ts_relation .
  DATA mt_bapiret2 TYPE bapiret2_t .
  CLASS-DATA:
    gt_capa_requirement_groups   TYPE TABLE OF cybed_gru .

  METHODS build_relations .
ENDCLASS.

CLASS ZCL_CORE IMPLEMENTATION.

  METHOD BUILD_CAPA_REQUIREMENT_GROUPS.

    FIELD-SYMBOLS: <ls_cr_group> TYPE cybed_gru.
* <ls_cr_group> Tabelle entsprechend Aufbauen.
* Es werden zwei Gruppen definiert:
* Gruppe 01: Alle eingeplanten KBEDS zu KAKO
* Gruppe 02: Alle ausgeplanten KBEDS zu KAKO
* Beide Gruppen enthalten sowohl PLAFS als auch FAUF
    FREE: gt_capa_requirement_groups.
* die erste Gruppe: ist eingeplante KBED zu KAKO
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kako.
    <ls_cr_group>-wert     = '*'.
    <ls_cr_group>-chart  = '01'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kako.
    <ls_cr_group>-feld     = 'KAPIE'.
    <ls_cr_group>-wert     = '00000000'.
    <ls_cr_group>-chart  = '01'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = con_field_kbed_status.
    <ls_cr_group>-wert     = con_status_eingeplant.
    <ls_cr_group>-chart  = '01'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'CANUMF'.
    <ls_cr_group>-wert     = '0000'.
    <ls_cr_group>-chart  = '01'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = ' '.
    <ls_cr_group>-chart    = '01'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = '0'.
    <ls_cr_group>-chart  = '01'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '01'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = '1'.
    <ls_cr_group>-chart  = '01'.

* die zweite Gruppe: ist ausgeplante KBED zu KAKO
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kako.
    <ls_cr_group>-wert     = '*'.
    CLEAR  <ls_cr_group>-feld.
    <ls_cr_group>-chart  = '02'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kako.
    <ls_cr_group>-feld     = 'KAPIE'.
    <ls_cr_group>-wert     = '00000000'.
    <ls_cr_group>-chart  = '02'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = con_field_kbed_status.
    <ls_cr_group>-wert     = con_status_ausgeplant.
    <ls_cr_group>-chart  = '02'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'CANUMF'.
    <ls_cr_group>-wert     = '0000'.
    <ls_cr_group>-chart  = '02'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = ' '.
    <ls_cr_group>-chart  = '02'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = '0'.
    <ls_cr_group>-chart  = '02'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '02'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = '1'.
    <ls_cr_group>-chart  = '02'.

* die dritte Gruppe: Planaufträge mit keinem Status
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '03'.
    <ls_cr_group>-struktur = con_structure_plaf.
    <ls_cr_group>-wert     = '*'.
    CLEAR  <ls_cr_group>-feld.
    <ls_cr_group>-chart  = '03'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '03'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'OBSTA'.
    CLEAR <ls_cr_group>-wert.
    <ls_cr_group>-chart  = '03'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '03'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = ' '.
    <ls_cr_group>-chart  = '03'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '03'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = '0'.
    <ls_cr_group>-chart  = '03'.
    APPEND INITIAL LINE TO gt_capa_requirement_groups ASSIGNING <ls_cr_group>.
    <ls_cr_group>-gruppe = '03'.
    <ls_cr_group>-struktur = con_structure_kbed.
    <ls_cr_group>-feld     = 'KBPHASE_KZ'.
    <ls_cr_group>-wert     = '1'.
    <ls_cr_group>-chart  = '03'.

  ENDMETHOD.

  METHOD build_relations.

    DATA: lt_rel_tab TYPE TABLE OF cysel_obj,
          ls_kbed    TYPE kbedd,
          ls_afvg    TYPE afvgd,
          ls_afko    TYPE caufvd,
          ls_plaf    TYPE plaf.
    FIELD-SYMBOLS: <ls_relation> TYPE ts_relation,
                   <ls_object>   TYPE cygru_ein,
                   <ls_rel_tab>  TYPE cysel_obj.

    CLEAR mt_relations.
    LOOP AT mt_objects ASSIGNING <ls_object>.
      CALL FUNCTION 'CY01_INDEX_INFORMATION_READ'
        EXPORTING
          in_index    = <ls_object>-indexakt
          in_struktur = <ls_object>-struktur
          kbed_info   = 'X'
          afvg_info   = 'X'
          afko_info   = 'X'
          plaf_info   = 'X'
        IMPORTING
          out_kbed    = ls_kbed
          out_afvg    = ls_afvg
          out_afko    = ls_afko
          out_plaf    = ls_plaf.
      APPEND INITIAL LINE TO mt_relations ASSIGNING <ls_relation>.

      IF ls_plaf IS NOT INITIAL.
        <ls_relation>-plnid = ls_plaf-plnum.
        <ls_relation>-vornr = ls_kbed-vornr.
        <ls_relation>-sart  = zif_core_constants=>co_linetype_plano.
      ELSEIF ls_afko IS NOT INITIAL.
        <ls_relation>-plnid = ls_afko-aufnr.
        <ls_relation>-vornr = ls_afvg-vornr.
        <ls_relation>-sart  = zcl_order_prodo=>get_sart_from_autyp( if_autyp = ls_afko-autyp ).
      ENDIF.

*# build the relations
      MOVE-CORRESPONDING ls_kbed TO <ls_relation>-kbed.
      CALL FUNCTION 'CY01_GET_RELATIONS'
        EXPORTING
          index_nach      = 0
          index_von       = <ls_object>-indexakt
          struktur_nach   = con_structure_kbed
          struktur_von    = <ls_object>-struktur
        TABLES
          rel_tab         = lt_rel_tab
        EXCEPTIONS
          OTHERS          = 0.

      READ TABLE lt_rel_tab INDEX 1 ASSIGNING <ls_rel_tab>.
      IF sy-subrc EQ 0.
        <ls_relation>-kbed-index = <ls_rel_tab>-indexakt.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD CLASS_CONSTRUCTOR.
    build_capa_requirement_groups( ).
  ENDMETHOD.

  METHOD CONSTRUCTOR.
    DATA: lt_filter  TYPE /gib/dcp_cm25_filter_t,
          lf_profile TYPE cy_gesprof,
          lt_bed_gru TYPE TABLE OF cybed_gru.

    FIELD-SYMBOLS: <ls_gru_ein> TYPE cygru_ein,
                   <ls_operation> TYPE ts_operation.

*# remember attributes
    mr_profile = ir_profile.
    mr_filter  = ir_filter.

    lt_filter  = mr_filter->get( ).
    lf_profile = mr_profile->get( ).
    lt_bed_gru = gt_capa_requirement_groups.

    CALL FUNCTION 'CY01_EXTERNAL_INTERFACE'
      EXPORTING
        function             = 'INIT' "con_fcode_initialize
        profile_id           = lf_profile
        reset_all_tables_imp = 'X'
      TABLES
        fil_tab              = lt_filter
        bed_gru              = lt_bed_gru
        gru_ein              = mt_objects
      EXCEPTIONS
        OTHERS               = 0.

    build_relations( ).

    LOOP AT mt_objects ASSIGNING <ls_gru_ein>." WHERE  gruppe = '03'." unplanned orders
      APPEND INITIAL LINE TO mt_operations ASSIGNING <ls_operation>.
      CALL FUNCTION 'CY01_INDEX_INFORMATION_READ'
        EXPORTING
          in_index    = <ls_gru_ein>-indexakt    " imput structure index
          in_struktur = <ls_gru_ein>-struktur " imput structure
          kbed_info   = 'X'
          afvg_info   = 'X'
          afko_info   = 'X'
          plaf_info   = 'X'
          sauf_info   = 'X'
          crhd_info   = 'X'
          kako_info   = 'X'
          pers_info   = 'X'
          mara_info   = 'X'
        IMPORTING
          out_kbed    = <ls_operation>-kbed
          out_afvg    = <ls_operation>-afvg
          out_afko    = <ls_operation>-afko
          out_plaf    = <ls_operation>-plaf
          out_sauf    = <ls_operation>-sauf
          out_crhd    = <ls_operation>-crhd
          out_kako    = <ls_operation>-kako
          out_pers    = <ls_operation>-pers
          out_mara    = <ls_operation>-mara.
      <ls_operation>-vornr = <ls_operation>-kbed-vornr.
      IF <ls_operation>-plaf IS NOT INITIAL.
        <ls_operation>-plnid = <ls_operation>-plaf-plnum.
      ELSE.
        <ls_operation>-plnid = <ls_operation>-afko-aufnr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD FREE.

    CALL FUNCTION 'CY01_EXTERNAL_INTERFACE'
      EXPORTING
        function             = 'STOP'
        reset_all_tables_imp = 'X'
      EXCEPTIONS
        OTHERS               = 0.

  ENDMETHOD.

  method GET_BAPIRET2.

* RETURNING value(rt_bapiret2) TYPE BAPIRET2_T
    rt_bapiret2 = mt_bapiret2.

  endmethod.

  METHOD POST.

    CALL FUNCTION 'CY01_EXTERNAL_INTERFACE'
      EXPORTING
        function             = 'XX99' "con_fcode_post_all
        reset_all_tables_imp = ' '
      EXCEPTIONS
        OTHERS               = 0.

  ENDMETHOD.

  METHOD READ_PROTOCOL.

    DATA: msg_count TYPE p.
    DATA: lf_msgno TYPE symsgno,
          lf_msgid TYPE symsgid.
    DATA: lt_bapiret2 TYPE bapiret2_t.

    FIELD-SYMBOLS: <ls_message>  TYPE cmfmsg,
                   <ls_bapiret2> TYPE bapiret2.

    DATA: msg_prot TYPE TABLE OF cmfmsg,
          msg_prot_2 TYPE TABLE OF cmfmsg.
    FIELD-SYMBOLS: <msg_prot> TYPE cmfmsg,
                   <msg_prot_2> TYPE cmfmsg.
    DATA index_key TYPE indx-srtfd.
    DATA msg_count_loc TYPE p.

* Terminierungsprotokoll:
* Information über die Anzahl der gesp. Nachrichten lesen
    CALL FUNCTION 'CM_F_INFO'
      EXPORTING
        aplid           = 'PPCP'
      IMPORTING
        msg_counter_pro = msg_count_loc
      EXCEPTIONS
        wrong_object_id = 01.

    IF msg_count_loc > 0.
      msg_count = msg_count + msg_count_loc.
      CLEAR msg_prot_2.
      REFRESH msg_prot_2.

      CALL FUNCTION 'CM_F_MESSAGES_GET'
        EXPORTING
          aplid      = 'PPCP'
        TABLES
          e_msgprot  = msg_prot_2
        EXCEPTIONS
          OTHERS               = 0.

      LOOP AT msg_prot_2 ASSIGNING <msg_prot_2>.
        IF  <msg_prot_2>-arbgb EQ 'CY' AND <msg_prot_2>-msgnr EQ '730'
                               AND <msg_prot_2>-msgty EQ 'I'.
          <msg_prot_2>-object = <msg_prot_2>-msgv1.
        ENDIF.
        APPEND INITIAL LINE TO msg_prot ASSIGNING <msg_prot>.
        MOVE-CORRESPONDING <msg_prot_2> TO <msg_prot>.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'CM_F_DELETE_LAST_MESSAGES'
      EXPORTING
        aplid      = 'PPCP'
      EXCEPTIONS
        OTHERS               = 0.

    LOOP AT msg_prot ASSIGNING <ls_message>.
      APPEND INITIAL LINE TO lt_bapiret2 ASSIGNING <ls_bapiret2>.
      lf_msgno = <ls_message>-msgnr.
      lf_msgid = <ls_message>-arbgb.
      CALL FUNCTION '/GIB/DCP_FILL_BAPIRET2'
        EXPORTING
          if_msgty  = <ls_message>-msgty
          if_msgno  = lf_msgno
          if_msgid  = lf_msgid
          if_par1   = <ls_message>-msgv1
          if_par2   = <ls_message>-msgv2
          if_par3   = <ls_message>-msgv3
          if_par4   = <ls_message>-msgv4
        IMPORTING
          ew_return = <ls_bapiret2>.
    ENDLOOP.

    APPEND LINES OF lt_bapiret2 TO mt_bapiret2.

  ENDMETHOD.

  METHOD RESCHEDULE.

  ENDMETHOD.

  METHOD RESCHEDULE_ORDER.

    DATA: ls_relation TYPE ts_relation,
          lt_kbed_tab TYPE TABLE OF cykbed_tab.
    FIELD-SYMBOLS: <ls_bapiret2> TYPE bapiret2.

    READ TABLE mt_relations INTO ls_relation
                            WITH KEY plnid = is_order-plnid
                                     vornr = is_order-vornr
                                     sart  = is_order-sart.
    IF sy-subrc EQ 0.
      ls_relation-kbed-epanf     = is_order-pldat.
      ls_relation-kbed-epanz     = is_order-plzeit.
      ls_relation-kbed-funktion1 = 'AV09'."con_fcode_opr_reschedule."reschedule

      IF is_order-pldat LE sy-datum AND is_order-plzeit LE sy-uzeit.
        APPEND INITIAL LINE TO mt_bapiret2 ASSIGNING <ls_bapiret2>.
        CALL FUNCTION '/GIB/DCP_FILL_BAPIRET2'
          EXPORTING
            if_msgty  = 'E'
            if_msgno  = '126' "Keine Terminierung! Auftrag &1 --> Datum in der Vergangenheit.
            if_msgid  = 'Z_CORE'
            if_par1   = is_order-plnid
          IMPORTING
            ew_return = <ls_bapiret2>.
        RETURN.
      ENDIF.
      APPEND ls_relation-kbed TO lt_kbed_tab.
    ELSE.
      APPEND INITIAL LINE TO mt_bapiret2 ASSIGNING <ls_bapiret2>.
      " operation can not be rescheduled
      CALL FUNCTION '/GIB/DCP_FILL_BAPIRET2'
        EXPORTING
          if_msgty  = 'E'
          if_msgno  = '129' "Keine Terminierung! Auftrag &1 --> Interner Fehler
          if_msgid  = 'Z_CORE'
          if_par1   = is_order-plnid
        IMPORTING
          ew_return = <ls_bapiret2>.
      RETURN.
    ENDIF.

*# call rescheduling...
    CALL FUNCTION 'CY01_EXTERNAL_INTERFACE'
      TABLES
        kbed_tab = lt_kbed_tab
      EXCEPTIONS
        OTHERS               = 0.

    read_protocol( ).

  ENDMETHOD.
ENDCLASS.
