`default_nettype none

`include "global.vh"
`include "config.vh"	// mulu_m7q7.vh

// This exists as a top level module for production wiring the ports up
module top_mulu_m7q7 (
    input	[`INPUT_WIDTH-1:0]		io_in,
    output	[`OUTPUT_WIDTH-1:0]		io_out
);

    wire clk = io_in[`I_CLK_BITID];		// 0
    // No RESET we are combinational anyway
    wire [`X_WIDTH-1:0] mq = io_in[`I0_X_BITID+`X_WIDTH-1:`I0_X_BITID];	// [1+7-1] = [7:1]

    wire [`X_WIDTH-1:0] m;
    wire [`Y_WIDTH-1:0] q;
    wire [`P_WIDTH-1:0] p;

    //assert(`O0_P_LSB_BITID == `O1_P_MSB_BITID);
    //assert(`X_WIDTH == `Y_WIDTH);

//reg [`OUTPUT_WIDTH-1:0] tmp;
//  reg [`OUTPUT_WIDTH-1:0] mux;
//  always@(posedge clk) 
//    mux[7:1] <= 7'b0101010;

//  always@(negedge clk) 
//    mux[7:1] <= 7'b1010101;

//assign io_out[7:1] = mux[7:1];
// (tmp[7:1]) 
   
    mux_clk_edge_out #(
        .WIDTH(7)
    ) mux_out (
        .clk (clk),
        .neg (p[13:7]),
        .pos (p[6:0]),
        .out (io_out[7:`O0_P_LSB_BITID])	// 1
    );

//    assign pp = { 14'b010100110011, io_in[1:0] };

//    wire [`P_WIDTH-1:0] p;

    mulu_m7q7 mulu_m7q7(
        .m   (m),
        .q   (q),
        .p   (p)
    );

    mux_clk_edge_in #(
        .WIDTH(7)
    ) mux_in (
        .clk (clk),
        .in  (mq),	// io_in[7:1]
        .neg (m),
        .pos (q)
    );

    assign io_out[0] = 1'b0;    // [0] pull-down unused pins for Z-state free wave

endmodule
