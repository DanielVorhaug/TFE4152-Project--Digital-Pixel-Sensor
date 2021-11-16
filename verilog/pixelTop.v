

module PIXEL_TOP (
    input  logic SYSTEM_CLK,
    input  logic SYSTEM_RESET,
    output logic DATA_OUT_CLK,
    output logic [OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH-1:0] DATA_OUT
);
    parameter WIDTH = 2;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 8;

    logic power_enable;
    logic write_enable;
    logic counter_reset;
    logic counter_clock;
    real  analog_ramp;
    logic reset;
    logic erase;
    logic expose;
    logic read_reset;
    logic read_clk_in;
    logic vbn1;

    PIXEL_STATE_MACHINE #(
            .WIDTH(WIDTH),
            .HEIGHT(HEIGHT),
            .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH),
            .BIT_DEPTH(BIT_DEPTH)) 
        pstate(
            .SYSTEM_CLK (SYSTEM_CLK),
            .SYSTEM_RESET (SYSTEM_RESET),
            .POWER_ENABLE (power_enable),
            .WRITE_ENABLE (write_enable),
            .COUNTER_RESET (counter_reset),
            .COUNTER_CLOCK (counter_clock),
            .ANALOG_RAMP (analog_ramp),
            .RESET (reset),                     // Reset voltage in paper
            .ERASE (erase),                     // Pixel reset in paper
            .EXPOSE (expose),                   // PG in paper
            .READ_RESET (read_reset),
            .READ_CLK_IN (read_clk_in),
            .VBN1 (vbn1)                        // ana_bias1
    );

    PIXEL_ARRAY #(
            .WIDTH(WIDTH),
            .HEIGHT(HEIGHT), 
            .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH), 
            .BIT_DEPTH(BIT_DEPTH)) 
        pa1(
            .POWER_ENABLE (power_enable),
            .WRITE_ENABLE (write_enable),
            .COUNTER_RESET (counter_reset),
            .COUNTER_CLOCK (counter_clock),
            .ANALOG_RAMP (counter_clock),
            .RESET (reset),
            .ERASE (erase),
            .EXPOSE (expose),
            .SYSTEM_CLK (SYSTEM_CLK),
            .READ_RESET (read_reset),
            .READ_CLK_IN (read_clk_in),
            .VBN1 (vbn1),
            .DATA_OUT_CLK (DATA_OUT_CLK),
            .DATA_OUT (DATA_OUT)        
    );

endmodule
