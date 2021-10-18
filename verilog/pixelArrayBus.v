module PIXEL_ARRAY_BUS (
    input logic [WIDTH*BIT_DEPTH-1:0] DATA,
    input logic READ_CLK,
    input logic WRITE_CLK,
    output logic [output_bus_width-1:0] OUT
);

parameter integer WIDTH = 2;
parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2;
parameter integer BIT_DEPTH = 8;
integer output_bus_width = OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH;

integer n = 0;

logic [WIDTH*8-1:0] buffer = '0;

always_ff @(posedge READ_CLK) begin
    buffer <= DATA;
end

always_ff @(posedge WRITE_CLK) begin //Potential code for sequential read
    OUT = buffer[output_bus_width*n - 1: output_bus_width*(n-1)];
    n++;
    if (OUTPUT_BUS_PIXEL_WIDTH*n==WIDTH) n = 0;
end 

// always_comb begin
//     OUT = buffer;
// end

endmodule