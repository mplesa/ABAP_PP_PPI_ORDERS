*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK type WITH FRAME TITLE text-004.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-001.
PARAMETERS: pa_a RADIOBUTTON GROUP rad1 MODIF ID a USER-COMMAND type DEFAULT 'X'.
SELECTION-SCREEN COMMENT 35(15) text-002 MODIF ID a FOR FIELD pa_a.
PARAMETERS: pa_p RADIOBUTTON GROUP rad1 MODIF ID p.
SELECTION-SCREEN COMMENT 53(22) text-003 MODIF ID p FOR FIELD pa_p.
SELECTION-SCREEN END OF LINE.
PARAMETERS: pa_aufnr TYPE aufnr MODIF ID auf
                                MEMORY ID anr,
            pa_plnum TYPE plnum MODIF ID pln
                                MEMORY ID paf,
            pa_virt  TYPE flag MODIF ID pln NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK type.
