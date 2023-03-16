#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_FULLADDER
VERILOG_SOURCES += $(PWD)/fulladder/config_fulladder.vh
VERILOG_SOURCES += $(PWD)/fulladder/top_fulladder.v
VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/fulladder/tb_fulladder.v

else

# GT simulation

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/fulladder/tb_fulladder.v

endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_fulladder
