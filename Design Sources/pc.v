module pc(
    input clk,
    input pc_en,
    input reset,
    input [7:0] pc_in,
    output reg [7:0] pc_out
);

always @(posedge clk) begin
    if (reset)
        pc_out <= 8'd0;
    else if (pc_en)
        pc_out <= pc_in;
end

endmodule