#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULS_X3Y3
VERILOG_SOURCES += $(PWD)/muls_x3y3/config_muls_x3y3.vh
VERILOG_SOURCES += $(PWD)/muls_x3y3/top_muls_x3y3.v
VERILOG_SOURCES += $(PWD)/muls_x3y3/muls_x3y3.v
VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

TB_VERILOG_SOURCES += $(PWD)/muls_x3y3/tb_muls_x3y3.v

else

# GT simulation
TB_VERILOG_SOURCES += $(PWD)/muls_x3y3/tb_muls_x3y3.v

endif
