#
#
#
ifneq ($(GATES),yes)
# normal simulation

#SIM_ARGS        += -DIMPL_MULU_M3Q3
VERILOG_SOURCES += $(PWD)/mulu_m3q3/config_mulu_m3q3.vh
VERILOG_SOURCES += $(PWD)/mulu_m3q3/top_mulu_m3q3.v
VERILOG_SOURCES += $(PWD)/mulu_m3q3/mulu_m3q3.v
VERILOG_SOURCES += $(PWD)/fulladder/fulladder.v
VERILOG_SOURCES += $(PWD)/halfadder/halfadder.v

TB_VERILOG_SOURCES += $(PWD)/mulu_m3q3/tb_mulu_m3q3.v

else

# GT simulation
TB_VERILOG_SOURCES += $(PWD)/mulu_m3q3/tb_mulu_m3q3.v

endif
