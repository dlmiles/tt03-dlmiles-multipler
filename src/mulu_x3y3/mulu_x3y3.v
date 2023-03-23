`default_nettype none

`include "global.vh"
`include "config.vh"	// mulu_x3y3.vh

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


    //////// ADDERS (3 x HALF, 3 x FULL)

    // adder-sum (alias for final output product)
    //    the LSB (PP0[0]) has special treatment
    wire [`P_WIDTH-1:0] ads;

    assign ads[0] = pp[0][0];			// LSB output (LSB of PP0 as-is)

    // adder-carry interconnects
    wire [`P_WIDTH:0] adx;			// +1

    // note we start at bit1 as LSB(bit0) has already had special treatment
//    generate //: genad
//        for(genvar adiy = 1; adiy < `Y_WIDTH; adiy++) begin : iy			// loop 1 time, from 1
//            for(genvar adix = 1; adix <= `X_WIDTH; adix++) begin : ix			// loop 2 times, from 1
////                for(genvar adip = adix + 1; adip < adix + 3; adip++) begin : ip	// vanity loop 1 time, from adix + 1
//                    // The vanity for loop exists to demonstrate the arcane limitations of verilog :)
//                    // In wanting to name my component for better schematic/netlist reading by humans
//                    //  adip represents the P (product) output bit we are working on here
//                    halfadder #(
//                        .WIDTH(1)
//                    ) ha (	// ha_$adiy_$adix_$adip => ha_iy1_ix1_ip1 ?
//                        .a  (acc[adix-1]),
//                        .b  (pp[adiy][adix-1]),
//                        .s  (ads[adix]),
//                        .c  (acc[adix])
//                    );
////                end
//            end
//        end
//    endgenerate

    // The generate : genad, above unrolls to look like this:

    halfadder #(.WIDTH(1)) ha1_iy1_ix1_ip1
    (
                    .a  (pp[0][1]), //(acc[adix-1]),
                    .b  (pp[1][0]), //(pp[adiy][adix-1]),	// 0_2
                    .s  (ads[1]),   //(ads[adix]), // P1
                    .c  (adx[0])    //(acc[adix])  // to fa3_1_2_2ci
    );
    halfadder #(.WIDTH(1)) ha2_iy1_ix2_ipX
    (
                    .a  (pp[0][2]), //(acc[adix-1]),		// 1_0
                    .b  (pp[1][1]), //(pp[adiy][adix-1]),
                    .s  (adx[1]),   //(acc[adix])  // to fa3_1_2_2a
                    .c  (adx[2])    //(acc[adix])  // to fa4_?_?_Xci
    );
    fulladder #(.WIDTH(1)) fa3_iy1_ix2_ip2
    (
                    .a  (adx[1]),   //(acc[adix-1]),  // from ha2_1_2_Xs
                    .b  (pp[2][0]), //(pp[adiy][adix-1]),		// 1_2
                    .y  (adx[0]),   //    from ha1_1_1_1c
                    .s  (ads[2]),   //(acc[adix])  // P2
                    .c  (adx[3])    //(acc[adix])  // to ha5_?_?_3b
    );
    fulladder #(.WIDTH(1)) fa4_iy1_ix2_ipX
    (
                    .a  (pp[1][2]), //(acc[adix-1]),  // from ha_1_2_Xs	// 2_0
                    .b  (pp[2][1]), //(pp[adiy][adix-1]),
                    .y  (adx[2]),   //    from ha2_1_2_Xc
                    .s  (adx[4]),   //(acc[adix])  // to ha5_?_?_?a
                    .c  (adx[5])    //(acc[adix])  // to fa6_?_?_4ci
    );
    halfadder #(.WIDTH(1)) ha5_iy1_ix2_ip3
    (
                    .a  (adx[4]),   //(acc[adix-1]), // from fa4_1_2_Xs
                    .b  (adx[3]),   //(pp[adiy][adix-1]), // from fa3_1_2_2co
                    .s  (ads[3]),   //(acc[adix])  // P3
                    .c  (adx[6])    //(acc[adix])  // to fa6_1_2_4b
    );
    fulladder #(.WIDTH(1)) fa6_iy1_ix2_ip4
    (
                    .a  (pp[2][2]), //(acc[adix-1]),
                    .b  (adx[6]),   //(pp[adiy][adix-1]),  // from ha5_1_2_Xc
                    .y  (adx[5]),   //    from fa4_1_2_Xco
                    .s  (ads[4]),   //(acc[adix])  // P4
                    .c  (ads[5])    //(acc[adix])  // P5 MSB output
    );

    // So this but become easy to see the product
    assign p = ads;

endmodule
