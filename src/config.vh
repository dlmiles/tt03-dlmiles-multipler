
//`define	IMPL_HALFADDER		1
`define	IMPL_FULLADDER		1
//`define	IMPL_MULU_X2Y2		1

`ifdef IMPL_HALFADDER
`include "halfadder/halfadder.vh"
`endif

`ifdef IMPL_FULLADDER
`include "fulladder/fulladder.vh"
`endif

`ifdef IMPL_MULU_X2Y2
`include "mulu_x2y2/mulu_x2y2.vh"
`endif
