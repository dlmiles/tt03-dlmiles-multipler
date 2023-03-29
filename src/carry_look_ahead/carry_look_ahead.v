`default_nettype none
`timescale 1ns/1ps

// Comment me out for the generator method below
//`define USE_SYNTH_METHOD 1

//
//  The purpose of this is to achieve the same results as a ripple carry adder
//   by trading gate count (increase) to gain a lower propagaton delay.
//  This is especially useful when the WIDTH increases.
//
module carry_look_ahead #(
    // Carry Look Ahead
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

    wire [WIDTH-1+1:0] carry;	// +2 due to generate use (carry-in and carry-out)
    wire [WIDTH-1:0] p;
    wire [WIDTH-1:0] g;

    assign carry[0] = y;	// C0: carry-in

    genvar gena;
    genvar geno;
    genvar genp;
    genvar genpp;
    genvar genc;
    generate //: gencarry
        for (genc = 0; genc < WIDTH; genc = genc + 1) begin			// loop WIDTH times, from 0 (carry bit position)

            //assign {carry[genc], s[genc]} = a[genc] + b[genc] + carry[genc];
            
            // This looks like a half adder to me
            assign g[genc] = a[genc] & b[genc];		// HA: carry
            assign p[genc] = a[genc] ^ b[genc];		// HA: sum

            wire [genc+1:0] otmp;		// or
            wire [genc+1:0] atmp [genc+2:0];	// and
            wire [genc+1] ares;			// N-input AND result (each AND_RES below)

            //      OR_TERM3 +         OR_TERM2 +    OR_TERM1 +       OR_TERM0
            //      AND_RES3           AND_RES2      AND_RES1         AND_RES0
            // C0 = Carry-In (from module port 'y')
            // C1 =       G0 +                                           P0 C0
            // C2 =       G1 +                          P1 G0 +       P1 P0 C0
            // C3 =       G2 +            P2 G1 +    P2 P1 G0 +    P2 P1 P0 C0
            // C4 =       G3 + P3 G2 + P3 P2 G1 + P3 P2 P1 G0 + P3 P2 P1 P0 C0 (carry-out)

            // 0-th index has C0 our P and all the others upto us
            // AND_RES0: C0
            assign atmp[0][0] = carry[0];
            for (genp = 0; genp <= genc; genp = genp + 1) begin		// loop 0..genc+1 (at least once) times, from 0
                // AND_RES0: P0 P1 P2 P3
                assign atmp[0][genp+1] = p[genp];
            end
            // AND_RES0 = C0 P0 P1 P2 P3
            assign ares[0] = &atmp[0][genc+1:0];		// N-input AND: partial bus, reduction operator

            // N-th index has G[prev] + P[next] P[next+1] ...
            for (genp = 1; genp <= genc; genp = genp + 1) begin	// loop 0 times on first, from 1 (2nd onwards AND term)
                // AND_RES1: G0
                assign atmp[genp][0] = g[genp-1];
                // genc=2 genp=1 .. genpp 2 1    => P1 P2
                // genc=2 genp=2 .. genpp 2      => P2
                // genc=3 genp=1 .. genpp 3 2 1  => P1 P2 P3
                // genc=3 genp=2 .. genpp 3 2    => P2 P3
                // genc=3 genp=3 .. genpp 3      => P3
                for (genpp = genc; genpp >= genp; genpp = genpp - 1) begin	// loop genc..0 times, from genc DECREMENT (P term)
                    // AND_RES1: P1 P2 P3
                    // genc-genpp: provides 0-based counter going up per iteration
                    assign atmp[genp][genc-genpp+1] = p[genc-genpp+genp];	// genc-genpp+1: accounts for decrementing loop, but bus must build from 0 up
                end
                // genc-genp+1 provides the correct count of inputs
                // AND_RES1 = G0 P1 P2 P3
                assign ares[genp] = &atmp[genp][genc-genp+1:0];	// N-input AND: partial bus, reduction operator
            end

            assign otmp[0] = g[genc];
            for (geno = 0; geno <= genc; geno = geno + 1) begin			// loop 0..genc+1 (at least once) times, from 0
                // verilog notation for 'apply this binary operatiion to all bits of the bus as inputs'
                // reduction operators
                assign otmp[geno+1] = &ares[geno];		// N-input AND result
            end

            // verilog notation for 'apply this binary operatiion to all bits of the bus as inputs'
            // reduction operators
            assign carry[genc+1] = |otmp[genc+1:0];	// N-input OR, partial bus, reduction operator

//            assign carry[genc+1] = (a[genc] & b[genc]) | (b[genc] & carry[genc]) | (a[genc] & carry[genc]);
//            assign s[genc] = (a[genc]^b[genc])^carry[genc];

            assign s[genc] = carry[genc] ^ p[genc];
       end
    endgenerate

    assign c = carry[WIDTH];	// carry-out

`endif

endmodule
