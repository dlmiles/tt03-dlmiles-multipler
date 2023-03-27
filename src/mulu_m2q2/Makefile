#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULU_M2Q2
VERILOG_SOURCES += $(PWD)/mulu_m2q2/config_mulu_m2q2.vh
VERILOG_SOURCES += $(PWD)/mulu_m2q2/top_mulu_m2q2.v
VERILOG_SOURCES += $(PWD)/mulu_m2q2/mulu_m2q2.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

TB_VERILOG_SOURCES += $(PWD)/mulu_m2q2/tb_mulu_m2q2.v

else

# GT simulation
TB_VERILOG_SOURCES += $(PWD)/mulu_m2q2/tb_mulu_m2q2.v

endif
