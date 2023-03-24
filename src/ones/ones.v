`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

//
//
//
module ones #(
    parameter	WIDTH = 1
) (
    input	[WIDTH-1:0]	i,

    output	[WIDTH-1:0]	o
);

    assign o = ~i;

endmodule
