`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2026 21:39:32
// Design Name: 
// Module Name: accumulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module accumulator(
    input clk, 
    input acc_en, 
    input reset,
    input [7:0] acc_in,
    output reg [7:0] acc_out
);

    always @(posedge clk) begin
        if (reset) acc_out <= 8'd0;
        else if (acc_en) acc_out <= acc_in;
    end

endmodule