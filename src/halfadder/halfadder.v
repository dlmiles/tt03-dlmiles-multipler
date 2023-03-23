`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

//
//
//
module halfadder #(
    parameter	WIDTH = 1
) (
    input	[WIDTH-1:0]	a,
    input	[WIDTH-1:0]	b,

    output	[WIDTH-1:0]	c,
    output	[WIDTH-1:0]	s
);

    assign c = a & b;
    assign s = a ^ b;

endmodule
