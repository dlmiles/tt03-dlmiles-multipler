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

    output	[WIDTH-1:0]	s,
    output	[WIDTH-1:0]	c
);

    assign s = a ^ b;
    assign c = a & b;

endmodule
