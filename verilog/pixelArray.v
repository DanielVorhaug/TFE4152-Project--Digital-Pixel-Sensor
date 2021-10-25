

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

    //inout wire [7:0] DATA,    //Will have to expand this to account for more pixels
    output logic [WIDTH*OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH-1:0] DATA_OUT

);
    parameter WIDTH = 2;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 8;

    wire [BIT_DEPTH*WIDTH - 1:0] data;
    logic [BIT_DEPTH - 1:0] counter;// = '0;
    logic read_clk_out;
    logic write_clk_out;
    logic [$clog2(HEIGHT):0] memory_row;
    logic memory_read_enable;
    logic [HEIGHT-1: 0] row_select;

    PIXEL_ARRAY_COUNTER #(.BIT_DEPTH(BIT_DEPTH)) pac1(
        .COUNTER_RESET (COUNTER_RESET),
        .COUNTER_CLOCK (COUNTER_CLOCK),
        .DATA (counter) );

    assign data[7:0] = (WRITE_ENABLE) ? counter : 'Z;
    assign data[15:8] = (WRITE_ENABLE) ? counter : 'Z;

    PIXEL_ARRAY_MEMORY_CONTROLLER #(.HEIGHT(HEIGHT), .WIDTH(WIDTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH)) pamc1(
        .SYSTEM_CLK(SYSTEM_CLK),
        .READ_RESET(READ_RESET),
        .READ_CLK_IN(READ_CLK_IN),
        .READ_CLK_OUT(read_clk_out),
        .WRITE_CLK_OUT(write_clk_out),
        .MEMORY_ROW(memory_row),
        .MEMORY_READ_ENABLE(memory_read_enable)
    );

    PIXEL_ARRAY_READ_POINTER #(.HEIGHT(HEIGHT)) parp1 (
        .CONTROL(memory_row),
        .ENABLE(memory_read_enable),
        .ROW_SELECT(row_select)
    );

    PIXEL_ARRAY_BUS #(.BIT_DEPTH(BIT_DEPTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH)) pab1(
        .DATA(data),
        .READ_CLK(read_clk_out),
        .OUT(DATA_OUT)
    );

    PIXEL_SENSOR #(.BIT_DEPTH(BIT_DEPTH)) ps1 (
        .VBN1(VBN1),
        .RAMP(ANALOG_RAMP),
        .RESET(RESET),       // Reset voltage in paper
        .ERASE(ERASE),       // Pixel reset in paper
        .EXPOSE(EXPOSE),      // PG in paper
        .READ(row_select[0]),        // Read in paper
        .DATA(data[7:0])
    );
    PIXEL_SENSOR #(.BIT_DEPTH(BIT_DEPTH)) ps2 (
        .VBN1(VBN1),
        .RAMP(ANALOG_RAMP),
        .RESET(RESET),       // Reset voltage in paper
        .ERASE(ERASE),       // Pixel reset in paper
        .EXPOSE(EXPOSE),      // PG in paper
        .READ(row_select[0]),        // Read in paper
        .DATA(data[15:8])
    );
    PIXEL_SENSOR #(.BIT_DEPTH(BIT_DEPTH)) ps3 (
        .VBN1(VBN1),
        .RAMP(ANALOG_RAMP),
        .RESET(RESET),       // Reset voltage in paper
        .ERASE(ERASE),       // Pixel reset in paper
        .EXPOSE(EXPOSE),      // PG in paper
        .READ(row_select[1]),        // Read in paper
        .DATA(data[7:0])
    );
    PIXEL_SENSOR #(.BIT_DEPTH(BIT_DEPTH)) ps4 (
        .VBN1(VBN1),
        .RAMP(ANALOG_RAMP),
        .RESET(RESET),       // Reset voltage in paper
        .ERASE(ERASE),       // Pixel reset in paper
        .EXPOSE(EXPOSE),      // PG in paper
        .READ(row_select[1]),        // Read in paper
        .DATA(data[15:8])
    );

    // PIXEL_SENSOR #() [HEIGHT-1:0]ps[WIDTH-1:0] (
    //     input logic      VBN1,
    //     .RAMP(ANALOG_RAMP),
    //     .RESET(RESET),       // Reset voltage in paper
    //     .ERASE(ERASE),       // Pixel reset in paper
    //     .EXPOSE(EXPOSE),      // PG in paper
    //     .READ(),        // Read in paper
    //     inout [7:0] DATA
    // );
    // genvar h, w;
    // generate
    //     for (h = 0; h < HEIGHT; h++)begin
    //         for(w = 0; w < WIDTH; w++)begin
    //             PIXEL_SENSOR #() ps
    //         end
    //     end 
    // endgenerate

endmodule