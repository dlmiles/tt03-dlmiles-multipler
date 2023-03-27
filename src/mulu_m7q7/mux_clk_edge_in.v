`default_nettype none

`include "global.vh"
`include "config.vh"	// mulu_m7q7.vh

`define REG_NEG 1
// REG_POS Not needed, if readback is 100ns after posedge clk ?
`define REG_POS 1

module mux_clk_edge_in #(
    parameter	WIDTH = 1,
    parameter   REG_NEG = 0,
    parameter   REG_POS = 0
) (
    input				clk,
    input	[WIDTH-1:0]		in,

    output	[WIDTH-1:0]		neg,
    output	[WIDTH-1:0]		pos
);

`ifdef REG_POS
  reg [WIDTH-1:0] reg_pos;
  always@(posedge clk) begin
    reg_pos <= in;
  end
//  assign pos = clk ? in : reg_pos;
  assign pos = reg_pos;
`else
//  always_comb begi
//    if clk begin
//       pos = in;
//    end else begin
//       pos = 0; //WIDTH'b0;
//    end
//    pos = clk ? in : 0;
//  end
  assign pos = clk ? in : 0; // WIDTH'b0;
`endif

`ifdef REG_NEG
  reg [WIDTH-1:0] reg_neg;
  always @(negedge clk) begin
    reg_neg <= in;
  end
  assign neg = clk ? in : reg_neg;
//  assign neg = reg_neg; // : in;
`else
//  always_comb begin
//    neg <= 0;
//  end
  assign neg = clk ? 0 : in;	// WIDTH'b0
`endif

endmodule
