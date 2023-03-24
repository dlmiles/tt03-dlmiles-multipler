# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

COMPILE_ARGS    += -I$(PWD)
TB_VERILOG_SOURCES += $(PWD)/tb.v

# normal simulation
ifneq ($(GATES),yes)

else

# gate level simulation requires some extra setup, you shouldn't need to touch this
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130B/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130B/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v
endif

# @also config.vh: pick correct `define

include $(PWD)/ones/Makefile
#include $(PWD)/halfadder/Makefile
#include $(PWD)/fulladder/Makefile
#include $(PWD)/mulu_x2y2/Makefile
#include $(PWD)/mulu_x3y3/Makefile

VERILOG_SOURCES += $(TB_VERILOG_SOURCES)

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL ?= tb

# MODULE is the basename of the Python test file
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim


distclean: clean
	$(RM) tb.vcd tb_*.vcd
	$(RM) -r __pycache__
