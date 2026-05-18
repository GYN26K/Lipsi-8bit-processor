module memory(
    input clk, 
    input wr_en, 
    input fetch, 
    input small_addr, 
    input reset,
    input [3:0] N, 
    input [7:0] rd_addr,
    input [7:0] wr_addr, 
    input [7:0] wr_data,
    output reg [7:0] rd_data
);

integer i;
reg [7:0] mem [511:0];

always @(posedge clk) begin
    if (reset) begin
    // fibonacci
        mem[9'd0] <= 8'b0; // r0
        mem[9'd1] <= 8'b1; // r1
        mem[9'd2] <= 8'b0; // r2 initialise to 0
        mem[9'd3] <= {4'b0,N}; // r3
        mem[9'd4] <= 8'b1 ; // r4 = 1
        for (i = 5; i < 256; i = i + 1) mem[i] <= 8'd0;

        mem[9'd256] <= 8'h70; // load r0 in A
        mem[9'd257] <= 8'h01; // A = A + r1
        mem[9'd258] <= 8'h82; // store A in r2
        mem[9'd259] <= 8'h71; // load r1 in A
        mem[9'd260] <= 8'h80; // store A in r0
        mem[9'd261] <= 8'h72; // load r2 in A
        mem[9'd262] <= 8'h81; // store A in r1
        mem[9'd263] <= 8'h73; // load r3 in A
        mem[9'd264] <= 8'h14; // sub A - r4 = A - 1
        mem[9'd265] <= 8'h83; // store A in r3
        mem[9'd266] <= 8'hd2; // branch if A is 0
        mem[9'd267] <= 8'h0e; // branch address
        mem[9'd268] <= 8'hd3; // branch if A is not 0
        mem[9'd269] <= 8'h00; // to address 256
        mem[9'd270] <= 8'h72; // load r2 to A as it has final value 
        mem[9'd271] <= 8'hff; // exit
    
//        On reset, read first instruction
        rd_data <= mem[9'd256];
        
    end 
    
    else begin
        if (fetch) begin
            // Instruction fetch from instruction memory
            rd_data <= mem[{fetch, rd_addr}];
        end else if (small_addr == 1) begin
            if (wr_en) begin
                mem[{fetch, 4'b0000, wr_addr[3:0]}] <= wr_data;
            end else begin
                rd_data <= mem[{fetch, 4'b0000, rd_addr[3:0]}];
            end
        end else begin
            if (wr_en) begin
                mem[{fetch, wr_addr}] <= wr_data;
            end else begin
                rd_data <= mem[{fetch, rd_addr}];
            end
        end
    end
end

endmodule