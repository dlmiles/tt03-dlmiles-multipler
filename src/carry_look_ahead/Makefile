#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_FULLADDER
ifeq ($(IMPL_NEGEDGE_CARRY_LOOK_AHEAD),1)
 VERILOG_SOURCES += $(PWD)/carry_look_ahead/config_negedge_carry_look_ahead.vh
 VERILOG_SOURCES += $(PWD)/carry_look_ahead/top_negedge_carry_look_ahead.v
 VERILOG_SOURCES += $(PWD)/mulu_m7q7/mux_clk_edge_in.v
else
 VERILOG_SOURCES += $(PWD)/carry_look_ahead/config_carry_look_ahead.vh
 VERILOG_SOURCES += $(PWD)/carry_look_ahead/top_carry_look_ahead.v
endif
VERILOG_SOURCES += $(PWD)/carry_look_ahead/carry_look_ahead.v

# replace tb.v
ifeq ($(IMPL_NEGEDGE_CARRY_LOOK_AHEAD),1)
 TB_VERILOG_SOURCES = $(PWD)/tb_negedge.v
else
 TB_VERILOG_SOURCES = $(PWD)/carry_look_ahead/tb_carry_look_ahead.v
endif

else

# GT simulation

# replace tb.v
ifeq ($(IMPL_NEGEDGE_CARRY_LOOK_AHEAD),1)
 TB_VERILOG_SOURCES = $(PWD)/tb_negedge.v
else
 TB_VERILOG_SOURCES = $(PWD)/carry_look_ahead/tb_carry_look_ahead.v
endif

endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
ifeq ($(IMPL_NEGEDGE_CARRY_LOOK_AHEAD),1)
 TOPLEVEL = tb_negedge
else
 TOPLEVEL = tb_carry_look_ahead
endif
