
wire clk;
assign clk = io_in[0];

reg [6:0] my_reg_neg;
wire [15:0] outtmp;

always @(negedge clk) begin
  my_reg_neg <= io_in[7:1];
end

mux_clk_edge_out(clk, io_out[7:0], outtmp[15:8], outtmp[7:0]);

always @(posedge clk) begin  // prolly don't need always block here anymore but in do_work_module
  do_work_module (
    .clk     (clk),
    .data_a  (io_in[7:1]),
    .data_b  (my_reg_neg[6:0]),
    .data_out(outtmp[15:0])  // maybe .data_out[15:8] needs to be registered, while the other half not ?
  );
end
