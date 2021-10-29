`timescale 1 ns / 1 ps

module pixelState_tb;
     // Clock
    logic system_clk = 0;
    logic system_reset = 0;
    parameter integer clk_period = 500;
    parameter integer sim_period = clk_period *10.2;
    parameter integer sim_end = clk_period*2400;
    always #clk_period system_clk=~system_clk;

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

    PIXEL_STATE_MACHINE 
        #(
            .WIDTH(WIDTH),
            .HEIGHT(HEIGHT),
            .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH),
            .BIT_DEPTH(BIT_DEPTH)
        ) 
        pstate(
            .SYSTEM_CLK (system_clk),
            .SYSTEM_RESET (system_reset),
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
    


    initial
        begin
            system_reset = 1;

            #clk_period  system_reset=0;

            $dumpfile("simulation/pixelState_tb.vcd");
            $dumpvars(0,pixelState_tb);
            
            #sim_end
                $stop;


        end

endmodule