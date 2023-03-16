`default_nettype none

`include "global.vh"
`include "mulu_x3y3.vh"

// Unsigned Multipler, X width 3, Y width 3, making P result width 6
module mulu_x3y3 (
    input	[`X_WIDTH-1:0]	x,
    input	[`Y_WIDTH-1:0]	y,

    output	[`P_WIDTH-1:0]	p
`ifdef HAS_SIGN
    , output			s
`endif
`ifdef HAS_READY
    , output			rdy
`endif
);

`ifdef HAS_SIGN
    // sign bit
    assign s = x[`X_WIDTH-1] ^ y[`Y_WIDTH-1];
`endif
`ifdef HAS_READY
    // always ready
    assign rdy = `READY_TRUE;
`endif

    /////// PARTIAL PRODUCTS

    // This method is better for working when X_WIDTH != Y_WIDTH
    wire [`Y_WIDTH-1:0] pp [`X_WIDTH-1:0];

    genvar ppiy;
    genvar ppix;
    generate //: genpp
        for (ppiy = 0; ppiy < `Y_WIDTH; ppiy = ppiy + 1) begin		// loop 3 times, from 0
            // If X_WIDTH == Y_WIDTH then this for loop below means:
            // pp[iy][`X_WIDTH-1:0] = x[`X_WIDTH-1:0] & {`X_WIDTH{y[ppiy]}}
            for(ppix = 0; ppix < `X_WIDTH; ppix = ppix + 1) begin	// loop 3 times, from 0
                assign pp[ppiy][ppix] = x[ppix] & y[ppiy];
            end
        end
    endgenerate


    //////// FULL ADDERS

    wire [`Y_WIDTH:0] ppc;	// +1 size
    assign ppc[0] = 1'b0;	// maybe this should be external for cascade ? and remove the -2 ?

    // `Y_WIDTH - 2: due to intervals needing adders
    wire [`Y_WIDTH-2:0] pps [`X_WIDTH-1:0];

    genvar faiy;
    // `Y_WIDTH - 1: due to intervals needing adders
    for(faiy = 0; faiy < `Y_WIDTH; faiy = faiy + 1) begin : iy		// loop 2 times, from 1
        fulladder #(
            .WIDTH(`X_WIDTH)
        ) fulladder$bit$faiy (
            .ci (ppci[faiy]),
            .a  (pp[faiy][:1]),
            .b  ({  pp[faiy+1][`X_WIDTH-2:1],  1'b0  }),	// -2 right-shift <<1
            .s  (pps[faiy]),
            .co (ppci[faiy+1])
        );
        assign p[faiy] <= pps[faiy];
    end
    assign p[`P_WIDTH-1:`Y_WIDTH] = pps[];
    assign sign <= ppci[`Y_WIDTH-1];	// from last co

endmodule
