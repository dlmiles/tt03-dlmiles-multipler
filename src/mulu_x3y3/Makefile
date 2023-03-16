#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULU_X3Y3
VERILOG_SOURCES += $(PWD)/mulu_x3y3/config_mulu_x3y3.vh
VERILOG_SOURCES += $(PWD)/mulu_x3y3/top_mulu_x3y3.v
VERILOG_SOURCES += $(PWD)/mulu_x3y3/mulu_x3y3.v
VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

TB_VERILOG_SOURCES += $(PWD)/mulu_x3y3/tb_mulu_x3y3.v

else

# GT simulation
TB_VERILOG_SOURCES += $(PWD)/mulu_x3y3/tb_mulu_x3y3.v

endif
