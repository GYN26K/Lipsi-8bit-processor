`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2026 21:38:46
// Design Name: 
// Module Name: lipsi_processor
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


module cpu(
    input clk, 
    input reset,
    output [7:0] acc
);

    wire [3:0] state;
    wire [3:0] next_state;
    wire [3:0] alu_ctrl;
    wire [7:0] rd_data;
    wire [7:0] acc_in;
    wire [3:0] alu_ctrl_store;
    wire [1:0] mux_pc_rd;
    wire [7:0] rd_addr;
    wire [7:0] wr_addr;
    wire [7:0] wr_data;
    wire [7:0] pc_in;
    wire [7:0] pc_out;
    wire [7:0] pc_plus_1;
    wire [7:0] acc_out;
    
    assign acc = acc_out;

    wire fetch;
    wire small_addr;
    wire mux_wr_addr;
    
    assign wr_en = mux_wr_addr;

    memory m1(
        .clk(clk),
        .N(N), 
        .wr_en(wr_en), 
        .fetch(fetch | reset), 
        .reset(reset),
        .rd_addr(pc_in), 
        .wr_addr(wr_addr), 
        .wr_data(wr_data),
        .rd_data(rd_data), 
        .small_addr(small_addr) 
    );

    mux2x1 mux1(
        .i0(8'd0), 
        .i1(rd_data), 
        .y(wr_addr), 
        .s(mux_wr_addr)
    );

    mux2x1 mux2(
        .i0(acc_out), 
        .i1(pc_out), 
        .y(wr_data), 
        .s(mux_wr_data)
    );

    mux4x1 mux3(
        .i0(pc_plus_1), 
        .i1(acc_out), 
        .i2(rd_data), 
        .i3(8'd0),
        .y(pc_in), 
        .s1(mux_pc_rd[1] | reset), 
        .s0(mux_pc_rd[0] | reset)
    );

    pc p1(
        .clk(clk), 
        .pc_en(pc_en), 
        .reset(reset), 
        .pc_in(pc_in), 
        .pc_out(pc_out)
    );

    add_1 a1(
        .pc_out(pc_out), 
        .pc_plus_1(pc_plus_1)
    );

    accumulator acc1(
        .clk(clk),
        .reset(reset), 
        .acc_en(acc_en), 
        .acc_in(acc_in), 
        .acc_out(acc_out)
    );

    alu alu1(
        .acc_out(acc_out), 
        .rd_data(rd_data), 
        .alu_ctrl(alu_ctrl),
        .acc_in(acc_in)
    );

    ctrl_unit c1(
        .clk(clk), 
        .instruction(rd_data), 
        .alu_ctrl_store(alu_ctrl), 
        .pc_en(pc_en), 
        .reset(reset),
        .acc_en(acc_en), 
        .mux_pc_rd(mux_pc_rd), 
        .wr_addr(mux_wr_addr),
        .wr_data(mux_wr_data),
        .A(acc_out), 
        .fetch(fetch), 
        .small_addr(small_addr),
        .state(state), 
        .next_state(next_state)
    );

endmodule