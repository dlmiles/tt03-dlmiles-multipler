`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

// Comment me out for the generator method below
`define USE_SYNTH_METHOD 1

//
//
//
module ones #(
    parameter	WIDTH = 1
) (
    input	[WIDTH-1:0]	i,

    output	[WIDTH-1:0]	o
);

`ifdef USE_SYNTH_METHOD

    // Verilog synthesis will perform the operation with some syntactic sugar
    assign o = ~i;

`else

    // Negate / invert
    genvar geni;
    generate //: gennot
        for (geni = 0; geni < WIDTH; geni = geni + 1) begin			// loop WIDTH times, from 0
            assign o[geni] = ~i[geni];
        end
    endgenerate

`endif

endmodule
