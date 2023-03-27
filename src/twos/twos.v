`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

// Comment me out for the generator method below
`define USE_SYNTH_METHOD 1

//
//
//
module twos #(
    parameter	WIDTH = 1
) (
    input	[WIDTH-1:0]	i,

    output	[WIDTH-1:0]	o
);

`ifdef USE_SYNTH_METHOD

    // Verilog synthesis will perform the operation with some syntactic sugar
    assign o = ~i + 1;

`else    

    // If we were to write the operation by hand it would look like:
    wire [WIDTH-1:0] neg;
    assign neg = ~i;

    wire [WIDTH-1+1:0] tmp;	// +1 due to generator use, it will be thrown away as the wire is only connected at one end
    assign tmp[0] = 1'b1;	// The number 1 we are adding

    // Setup adders with carry, to add one
    genvar geni;
    generate //: gencarry
        for (geni = 0; geni < WIDTH; geni = geni + 1) begin			// loop WIDTH times, from 0
            halfadder #(
                .WIDTH(1)
            ) ha (
                .a  (tmp[geni]),
                .b  (neg[geni]),
                .c  (tmp[geni+1]),
                .s  (o[geni])
            );
        end
    endgenerate

`endif

endmodule
