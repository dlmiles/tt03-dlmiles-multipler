
// @also Makefile: pick correct include
//`define	IMPL_ONES		1
//`define	IMPL_HALFADDER		1
//`define	IMPL_FULLADDER		1
//`define	IMPL_MULU_X2Y2		1
//`define	IMPL_MULU_X3Y3		1

`ifdef IMPL_ONES
`include "ones/ones.vh"
`endif

`ifdef IMPL_HALFADDER
`include "halfadder/halfadder.vh"
`endif

`ifdef IMPL_FULLADDER
`include "fulladder/fulladder.vh"
`endif

`ifdef IMPL_MULU_X2Y2
`include "mulu_x2y2/mulu_x2y2.vh"
`endif

`ifdef IMPL_MULU_X3Y3
`include "mulu_x3y3/mulu_x3y3.vh"
`endif
