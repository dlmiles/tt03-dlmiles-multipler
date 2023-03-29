`default_nettype none
`timescale 1ns/1ps

`include "global.vh"
`include "config.vh"

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb_negedge (
    // testbench is controlled by test.py
    input		clk,
    input	[6:0]	in7,

    output	[7:0]	out8
);

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb_negedge.vcd");
        $dumpvars (0, tb_negedge);
        #1;
    end

    // wire up the inputs and outputs
    wire [`INPUT_WIDTH-1:0] inputs;
    assign inputs = {in7, clk};

    wire [`OUTPUT_WIDTH-1:0] outputs;
    assign out8 = outputs;

    // instantiate the DUT

`ifdef IMPL_NEGEDGE_CARRY_LOOK_AHEAD
    top_negedge_carry_look_ahead carry_look_ahead (
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif
        .io_in  (inputs),
        .io_out (outputs)
    );
`endif

`ifdef IMPL_MULU_M7Q7
    top_mulu_m7q7 multiplier_unsigned_m7q7 (
`ifdef GL_TEST
        .vccd1( 1'b1),
        .vssd1( 1'b0),
`endif
        .io_in  (inputs),
        .io_out (outputs)
    );
`endif

endmodule
