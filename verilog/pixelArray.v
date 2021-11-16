

module PIXEL_ARRAY(
    input logic POWER_ENABLE,
    input logic WRITE_ENABLE,
    input logic COUNTER_RESET,
    input logic COUNTER_CLOCK,
    input real  ANALOG_RAMP,
    input logic RESET,       // Reset voltage in paper
    input logic ERASE,       // Pixel reset in paper
    input logic EXPOSE,      // PG in paper
    input logic SYSTEM_CLK,
    input logic READ_RESET,
    input logic READ_CLK_IN,
    input logic VBN1,

    output logic DATA_OUT_CLK,
    output logic [OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH-1:0] DATA_OUT

);
    parameter WIDTH = 2;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 8;
    parameter dv_pixel = 0.5;

    wire [BIT_DEPTH*WIDTH - 1:0] data;
    logic [BIT_DEPTH - 1:0] counter;
    logic read_clk_out;
    logic [$clog2(HEIGHT):0] memory_row;
    logic memory_read_enable;
    logic [HEIGHT-1: 0] row_select;

    PIXEL_ARRAY_COUNTER #(
            .BIT_DEPTH(BIT_DEPTH))
        pac1(
            .COUNTER_RESET(COUNTER_RESET),
            .COUNTER_CLOCK(COUNTER_CLOCK),
            .DATA(counter) 
    );

    genvar i;
    generate
       for (i = 0; i < WIDTH; i = i + 1) begin
           assign data[BIT_DEPTH*(i+1) - 1:BIT_DEPTH*i] = WRITE_ENABLE ? counter : 'Z;
       end 
    endgenerate

    PIXEL_ARRAY_MEMORY_CONTROLLER #(
            .HEIGHT(HEIGHT),
            .WIDTH(WIDTH), 
            .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH)) 
        pamc1(
            .SYSTEM_CLK(SYSTEM_CLK),
            .READ_RESET(READ_RESET),
            .READ_CLK_IN(READ_CLK_IN),
            .READ_CLK_OUT(read_clk_out),
            .WRITE_CLK_OUT(DATA_OUT_CLK),
            .MEMORY_ROW(memory_row),
            .MEMORY_READ_ENABLE(memory_read_enable)
    );

    PIXEL_ARRAY_READ_POINTER #(
            .HEIGHT(HEIGHT)) 
        parp1 (
            .CONTROL(memory_row),
            .ENABLE(memory_read_enable),
            .ROW_SELECT(row_select)
    );

    PIXEL_ARRAY_BUS #(
            .BIT_DEPTH(BIT_DEPTH),
            .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH),
            .WIDTH(WIDTH)) 
        pab1(
            .DATA(data),
            .READ_CLK(read_clk_out),
            .OUT(DATA_OUT),
            .WRITE_CLK(DATA_OUT_CLK)
    );


        // Pixels
    genvar column;
    genvar row;
    generate
        for(column = 0; column < WIDTH; column = column + 1)begin
            for(row = 0; row < HEIGHT; row = row + 1)begin
                PIXEL_SENSOR #(
                        .BIT_DEPTH(BIT_DEPTH),
                        .dv_pixel(dv_pixel)) 
                    ps(
                        .VBN1(VBN1),
                        .RAMP(ANALOG_RAMP),
                        .RESET(RESET),          // Reset voltage in paper
                        .ERASE(ERASE),          // Pixel reset in paper
                        .EXPOSE(EXPOSE),        // PG in paper
                        .READ(row_select[row]), // Read in paper
                        .DATA(data[BIT_DEPTH*(column+1)-1:BIT_DEPTH*(column)])
                );
            end
        end
    endgenerate

endmodule
