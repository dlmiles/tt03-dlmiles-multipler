#
#  Sorry to need this due to the multi-directory project layout.
#
parray ::env

puts "PWD [::pwd]"

# Ok so this file is activated by
#  *  Checking it into the project as src/config_extra.tcl
#  *  Editing config.tcl to include lines just below other 'source' directive:
#    This is part of this project and the only edit to this file
#    source $::env(DESIGN_DIR)/config_extra.tcl
#  *  Adding the file to info.yaml/source_files as 'config_extra.tcl'

# The purpose is to remove itself from the envvar $VERILOG_FILES because
#  of the above method of adding and the tt-support-tools adding it even
#  with *.tcl
# Remove from $VERILOG_FILES: /work/src/config_extra.tcl
if { [info exists ::env(VERILOG_FILES)] } {
   set _verilog_files [list]

   foreach item [regexp -all -inline {\S+} $::env(VERILOG_FILES)] {
       if { ![regexp {\.tcl$} $item] } {       # remove *.tcl
           # keep reset
           lappend _verilog_files $item	
       }
   }
   set _verilog_files_edited [join [list $_verilog_files] " "]

   if { "$::env(VERILOG_FILES)" ne "$_verilog_files_edited" } {
       set ::env(VERILOG_FILES) "$_verilog_files_edited"
   }
   puts "VERILOG_FILES = $::env(VERILOG_FILES)"
}


# Due to the multiple directory native I need to setup for OpenLANE
#   tcl ::env(VERILOG_INCLUDE_DIRS)
#
#
#
#
#
# The src/Makefile builds everything relative to the src dir.
# So `include "config.vh" works from a sub-dir *.v, when the file is in src/
#
# But OpenLANE appears to manage Verilog `include to means the source is the
#  location of the verilog file itself.  Or at least does not automatically
#  find *.vh files at top level.
#

# https://openlane.readthedocs.io/en/latest/reference/configuration.html#synthesis
# I assume this can be colon-character ":" delimited like $PATH, the docs are not
# immediately helpful to know that.

# If a directory "include" exists, then it assumes you structure everything from there.
if { [info exists ::env(DESIGN_DIR)] } {
  if { [file isdirectory "$::env(DESIGN_DIR)/include"] } {
    if { [info exists ::env(VERILOG_INCLUDE_DIRS)] } {
      set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)/include:$::env(VERILOG_INCLUDE_DIRS)"
    } else {
      # Don't create an empty path entry
      set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)"
    }
  } else {
    # Otherwise add in the DESIGN_DIR itself so it works like icarus/cocotb does locally
    # It is assumed DESIGN_DIR = gitproject/src at this time until this script is debugged/checked
    if { [info exists ::env(VERILOG_INCLUDE_DIRS)] } {
      set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR):$::env(VERILOG_INCLUDE_DIRS)"
    } else {
      # Don't create an empty path entry
      set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)"
    }
  }
  puts "VERILOG_INCLUDE_DIRS = $::env(DESIGN_DIR)/include"
}

parray ::env
