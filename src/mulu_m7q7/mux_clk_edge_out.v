`default_nettype none

`include "global.vh"
`include "config.vh"	// mulu_m7q7.vh

module mux_clk_edge_out #(
    parameter	WIDTH = 1
) (
    input				clk,
    input	[WIDTH-1:0]		neg,
    input	[WIDTH-1:0]		pos,
    output reg 	[WIDTH-1:0]		out
);

`ifdef FOO

  always@(posedge clk) 
    out <= pos;

  always@(negedge clk) 
    out <= neg;

`else

//  reg [WIDTH-1:0] foo;
//  reg [WIDTH-1:0] foop;
//  always @(posedge clk)
//    foop <= pos;
//
//  always @(negedge clk)
//    foo <= neg;

//  always_comb begin
//     out = clk ? 7'b1010101 : 7'b0101010;
//  end

  assign out = clk ? pos : neg;

//  assign out = clk ? 7'b1110001 : 7'b0001110;

`endif

endmodule
