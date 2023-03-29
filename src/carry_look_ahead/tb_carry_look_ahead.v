`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb_carry_look_ahead #(
    parameter	WIDTH = 3
) (
    // testbench is controlled by test.py
    input			clk,

    input	[WIDTH-1:0]	a,
    input	[WIDTH-1:0]	b,
    input			y,

    output			c,
    output	[WIDTH-1:0]	s
);

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_carry_look_ahead.vcd");
        $dumpvars (0, tb_carry_look_ahead);
        #1;
    end

    // instantiate the DUT
    carry_look_ahead #(
        .WIDTH(WIDTH)
    ) dut (
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif
        .a  (a),
        .b  (b),
        .y  (y),
        .c  (c),
        .s  (s)
    );

endmodule
