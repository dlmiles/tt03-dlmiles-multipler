`default_nettype none

`include "global.vh"
`include "config.vh"

// This exists a a top level module for production wiring the ports up
module top_fulladder #(
    parameter WIDTH = 1
) (
    input	[`INPUT_WIDTH-1:0]		io_in,
    output	[`OUTPUT_WIDTH-1:0]		io_out
);

    wire clk = io_in[`I_CLK_BITID];		// 0
    wire reset = io_in[`I_RST_BITID];		// 1
    wire [`WIDTH-1:0] a = io_in[`I_A_BITID+`WIDTH-1:`I_A_BITID];	// [2:2]
    wire [`WIDTH-1:0] b = io_in[`I_B_BITID+`WIDTH-1:`I_B_BITID];	// [3:3]
    wire [`WIDTH-1:0] y = io_in[`I_Y_BITID];				// [4]

    wire c;
    assign io_out[`O_CARRY_BITID] = c;		// 6
    wire s;
    assign io_out[`O_SUM_BITID] = s;		// 7

    fulladder #(
      .WIDTH(WIDTH)
    ) fulladder(
      .a   (a),
      .b   (b),
      .y   (y),
      .c   (c),
      .s   (s)
    );

endmodule
