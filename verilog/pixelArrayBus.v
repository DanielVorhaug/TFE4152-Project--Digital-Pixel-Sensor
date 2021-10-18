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

logic [$clog2(WIDTH)-1:0] n = 0; // maybe -1

logic [WIDTH*8-1:0] buffer = '0;

always_ff @(posedge READ_CLK) begin
    buffer <= DATA;
end

always_ff @(posedge WRITE_CLK) begin //Potential code for sequential read
    generate for (int i=1; i<(WIDTH/OUTPUT_BUS_PIXEL_WIDTH)+1; i=i+1) begin: 
            if (n==i) OUT <= buffer[output_bus_width * i - 1 : output_bus_width * (i-1)];
        end 
    endgenerate
    if(n==WIDTH/OUTPUT_BUS_PIXEL_WIDTH + 1) n = 1;


    // if (n==)
    // OUT <= buffer[15: 0];
    // kattepus <= kattepus+1;
    // if (OUTPUT_BUS_PIXEL_WIDTH*kattepus==WIDTH) kattepus <= 0;
end 

// always_comb begin
//     OUT = buffer;
// end

endmodule