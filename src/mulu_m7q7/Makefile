#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULX_M7Q7
VERILOG_SOURCES += $(PWD)/mulu_m7q7/config_mulu_m7q7.vh
VERILOG_SOURCES += $(PWD)/mulu_m7q7/top_mulu_m7q7.v
VERILOG_SOURCES += $(PWD)/mulu_m7q7/mulu_m7q7.v
VERILOG_SOURCES += $(PWD)/mulu_m7q7/mux_clk_edge_out.v
VERILOG_SOURCES += $(PWD)/mulu_m7q7/mux_clk_edge_in.v
VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/tb_negedge.v
TB_VERILOG_SOURCES += $(PWD)/mulu_m7q7/tb_mulu_m7q7.v

else

# replace tb.v
TB_VERILOG_SOURCES = $(PWD)/tb_negedge.v
# GT simulation
TB_VERILOG_SOURCES += $(PWD)/mulu_m7q7/tb_mulu_m7q7.v

endif

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = tb_negedge
