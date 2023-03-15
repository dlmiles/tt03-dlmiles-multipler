`default_nettype none

`define X_WIDTH 2
`define Y_WIDTH 2

`define P_WIDTH 4
`define HAS_SIGN	0
`define	S_WIDTH		0

`define HAS_READY	0

`define I_CLK_BITID	0
`define I_RST_BITID	1
`define I_X_BITID	2
`define I_Y_BITID	4

`define O_SIGN_BITID	6
`define O_READY_BITID	7

`define READY_FALSE	1'b0
`define READY_TRUE	1'b1

// Unsigned Multipler, X width 2, Y width 2, making P result width 4
module mulu_x2y2 (
    input	[`X_WIDTH-1:0]	x,
    input	[`X_WIDTH-1:0]	y,

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
    wire [`Y_WIDTH-1:0][`X_WIDTH-1:0] pp;

    genvar ppiy;
    genvar ppix;
    generate //: genpp
        for (ppiy = 0; ppiy < `Y_WIDTH; ppiy = ppiy + 1) begin		// loop 2 times, from 0
            // If X_WIDTH == Y_WIDTH then this for loop below means:
            // pp[iy][`X_WIDTH-1:0] = x[`X_WIDTH-1:0] & {`X_WIDTH{y[ppiy]}}
            for(ppix = 0; ppix < `X_WIDTH; ppix = ppix + 1) begin	// loop 2 times, from 0
                assign pp[ppiy][ppix] = x[ppix] & y[ppiy];
            end
        end
    endgenerate


    //////// HALF ADDERS

    // adder-sum (which aliases output product)
    //    the LSB (PP0[0]) and MSB (last carry-out) have special treatment
    wire [`P_WIDTH-1:0] ads;

    assign ads[0] = pp[0][0];			// LSB output (LSB of PP0)

    // adder-carry chain
    wire [`X_WIDTH:0] acc;			// +1

    // we set this up so the generate block can cascade
    assign acc[0] = pp[0][1];	// adder-carry maybe this should be external for cascade when supported ?

//    genvar adiy;
//    genvar adix;
//    genvar adip;	// the product bit id we're working on to name the adder
    // note we start at bit1 as LSB(bit0) has already had special treatment
//    generate //: genad
//        //adip = 1;
//        for(adiy = 1; adiy < `Y_WIDTH - 1; adiy = adiy + 1) begin	// loop 1 time, from 1
//            for(adix = 1; adix < `X_WIDTH; adix = adix + 1) begin	// loop 2 times, from 1
//                halfadder #(
//                    .WIDTH(1)
//                ) halfadder_$adiy_$adix_$adip (
//                    .a  (1'b0), //(acc[adix-1]),
//                    .b  (1'b1), //(pp[adiy][adix-1]),
//                    .s  (ads[adix]),
//                    .c  (acc[adix])
//                );
//                //adip = adip + 1;
//            end
//        end
//    endgenerate

    halfadder #(.WIDTH(1)) halfadder_$adiy1_$adix1_$adip1
    (
                    .a  (acc[0]), //(acc[adix-1]),
                    .b  (pp[1][0]), //(pp[adiy][adix-1]),
                    .s  (ads[1]),
                    .c  (acc[1])
    );
    halfadder #(.WIDTH(1)) halfadder_$adiy1_$adix2_$adip2
    (
                    .a  (acc[1]), //(acc[adix-1]),
                    .b  (pp[1][1]), //(pp[adiy][adix-1]),
                    .s  (ads[2]),
                    .c  (acc[2])
    );

    assign ads[`P_WIDTH-1] = acc[`X_WIDTH];	// MSB output

    // So this but become easy to see the product
    assign p = ads;

endmodule
