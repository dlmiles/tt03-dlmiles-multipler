`default_nettype none

`define X_WIDTH 3
`define Y_WIDTH 3

`define P_WIDTH 6
`define HAS_SIGN	1
`define	S_WIDTH		1

`define I_CLK_BITID	0
`define I_RST_BITID	1
`define I_X_BITID	2
`define I_Y_BITID	5

`define O_SIGN_BITID	6
`define O_READY_BITID	7

`define READY_FALSE	1'b0
`define READY_TRUE	1'b1

// Signed Multipler, X width 3, Y width 3, making result width 7
module muls_x3y3 (
    input [7:0] io_in,
    output [7:0] io_out
);

    // relabel inputs for SIM
    wire clk = io_in[`I_CLK_BITID];		// 0
    wire reset = io_in[`I_RST_BITID];		// 1
    // input X
    wire [`X_WIDTH-1:0] x;
    assign x[`X_WIDTH-1:0] = io_in[`I_X_BITID+`X_WIDTH-1:`I_X_BITID];	// 2+3-1:2 // 4:2
    // input Y
    wire [`Y_WIDTH-1:0] y;
    assign y[`Y_WIDTH-1:0] = io_in[`I_Y_BITID+`Y_WIDTH-1:`I_Y_BITID];	// 5+3-1:5 // 7:5

    reg [`P_WIDTH-1:0] p;
    assign io_out[`P_WIDTH-1:0] = p;
`ifdef HAS_SIGN
    reg sign;
    assign io_out[`O_SIGN_BITID] = sign;
`endif
    reg ready;
    assign io_out[`O_READY_BITID] = ready;

    always @(*) begin
`ifdef HAS_SIGN
        // sign bit
        sign <= x[`X_WIDTH-1] ^ y[`Y_WIDTH-1];
`endif
        p <= `P_WIDTH'b000000;	// 6'b000000
        ready <= `READY_TRUE;
    end

    /////// PARTIAL PRODUCTS

    // This method is better for working when X_WIDTH != Y_WIDTH
    wire [`Y_WIDTH-1:0][`X_WIDTH-1:0] pp;

    genvar ppiy;
    genvar ppix;
    generate for (ppiy = 0; ppiy < `Y_WIDTH; ppiy = ppiy + 1) begin : genpp
            // If X_WIDTH == Y_WIDTH then this for loop below means:
            // pp[iy][`X_WIDTH-1:0] = x[`X_WIDTH-1:0] & {`X_WIDTH{y[ppiy]}}
            for(ppix = 0; ppix < `X_WIDTH; ppix = ppix + 1) begin
                assign pp[ppiy][ppix] = x[ppix] & y[ppiy];
            end
        end
    endgenerate


    //////// FULL ADDERS

    wire [`Y_WIDTH:0] ppc;	// +1 size
    assign ppc[0] = 1'b0;	// maybe this should be external for cascade ? and remove the -2 ?

    // `Y_WIDTH - 2: due to intervals needing adders
    wire [`Y_WIDTH-2:0][`X_WIDTH-1:0] pps;

    genvar faiy;
    // `Y_WIDTH - 1: due to intervals needing adders
    for(faiy = 0; faiy < `Y_WIDTH; faiy = faiy + 1) begin
        fulladder #(
            .WIDTH(`X_WIDTH)
        ) fulladder$bit$faiy (
            .y  (ppci[faiy]),
            .a  (pp[faiy][:1]),
            .b  ({  pp[faiy+1][`X_WIDTH-2:1],  1'b0  }),	// -2 right-shift <<1
            .s  (pps[faiy]),
            .c  (ppci[faiy+1])
        );
        assign p[faiy] <= pps[faiy];
    end
    assign p[`P_WIDTH-1:`Y_WIDTH] = pps[];
    assign sign <= ppci[`Y_WIDTH-1];	// from last carry-out

endmodule
