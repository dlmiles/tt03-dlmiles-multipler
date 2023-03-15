#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULU_X2Y2
VERILOG_SOURCES += $(PWD)/mulu_x2y2/config_mulu_x2y2.vh
# this is the only part you should need to modify:
VERILOG_SOURCES += $(PWD)/mulu_x2y2/top_mulu_x2y2.v
VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_mulu_x2y2.v
VERILOG_SOURCES += $(PWD)/mulu_x2y2/mulu_x2y2.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

#VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_fulladder.v
#VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_muls_x3y3.v $(PWD)/mulu_x2y2/muls_x3y3.v
#VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v

else

# GT simulation
VERILOG_SOURCES += $(PWD)/mulu_x2y2/tb_mulu_x2y2.v

endif
