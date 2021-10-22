module PIXEL_ARRAY_BUS (
    input logic [WIDTH*8-1:0] DATA,
    input logic READ_CLK,
    //input logic WRITE_CLK,
    output logic [WIDTH*OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH-1:0] OUT
);

parameter integer BIT_DEPTH = 8;
parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2;
parameter integer WIDTH = 2;
//integer n = 0;
logic [WIDTH*8-1:0] buffer = '0;

always_ff @(posedge READ_CLK) begin
    buffer <= DATA;
end

/*always_ff @(posedge WRITE_CLK) begin //Potential code for sequential read
    OUT = buffer[16*n - 1: 16*(n-1)];
    n++;
    if (2n==WIDTH) n = 0;
end*/ 

always_comb begin
    OUT = buffer;
end

endmodule