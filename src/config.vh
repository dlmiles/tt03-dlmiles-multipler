
// @also Makefile: pick correct include
//`define	IMPL_ONES		1
//`define	IMPL_TWOS		1
//`define	IMPL_HALFADDER		1
//`define	IMPL_FULLADDER		1
//`define	IMPL_CARRY_LOOK_AHEAD	1
//`define	IMPL_MULU_M2Q2		1
//`define	IMPL_MULU_M3Q3		1
//`define	IMPL_MULU_M7Q7		1

`ifdef IMPL_ONES
`include "ones/ones.vh"
`endif

`ifdef IMPL_TWOS
`include "twos/twos.vh"
`endif

`ifdef IMPL_HALFADDER
`include "halfadder/halfadder.vh"
`endif

`ifdef IMPL_FULLADDER
`include "fulladder/fulladder.vh"
`endif

`ifdef IMPL_CARRY_LOOK_AHEAD
`include "carry_look_ahead/carry_look_ahead.vh"
`endif
`ifdef IMPL_NEGEDGE_CARRY_LOOK_AHEAD
`include "carry_look_ahead/carry_look_ahead.vh"
`endif

`ifdef IMPL_MULU_M2Q2
`include "mulu_m2q2/mulu_m2q2.vh"
`endif

`ifdef IMPL_MULU_M3Q3
`include "mulu_m3q3/mulu_m3q3.vh"
`endif

`ifdef IMPL_MULU_M7Q7
`include "mulu_m7q7/mulu_m7q7.vh"
`endif
