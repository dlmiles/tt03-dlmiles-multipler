#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULU_X2Y2
VERILOG_SOURCES += $(PWD)/mulu_x2y2/config_mulu_x2y2.vh
VERILOG_SOURCES += $(PWD)/mulu_x2y2/top_mulu_x2y2.v
TB_VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_mulu_x2y2.v
VERILOG_SOURCES += $(PWD)/mulu_x2y2/mulu_x2y2.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

#VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_muls_x3y3.v $(PWD)/mulu_x2y2/muls_x3y3.v
#VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v

else

# GT simulation
TB_VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_mulu_x2y2.v

endif
