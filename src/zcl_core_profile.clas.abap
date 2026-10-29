class ZCL_CORE_PROFILE definition
  public
  create public .

public section.
  type-pools ABAP .

  methods CONSTRUCTOR
    importing
      !IF_PROFILE_ID type CY_GESPROF optional
      !IF_CAPACITY_HORIZON type I default 100 .
  methods IS_VALID
    returning
      value(RF_ANSWER) type FLAG .
  methods GET
    returning
      value(RF_PROFILE) type CY_GESPROF .
protected section.
private section.

  data MF_CAPACITY_HORIZON type I .
  data MF_PROFILE type CY_GESPROF .
  data MS_OVERALL_PROFILE type CYCRPPRO .
  data MF_IS_VALID type FLAG value 'X' ##NO_TEXT.

  methods CHANGE_OVERALL_PROFILE .
  methods CHANGE_SELECTION_PROFILE .
  methods CHANGE_CONTROL_PROFILE .
  methods CHANGE_TIME_PROFILE .
  methods CHANGE_ANALYSIS_PROFILE .
  methods CHANGE_STRATEGY_PROFILE .
  methods CHECK_IF_IS_VALID .
ENDCLASS.

CLASS ZCL_CORE_PROFILE IMPLEMENTATION.

  METHOD CHANGE_ANALYSIS_PROFILE.

    DATA: ls_analysis_profile TYPE cycrpanpro.
    CALL FUNCTION 'CY01_GET_ANALYSIS_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-anpro_id
      IMPORTING
        crpanpro           = ls_analysis_profile
      EXCEPTIONS
        OTHERS             = 0.
    ls_analysis_profile-hieauf     = space."Hierarchieauflösung durchführen
    ls_analysis_profile-hiever     = space."Kapazitätsbedarfe über Arbeitsplatzhierarchie verdichten
    ls_analysis_profile-anver      = space."Kapazitätsangebote über Arbeitsplatzhierarchie verdichten
    ls_analysis_profile-hname      = space."Name der Hierarchie
    ls_analysis_profile-hwerks     = space."Werk für Hierarchie
    ls_analysis_profile-poolkap    = space."Schalter: summarische Betrachtung der Bedarfe von Poolkapa.
    ls_analysis_profile-minbel     = space."Mindestbelastung, ab der eine Darstellung erfolgt
    ls_analysis_profile-maxbel     = space."Maximalbelastung, bis zu der eine Darstellung erfolgt
    ls_analysis_profile-indcumcap  = space."Verdichtung der Einzelkapazitätsangebote
    ls_analysis_profile-indcumreq  = space."Kennzeichen: Bedarfsverdichtung über Einzelkapazitäten
    ls_analysis_profile-davap      = 'X'  ."Verteilung aus Arbeitsplatz/Vorgang
    ls_analysis_profile-vertl1     = space."Verteilung Kapazitätsbedarfe (Fertigungs- und Planauftrag)
    ls_analysis_profile-vertln     = space."Verteilung KapBedarfe (Instandh.-, Prozeßauftrag, Netzplan)
    ls_analysis_profile-unitsource = 'X'  ."Herkunft der Maßeinheit für Kapazitätsangebot und -bedarf
    ls_analysis_profile-capunit    = 'H'  ."Maßeinheit für die Ausgabe von Kapazitätsangebot und -bedarf ( Just in case.. not correct defined in Workcenter)
    CALL FUNCTION 'CY01_SET_ANALYSIS_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-anpro_id
        crpanpro           = ls_analysis_profile
      EXCEPTIONS
        OTHERS             = 0.

  ENDMETHOD.

  METHOD CHANGE_CONTROL_PROFILE.

    DATA: ls_control_profile TYPE cycrpcopro.

    CALL FUNCTION 'CY01_GET_CONTROL_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-copro_id
      IMPORTING
        crpcopro           = ls_control_profile
      EXCEPTIONS
        no_current_profile = 1
        profile_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.

    ENDIF.
*# change the profile accordingly

    ls_control_profile-present     = '3'  ."Art der Präsentation bzw. der Datenaufbereitung( 3 = No Display)
    ls_control_profile-timetyp     = '2'  ."Art der Datenaufbereitung( 2 = Dispaly data continuously over time )
    ls_control_profile-modifymode  = 'X'  ."Aufruf Kapazitätsabgleich im Änderungsmodus
    ls_control_profile-enqueueall  = space."Sperrverhalten der Kapazitätsplanung im Änderungsmodus ( space = only lock orders on changing )
    ls_control_profile-cua_dis     = space."GUI-Status für den Anzeigemodus
    ls_control_profile-cua_cng     = space."GUI-Status für den Änderungsmodus
    ls_control_profile-sortalways  = space."Sortieren der Zeilen nach jeder Änderung
    ls_control_profile-red_plan    = space."Plantafelmodus mit Zwischenspeichern
    ls_control_profile-set_event   = space."Ereignisse setzen nach Beenden und Sichern der Plantafel
    ls_control_profile-event_param = space."Parameter für ereignisgesteuerten Hintergrund-Job
    ls_control_profile-vrgwnr      = space."Nummer des Vorgabewertes(Setup optimisation field...)

    CALL FUNCTION 'CY01_SET_CONTROL_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-copro_id
        crpcopro           = ls_control_profile
      EXCEPTIONS
        no_current_profile = 1
        profile_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.

  METHOD CHANGE_OVERALL_PROFILE.

    CALL FUNCTION 'CY01_GET_OVERALL_PROFILE'
      EXPORTING
        profile_id         = mf_profile
      IMPORTING
        crppro             = ms_overall_profile
      EXCEPTIONS
        no_current_profile = 1
        profile_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.

      RETURN.
    ENDIF.
    ms_overall_profile-pltprof_id = space."ignore graphical planning table profile
    ms_overall_profile-pepro_id   = space."ignore period profile
    ms_overall_profile-tppro_id   = space."ignore planning table profile
    ms_overall_profile-lipro_id   = space."ignore list profile
    CALL FUNCTION 'CY01_SET_OVERALL_PROFILE'
      EXPORTING
        profile_id           = mf_profile
        crppro               = ms_overall_profile
      EXCEPTIONS
        OTHERS               = 0.

  ENDMETHOD.

  METHOD CHANGE_SELECTION_PROFILE.

    DATA: ls_selection_profile TYPE cycrpsepro.
    CALL FUNCTION 'CY01_GET_SELECTION_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-sepro_id
        reset_buffer_imp   = ' '
      IMPORTING
        crpsepro           = ls_selection_profile
      EXCEPTIONS
        OTHERS             = 0.
    ls_selection_profile-settab	    = space."Tabelle zum Set
    ls_selection_profile-obj_set    = space."Set für die Selektion der Objekte
    ls_selection_profile-fil_set    = space."Set für die Filterung der Objekte
    ls_selection_profile-bedgru	    = space."Bedarfsgruppierung
    ls_selection_profile-termlevel  = '1'  ."Terminierungsebene( 1 = Detailed planning )
    ls_selection_profile-shoporder  = 'X'  ."Kapazitätsbedarfe von Werkaufträgen werden gelesen
    ls_selection_profile-planorder  = 'X'  ."Kapazitätsbedarfe von Planaufträgen werden gelesen
    ls_selection_profile-soporder	  = space."Kapazitätsbedarfe von SOP-Aufträgen werden gelesen
    ls_selection_profile-hierres    = space."Hierarchieauflösung durchführen
    ls_selection_profile-indcapres  = space."Planung auf Einzelkapazitäten
    ls_selection_profile-avaicapver = space."Kapazitätsangebotsversion
    ls_selection_profile-mark_key   = space."Markierschlüssel zur Markierung von Objekten auf Plantafel
    ls_selection_profile-sollbed    = space."Anzeige von Sollkapazitätsbedarfen in Erweiterter Auswertung
    ls_selection_profile-restbed    = space."Anzeige von Restkapazitätsbedarfen in Erweiterter Auswertung
    ls_selection_profile-istbed     = space."Anzeige von Istkapazitätsbedarfen in Erweiterter Auswertung
    CALL FUNCTION 'CY01_SET_SELECTION_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-sepro_id
        crpsepro           = ls_selection_profile
      EXCEPTIONS
        OTHERS             = 0.

  ENDMETHOD.

  METHOD CHANGE_STRATEGY_PROFILE.

    DATA: ls_strategy_profile TYPE cycrpstpro,
          lt_action_profile   TYPE TABLE OF tcy57.
    FIELD-SYMBOLS: <ls_action_profile> TYPE tcy57.
    CALL FUNCTION 'CY01_GET_STRATEGY_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-stpro_id
      IMPORTING
        crpstpro           = ls_strategy_profile
      EXCEPTIONS
        OTHERS             = 0.
    ls_strategy_profile-forward	   = 'X'  ."Planungsrichtung vorwärts
    ls_strategy_profile-capsched   = space."Kapazitätsterminierung
    ls_strategy_profile-automatav	 = space."Eingabe von Termin und ArbPlatz bei Einplanung
    ls_strategy_profile-autoaufkt	 = space."Periodenrasterung bei Einplanung
    ls_strategy_profile-autoaufdt	 = space."Umplanen mit Fertigungsversionen
    ls_strategy_profile-eigenb_dis = '3'  ."Terminbestimmung bei der Einplanung von Eigenbearbeitung ('3' = Dispatch dependent on valid distributaion key for the scheduling capacity)
    ls_strategy_profile-earliest   = space."Einplanung zum frühesten Zeitpunkt
    ls_strategy_profile-cancel_dis = space."Abbruch der Einplanung bei Fehler
    ls_strategy_profile-queuetime	 = '2'  ."Behandlung der Wartezeit bei der Einplanung ('2' = minimum queue time )
    ls_strategy_profile-red_level	 = '0'  ."Reduzierungsstufe der Wartezeit
    ls_strategy_profile-dissort	   = space."Schlüssel für die Bestimmung der Einplanungsreihenfolge
    ls_strategy_profile-atpcap     = space."Kapazitätsbelastung im Planungszeitraum berücksicht
    ls_strategy_profile-bufonly	   = space."Vorgangspuffer berücksichtigen
    ls_strategy_profile-usefloatb	 = space."Vorgriffszeit bei Kapazitätsterminierung berücksichtigen
    ls_strategy_profile-usefloata	 = space."Sicherheitszeit bei Kapazitätsterminierung berücksichtigen
    ls_strategy_profile-insertopr	 = space."Vorgang einfügen
    ls_strategy_profile-closegap   = '0'  ."Lücken schließen bei der Ausplanung von Vorgängen('0' = no closing of gaps)
    ls_strategy_profile-ass_disp   = space."Kennzeichen: Zuordnung und Einplanung gleichzeitig
    ls_strategy_profile-bucket     = '0'  ."Zeitraster für Einplanung  ('0' = no split)
    ls_strategy_profile-bucket1	   = space."Suchbeginn in Planungsrichtung
    ls_strategy_profile-bucketbeg	 = space."Vorgänge beginnen oder enden auf Rasterpunkten
    ls_strategy_profile-bucketfull = space."Vorgang muß vollständig in einem Raster liegen
    ls_strategy_profile-nobreaks   = space."Planen in Nichtarbeitszeiten
    ls_strategy_profile-dirchange	 = space."Planungsrichtung wechseln
    ls_strategy_profile-cancel_ver = space."Abbruch der Einplanung bei Umplanen mit Fertigungsversionen
    ls_strategy_profile-diswsetup	 = space."Einplanen zur bestmöglichen Rüstlage
    ls_strategy_profile-init_cond	 = space."Rüstinitialzustand
    CALL FUNCTION 'CY01_SET_STRATEGY_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-stpro_id
        crpstpro           = ls_strategy_profile
      EXCEPTIONS
        OTHERS             = 0.

*# action profile...
    CALL FUNCTION 'CY01_GET_ACTION_PROFILE'
      EXPORTING
        profile_id         = ms_overall_profile-stpro_id
      TABLES
        tcy57_exp          = lt_action_profile
      EXCEPTIONS
        OTHERS             = 0.

    LOOP AT lt_action_profile ASSIGNING <ls_action_profile>.
      CASE <ls_action_profile>-action_id.
        WHEN '40000004' "Vorgangsterminprüfung
          OR '40000008'."Mittelpunktterminierung
          <ls_action_profile>-act_inact = space.  " these will be active
        WHEN OTHERS.
          <ls_action_profile>-act_inact = 'X'.
      ENDCASE.
    ENDLOOP.
    CALL FUNCTION 'CY01_UPDATE_ACTION_PROFILE'
      EXPORTING
        db_update = space
      TABLES
        tcy57_imp = lt_action_profile.

  ENDMETHOD.

  METHOD CHANGE_TIME_PROFILE.

    DATA: ls_time_profile     TYPE cycrptipro,
          lf_capacity_horizon TYPE i.

    CALL FUNCTION 'CY01_GET_TIME_PROFILE'
      EXPORTING
        profile_id            = ms_overall_profile-tipro_id
      IMPORTING
        crptipro              = ls_time_profile
      EXCEPTIONS
        OTHERS                = 0.
    ls_time_profile-anatimt	   = 'L'  ."Eingabeart Auswertungszeitraum ('L' = Number of calendar Years)
    ls_time_profile-anadatf	   = '-3' ."Startdatum der Auswertung
    ls_time_profile-anadatt	   = '3'  ."Enddatum der Auswertung
*# the values is in calendar days and if it is initial then 100 day will be used
    lf_capacity_horizon = mf_capacity_horizon.
    IF lf_capacity_horizon IS INITIAL.
      lf_capacity_horizon = 100.
    ENDIF.
    ls_time_profile-platimt    = 'G'."Eingabeart Planungszeitraum ( 'G' = Number of calendar Days )
    ls_time_profile-pladatf	   = space."Startdatum des Planungszeitraums (always form today on )
    ls_time_profile-pladatt	   = lf_capacity_horizon."Enddatum des Planungszeitraums
*# backlog left to 0
    ls_time_profile-rdate_type = 'G'."Art der Datumsangabe ( 'G' = Number of calendar Days )
    ls_time_profile-rdate	     = space."Datum der Rückstandseinlastung
*# read everyhting form the DB from 3 years back and 3 years in the future
    ls_time_profile-dbrtimt	   = 'L'."Eingabeart Datenbanklesezeitraum
    ls_time_profile-dbrdatf	   = '-3'."Startdatum der Datenbankselektion
    ls_time_profile-dbrdatt	   = '3'."Enddatum der Datenbankselektion
*# not known what this does
    ls_time_profile-profapp	   = space."Kennung einer Anwendung

    CALL FUNCTION 'CY01_SET_TIME_PROFILE'
      EXPORTING
        profile_id            = ms_overall_profile-tipro_id
        crptipro              = ls_time_profile
      EXCEPTIONS
        OTHERS                = 0.

  ENDMETHOD.

  METHOD CHECK_IF_IS_VALID.

    mf_is_valid = abap_true.

  ENDMETHOD.

  METHOD CONSTRUCTOR.

    mf_capacity_horizon = if_capacity_horizon.
    mf_profile = if_profile_id.
    IF mf_profile IS INITIAL.
      mf_profile = 'SAPSFCG001'.
    ENDIF.
    change_overall_profile( ).
    change_selection_profile( ).
    change_control_profile( ).
    change_time_profile( ).
    change_analysis_profile( ).
    change_strategy_profile( ).

  ENDMETHOD.

  METHOD GET.

    rf_profile = mf_profile.

  ENDMETHOD.

  METHOD IS_VALID.

    rf_answer = mf_is_valid.

  ENDMETHOD.
ENDCLASS.
