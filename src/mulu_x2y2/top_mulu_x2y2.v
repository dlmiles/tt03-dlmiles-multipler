`default_nettype none

`include "global.vh"
`include "mulu_x2y2.vh"

// This exists a a top level module for production wiring the ports up
module top_mulu_x2y2 #(
    parameter NOOP = 0
) (
    input	[7:0]		io_in,
    output	[7:0]		io_out
);

    wire clk = io_in[`I_CLK_BITID];		// 0
    wire reset = io_in[`I_RST_BITID];		// 1
    wire [`X_WIDTH-1:0] x = io_in[`I_X_BITID+`X_WIDTH-1:`I_X_BITID];	// [3:2]
    wire [`Y_WIDTH-1:0] y = io_in[`I_Y_BITID+`Y_WIDTH-1:`I_Y_BITID];	// [5:4]

    wire [`P_WIDTH-1:0] p;
    assign io_out[`O_P_BITID+`P_WIDTH-1:`O_P_BITID] = p;	// [3:0]
`ifdef HAS_SIGN
    wire s;
    assign io_out[`O_SIGN_BITID] = s;		// 6
`endif
`ifdef HAS_READY
    wire rdy;
    assign io_out[`O_READY_BITID] = rdy;	// 7
`endif

    mulu_x2y2 mulu_x2y2(
        .x   (x),
        .y   (y),
        .p   (p)
`ifdef HAS_SIGN
      , .s   (s)
`endif
`ifdef HAS_READY
      , .rdy (rdy)
`endif
    );

endmodule
