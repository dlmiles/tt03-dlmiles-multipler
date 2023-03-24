`default_nettype none

`include "global.vh"
`include "config.vh"

// This exists as a top level module for production wiring the ports up
module top_twos (
    input	[`INPUT_WIDTH-1:0]		io_in,
    output	[`OUTPUT_WIDTH-1:0]		io_out
);

    wire clk = io_in[`I_CLK_BITID];		// 0
    wire reset = io_in[`I_RST_BITID];		// 1
    wire [`TWOS_WIDTH-1:0] i = io_in[`I_I0_BITID+`TWOS_WIDTH-1:`I_I0_BITID];	// [5:2]

    wire [`TWOS_WIDTH-1:0] o;
    assign io_out[`O_O0_BITID+`TWOS_WIDTH-1:`O_O0_BITID] = o;		// [5:2]

    twos #(
      .WIDTH(TWOS_WIDTH)
    ) twos(
      .i   (i),
      .o   (o)
    );

    assign io_out[`OUTPUT_WIDTH-1:`TWOS_WIDTH] = `OUTPUT_WIDTH-`TWOS_WIDTH'b0;    // [7:6] pull-down unused pins for Z-state clear wave

endmodule
