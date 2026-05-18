module mux4x1(
    input [7:0] i0, 
    input [7:0] i1, 
    input [7:0] i2, 
    input [7:0] i3, 
    input s0, 
    input s1,
    output [7:0] y
);

    assign y = (s1 ? (s0 ? i3 : i2) : (s0 ? i1 : i0));

endmodule