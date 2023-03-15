#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_HALFADDER
VERILOG_SOURCES += $(PWD)/halfadder/config_halfadder.vh
VERILOG_SOURCES += $(PWD)/halfadder/top_halfadder.v
# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/halfadder/tb_halfadder.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

else

# GT simulation
TB_VERILOG_SOURCES = $(PWD)/halfadder/tb_halfadder.v

endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_halfadder
