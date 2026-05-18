module mux2x1(
    input [7:0] i0, 
    input [7:0] i1,
    input s,
    output [7:0] y
);

    assign y = s ? i1 : i0;

endmodule