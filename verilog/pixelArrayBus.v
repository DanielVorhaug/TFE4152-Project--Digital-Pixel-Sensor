module PIXEL_ARRAY_BUS (
    input   logic [WIDTH*BIT_DEPTH-1:0] DATA,
    input   logic READ_CLK,
    input   logic WRITE_CLK,
    output  logic [OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH-1:0] OUT
);

parameter integer BIT_DEPTH = 8;
parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2;
parameter integer WIDTH = 2;
logic [WIDTH*BIT_DEPTH-1:0] buffer = '0;

always_ff @(posedge READ_CLK) begin
    buffer <= DATA;
end

always_ff @(posedge WRITE_CLK) begin
    OUT <= buffer[BIT_DEPTH*OUTPUT_BUS_PIXEL_WIDTH-1: 0];
end

genvar i;
generate for(i = 0; i < WIDTH/OUTPUT_BUS_PIXEL_WIDTH-1; i++) begin
        always_ff @(posedge WRITE_CLK) begin
            buffer[BIT_DEPTH*OUTPUT_BUS_PIXEL_WIDTH*(i+1)-1:BIT_DEPTH*OUTPUT_BUS_PIXEL_WIDTH*i] <= buffer[BIT_DEPTH*OUTPUT_BUS_PIXEL_WIDTH*(i+2)-1:BIT_DEPTH*OUTPUT_BUS_PIXEL_WIDTH*(i+1)];
        end
    end
endgenerate

always_ff @(posedge WRITE_CLK) begin
    buffer[WIDTH*BIT_DEPTH-1:WIDTH*BIT_DEPTH-OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH] <= '0;
end

endmodule
