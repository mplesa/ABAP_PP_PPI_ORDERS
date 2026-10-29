PROCESS BEFORE OUTPUT.
  MODULE pbo_0100.

PROCESS AFTER INPUT.
  MODULE user_command_0100 AT EXIT-COMMAND.
  CHAIN.
    FIELD: afvgd-vge01,
           afvgd-vge02,
           afvgd-vge03,
           afvgd-vge04,
           afvgd-vge05,
           afvgd-vge06.
    MODULE check_unit_0100 ON CHAIN-REQUEST.
  ENDCHAIN.
  MODULE user_command_0100.
