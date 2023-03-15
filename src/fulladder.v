//
//
//
module fulladder #(
    parameter WIDTH = 2
) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input ci,

    output [WIDTH-1:0] s,
    output co
);

    assign {co, s} = a + b + ci;

    //assign s = (a^b)^ci;
    //assign co = (a & b) | (b & ci) | (a & ci);

endmodule
