module PIXEL_ARRAY_BUS (
    input logic [WIDTH*8-1:0] DATA,
    input logic READ_CLK,
    output logic [15:0] OUT
);

parameter integer WIDTH = 2;
logic [WIDTH*8-1:0] buffer = '0;

always_ff @(posedge READ_CLK) begin
    buffer <= DATA;
end
always_comb begin
    OUT = buffer;
end

endmodule