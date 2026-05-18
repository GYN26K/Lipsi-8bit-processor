`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2026 23:50:58
// Design Name: 
// Module Name: main_file
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


`timescale 1ns / 1ps

module main_module(
    input clk,
    input reset,
    output [6:0] seg,
    output [3:0] an
);

    wire slowclk;
    wire [31:0] result;

    wire [3:0] ones;
    wire [3:0] tens;
    wire [3:0] hundreds;
    wire [3:0] thousands;

    clk_div divider(
        .clk(clk),
        .rst(reset),
        .clk1(slowclk)
    );

    cpu cpu(
        .clk(slowclk),
        .reset(reset),
        .acc(result)
    );

    bin_to_bcd convert(
        .bin(result),
        .ones(ones),
        .tens(tens),
        .hundreds(hundreds),
        .thousands(thousands)
    );

    display_mux display(
        .clk(clk),
        .d0(ones),
        .d1(tens),
        .d2(hundreds),
        .d3(thousands),
        .an(an),
        .seg(seg)
    );

endmodule
// Sum of n numbers
//        mem[9'd0] <= {4'b0,N}; // r0
//        mem[9'd1] <= {4'b0,N}; // r1
//        mem[9'd2] <= 8'd1; // r2
//        for (i = 3; i < 256; i = i + 1) mem[i] <= 8'd0;
        
//        mem[9'd256] <= 8'h71; // load r1 to A
//        mem[9'd257] <= 8'h12; // A = A - r2
//        mem[9'd258] <= 8'h81; // store A in r1
//        mem[9'd259] <= 8'hd2; // branch if A is 0
//        mem[9'd260] <= 8'h09; // branch address
//        mem[9'd261] <= 8'h00; // add A = A + r0
//        mem[9'd262] <= 8'h80; // store A in r0
//        mem[9'd263] <= 8'hd0; // branch
//        mem[9'd264] <= 8'h00; // branch address
//        mem[9'd265] <= 8'h70; // load r0 in A
//        mem[9'd266] <= 8'hff; // exit   
//        rd_data <= mem[9'd256];  