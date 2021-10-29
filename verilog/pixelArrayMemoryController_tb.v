`timescale 1 ns / 1 ps

module PIXEL_ARRAY_MEMORY_CONTROLLER_tb ();


    logic SYSTEM_CLK = 0;
    logic READ_RESET = 0;
    logic READ_CLK_IN = 0;
    logic READ_CLK_OUT;
    logic WRITE_CLK_OUT;
    logic [$clog2(HEIGHT):0] MEMORY_ROW;
    logic MEMORY_READ_ENABLE;

    parameter integer WIDTH = 8;
    parameter integer HEIGHT = 9;
    parameter integer OUTPUT_BUS_PIXEL_WIDTH = 4; 

    parameter integer clk_period = 500;
    parameter integer sim_period = clk_period*2400;
    always #clk_period SYSTEM_CLK=~SYSTEM_CLK;

    

    PIXEL_ARRAY_MEMORY_CONTROLLER #(.HEIGHT(HEIGHT), .WIDTH(WIDTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH)) pamc1(
        .SYSTEM_CLK(SYSTEM_CLK),
        .READ_RESET(READ_RESET),
        .READ_CLK_IN(READ_CLK_IN),
        .READ_CLK_OUT(READ_CLK_OUT),
        .WRITE_CLK_OUT(WRITE_CLK_OUT),
        .MEMORY_ROW(MEMORY_ROW),
        .MEMORY_READ_ENABLE(MEMORY_READ_ENABLE)
    );



    initial
        begin


            $dumpfile("simulation/PIXEL_ARRAY_MEMORY_CONTROLLER_tb.vcd");
            $dumpvars(0,PIXEL_ARRAY_MEMORY_CONTROLLER_tb);

            #sim_period

            READ_CLK_IN = 1;
            #clk_period
            READ_CLK_IN = 0;

            #sim_period
                $stop;

        end
endmodule