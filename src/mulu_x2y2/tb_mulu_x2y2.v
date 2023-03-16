`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"    // mulu_x2y2.vh

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb_mulu_x2y2 (
    // testbench is controlled by test.py
    input clk,
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
        $dumpfile ("tb_mulu_x2y2.vcd");
        $dumpvars (0, tb_mulu_x2y2);
        #1;
    end

    // instantiate the DUT
    mulu_x2y2 multipler_unsigned_x2y2 (
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif
        .x   (x),
        .y   (y),
        .p   (p)
`ifdef HAS_SIGN
        , .s   (s)
`endif
`ifdef HAS_READY
        , .rdy (rdy)
`endif
    );

endmodule
