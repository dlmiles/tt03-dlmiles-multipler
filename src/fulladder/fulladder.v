//
//
//
module fulladder #(
    parameter	WIDTH = 1
) (
    input	[WIDTH-1:0]	a,
    input	[WIDTH-1:0]	b,
    input			y,

    output			c,
    output	[WIDTH-1:0]	s
);

    assign {c, s} = a + b + y;

    //assign c = (a & b) | (b & y) | (a & y);
    //assign s = (a^b)^y;

endmodule
