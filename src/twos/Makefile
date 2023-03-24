#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_TWOS
VERILOG_SOURCES += $(PWD)/twos/config_twos.vh
VERILOG_SOURCES += $(PWD)/twos/top_twos.v
VERILOG_SOURCES += $(PWD)/twos/twos.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/twos/tb_twos.v

else

# GT simulation

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/twos/tb_twos.v

endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_twos
