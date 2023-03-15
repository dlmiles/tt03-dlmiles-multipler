`default_nettype none

// This exists a a top level module for production wiring the ports up
module top_mulu_x2y2 #(
    parameter NOOP = 0
) (
    input [7:0] io_in,
    output [7:0] io_out
);

    wire clk = io_in[0];
    wire reset = io_in[1];
    wire [1:0] x = io_in[3:2];
    wire [1:0] y = io_in[5:4];

    wire [3:0] p;
    assign io_out[3:0] = p;
`ifdef HAS_SIGN
    wire s;
    assign io_out[6] = s;
`endif
`ifdef HAS_READY
    wire rdy;
    assign io_out[7] = rdy;
`endif

    mulu_x2y2 mulu_x2y2(
      .x  (x),
      .y  (y),
      .p  (p)
`ifdef HAS_SIGN
      , .s   (s)
`endif
`ifdef HAS_READY
      , .rdy (rdy)
`endif
    );

endmodule
