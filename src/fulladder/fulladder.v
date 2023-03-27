`default_nettype none
`timescale 1ns/1ps

// Comment me out for the generator method below
`define USE_SYNTH_METHOD 1

//
//
//
module fulladder #(
    parameter	WIDTH = 1
) (
    input	[WIDTH-1:0]	a,
    input	[WIDTH-1:0]	b,
    input			y,

    output			c,
    output	[WIDTH-1:0]	s
);

`ifdef USE_SYNTH_METHOD

    // Verilog synthesis will perform the operation with some syntactic sugar
    assign {c, s} = a + b + y;

    //assign c = (a & b) | (b & y) | (a & y);
    //assign s = (a^b)^y;

`else

    wire [WIDTH-1+1:0] carry;	// +1 due to generate use

    assign carry[0] = y;	// carry-in

    genvar geni;
    generate //: gencarry
        for (geni = 0; geni < WIDTH; geni = geni + 1) begin			// loop WIDTH times, from 0

            assign {carry[geni], s[geni]} = a[geni] + b[geni] + carry[geni];

            //assign carry[geni+1] = (a[geni] & b[geni]) | (b[geni] & carry[geni]) | (a[geni] & carry[geni]);
            //assign s[geni] = (a[geni]^b[geni])^carry[geni];

       end
    endgenerate

    assign c = carry[WIDTH];	// carry-out

`endif

endmodule
