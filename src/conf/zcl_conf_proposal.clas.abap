class ZCL_CONF_PROPOSAL definition
  public
  create public .

public section.

  types:
    tt_goodsmovements     TYPE TABLE OF bapi2017_gm_item_create .
  types:
    tt_link_conf_goodsmov TYPE TABLE OF bapi_link_conf_goodsmov .
  types:
    tt_return             TYPE TABLE OF bapi_coru_return .

  data MR_MSG type ref to ZCL_MSG .
  data MT_GOODSMOVEMENTS type TT_GOODSMOVEMENTS .
  data MT_LINK_CONF_GOODSMOV type TT_LINK_CONF_GOODSMOV .
protected section.
private section.
ENDCLASS.

CLASS ZCL_CONF_PROPOSAL IMPLEMENTATION.
ENDCLASS.
