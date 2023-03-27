`default_nettype none

`include "global.vh"
`include "config.vh"    // mulu_m2q2.vh

// Unsigned Multipler, X width 2, Y width 2, making P result width 4
module mulu_m2q2 (
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
        for (ppiy = 0; ppiy < `Y_WIDTH; ppiy = ppiy + 1) begin		// loop 2 times, from 0
            // If X_WIDTH == Y_WIDTH then this for loop below means:
            // pp[iy][`X_WIDTH-1:0] = x[`X_WIDTH-1:0] & {`X_WIDTH{y[ppiy]}}
            for(ppix = 0; ppix < `X_WIDTH; ppix = ppix + 1) begin	// loop 2 times, from 0
                assign pp[ppiy][ppix] = x[ppix] & y[ppiy];
            end
        end
    endgenerate


    //////// HALF ADDERS

    // adder-sum (alias for final output product)
    //    the LSB (PP0[0]) and MSB (last carry-out) have special treatment
    wire [`P_WIDTH-1:0] ads;

    assign ads[0] = pp[0][0];			// LSB output (LSB of PP0 as-is)

    // adder-carry chain
    wire [`X_WIDTH:0] acc;			// +1

    // we set this up in preparation for the generate block to cascade
    assign acc[0] = pp[0][1];	// adder-carry maybe this should be external for cascade when supported ?

    // note we start at bit1 as LSB(bit0) has already had special treatment
    generate //: genad
        for(genvar adiy = 1; adiy < `Y_WIDTH; adiy++) begin : iy			// loop 1 time, from 1
            for(genvar adix = 1; adix <= `X_WIDTH; adix++) begin : ix			// loop 2 times, from 1
//                for(genvar adip = adix + 1; adip < adix + 3; adip++) begin : ip	// vanity loop 1 time, from adix + 1
                    // The vanity for loop exists to demonstrate the arcane limitations of verilog :)
                    // In wanting to name my component for better schematic/netlist reading by humans
                    //  adip represents the P (product) output bit we are working on here
                    halfadder #(
                        .WIDTH(1)
                    ) ha (	// ha_$adiy_$adix_$adip => ha_iy1_ix1_ip1 ?
                        .a  (acc[adix-1]),
                        .b  (pp[adiy][adix-1]),
                        .s  (ads[adix]),
                        .c  (acc[adix])
                    );
//                end
            end
        end
    endgenerate

    // The generate : genad, above unrolls to look like this:

    // halfadder #(.WIDTH(1)) ha_iy1_ix1_ip1
    // (
    //                 .a  (acc[0]),   //(acc[adix-1]),
    //                 .b  (pp[1][0]), //(pp[adiy][adix-1]),
    //                 .s  (ads[1]),   //(ads[adix]),
    //                 .c  (acc[1])    //(acc[adix])
    // );
    // halfadder #(.WIDTH(1)) ha_iy1_ix2_ip2
    // (
    //                 .a  (acc[1]),   //(acc[adix-1]),
    //                 .b  (pp[1][1]), //(pp[adiy][adix-1]),
    //                 .s  (ads[2]),   //(acc[adix])
    //                 .c  (acc[2])    //(acc[adix])
    // );

    assign ads[`P_WIDTH-1] = acc[`X_WIDTH];	// MSB output

    // So this but become easy to see the product
    assign p = ads;

endmodule
