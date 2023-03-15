`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb_halfadder #(
    parameter WIDTH = 1
) (
    // testbench is controlled by test.py
    input clk,

    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,

    output [WIDTH-1:0] s,
    output [WIDTH-1:0] c
);

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_halfadder.vcd");
        $dumpvars (0, tb_halfadder);
        #1;
    end

    // instantiate the DUT
    halfadder #(
        .WIDTH(WIDTH)
    ) dut (
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif
        .a  (a),
        .b  (b),
        .s  (s),
        .c  (c)
    );

endmodule
