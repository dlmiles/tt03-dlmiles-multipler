`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb_twos #(
    parameter	WIDTH = `TWOS_WIDTH
) (
    // testbench is controlled by test.py
    input			clk,

    input	[WIDTH-1:0]	i,

    output	[WIDTH-1:0]	o
);

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_twos.vcd");
        $dumpvars (0, tb_twos);
        #1;
    end

    // instantiate the DUT
    twos #(
        .WIDTH(WIDTH)
    ) dut (
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif
        .i  (i),
        .o  (o)
    );

endmodule
