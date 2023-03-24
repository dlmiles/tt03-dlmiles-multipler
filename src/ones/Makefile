#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_ONES
VERILOG_SOURCES += $(PWD)/ones/config_ones.vh
VERILOG_SOURCES += $(PWD)/ones/top_ones.v
VERILOG_SOURCES += $(PWD)/ones/ones.v

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/ones/tb_ones.v

else

# GT simulation

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/ones/tb_ones.v

endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_ones
