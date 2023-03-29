`default_nettype none

`include "global.vh"
`include "config.vh"

// This exists a a top level module for production wiring the ports up
module top_carry_look_ahead #(
    parameter	WIDTH = 7
) (
    input	[`INPUT_WIDTH-1:0]		io_in,
    output	[`OUTPUT_WIDTH-1:0]		io_out
);

    wire clk = io_in[`I_CLK_BITID];		// [0]
    // No RESET we are combinational anyway
    wire [WIDTH-1:0] ab = io_in[`I0_A_BITID+WIDTH-1:`I0_A_BITID];	// [1+7-1:1] = [7:1]

    wire [WIDTH-1:0] a;
    wire [WIDTH-1:0] b;
    wire [WIDTH-1:0] s;
    assign io_out[`O_SUM_BITID+WIDTH-1:`O_SUM_BITID] = s;	// [7:1]
    wire c;
    assign io_out[`O_CARRY_BITID] = c;				// [0]

// FIXME destroyed it

    carry_look_ahead #(
        .WIDTH(WIDTH)
    ) carry_look_ahead (
        .a   (a),
        .b   (b),
        .y   (y),
        .c   (c),
        .s   (s)
    );

endmodule
