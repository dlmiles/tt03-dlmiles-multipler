#
#  Sorry to need this due to the multi-directory project layout.
#
parray ::env

puts [::pwd]

#
# The src/Makefile build everything relative to the src dir.
# So `include "config.vh" works from a sub-dir *.v, when the file is in src/
#
# But OpenLANE appears to manage Verilog `include to means the source is the
#  location of the verilog file itself.  Or at least does not automatically
#  include the top level.
#

# https://openlane.readthedocs.io/en/latest/reference/configuration.html#synthesis
# I assume this can be colon-character ":" delimited like $PATH, the docs are not
# immediately helpful to know that.

# If a directory "include" exists, then it assumes you strcture everything from there.
if { [file isdirectory "$::env(DESIGN_DIR)/include"] } {
  if { [info exists ::env(VERILOG_INCLUDE_DIRS)] } {
    set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)/include:$::env(VERILOG_INCLUDE_DIRS)"
  } else {
    set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)"
  }
} else {
  # Otherwise add in the DESIGN_DIR so it works like icarus/cocotb does locally
  if { [info exists ::env(VERILOG_INCLUDE_DIRS)] } {
    set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR):$::env(VERILOG_INCLUDE_DIRS)"
  } else {
    set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)"
  }
}

parray ::env
