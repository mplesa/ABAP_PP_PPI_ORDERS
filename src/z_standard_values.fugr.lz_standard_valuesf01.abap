*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form PBO_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pbo_0100 .
  DATA: lf_fname TYPE fieldname.
  FIELD-SYMBOLS: <lf_vgtext> TYPE rcr01-vgtl1,
                 <lf_vgm> TYPE rcr01-vgm01.

  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100' WITH gr_order->mf_plnid gr_operation->mf_vornr.

  IF gr_order->ms_caufvd-autyp = zcl_order=>co_autyp-process.
    gf_operation_name = 'Phase'(002).
  ELSE.
    gf_operation_name = 'Vorgang'(001).
  ENDIF.

  LOOP AT SCREEN.
*# set non-input values to non-input
    IF screen-group1(2) = 'VG'.
      CONCATENATE 'VGTL' screen-group1+2(1) INTO lf_fname.
      ASSIGN COMPONENT lf_fname OF STRUCTURE rcr01 TO <lf_vgtext>.
      CONCATENATE 'VGM0' screen-group1+2(1) INTO lf_fname.
      ASSIGN COMPONENT lf_fname OF STRUCTURE rcr01 TO <lf_vgm>.
      IF <lf_vgtext> IS INITIAL
        OR <lf_vgm> = '0'.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " PBO_0100
