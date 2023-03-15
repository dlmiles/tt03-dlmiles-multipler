`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "mulu_x2y2.vh"

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input clk,
    input rst,
    input [`X_WIDTH-1:0] x,
    input [`Y_WIDTH-1:0] y,

    output [`P_WIDTH-1:0] p
`ifdef HAS_SIGN
    , output s
`endif
`ifdef HAS_READY
    , output rdy
`endif
);

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    wire [`INPUT_WIDTH-1:0] inputs = {2'b0, {y}, {x}, rst, clk};
    wire [`OUTPUT_WIDTH-1:0] outputs;
    assign p = outputs[`O_P_BITID+`P_WIDTH-1:`O_P_BITID];	// 3:0
`ifdef HAS_SIGN
    //assert((`O_P_BITID+`P_WIDTH-1) < `O_SIGN_BITID);	// !iverilog
    assign s = outputs[`O_SIGN_BITID];				// 6
`endif
`ifdef HAS_READY
    //assert((`O_P_BITID+`P_WIDTH-1) < `O_READY_BITID);	// !iverilog
    assign rdy = outputs[`O_READY_BITID];			// 7
`endif

`ifdef IMPL_MULS_X3XY
    // instantiate the DUT
    muls_x3y3 multipler_signed_x3y3(
        `ifdef GL_TEST
            .vccd1( 1'b1),
            .vssd1( 1'b0),
        `endif
        .io_in  (inputs),
        .io_out (outputs)
    );
`endif
    top_mulu_x2y2 top_mulu_x2y2 (
        `ifdef GL_TEST
            .vccd1( 1'b1),
            .vssd1( 1'b0),
        `endif
        .io_in  (inputs),
        .io_out (outputs)
    );

endmodule
