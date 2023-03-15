`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input clk,
    input rst,
    input [1:0] x,
    input [1:0] y,

    output [3:0] p
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
    wire [7:0] inputs = {2'b0, {y}, {x}, rst, clk};
    wire [7:0] outputs;
    assign p = outputs[3:0];
`ifdef HAS_SIGN
    assign s = outputs[6];
`endif
`ifdef HAS_READY
    assign rdy = outputs[7];
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
//        `ifdef GL_TEST
//            .vccd1( 1'b1),
//            .vssd1( 1'b0),
//        `endif
        .io_in  (inputs),
        .io_out (outputs)
    );

endmodule
