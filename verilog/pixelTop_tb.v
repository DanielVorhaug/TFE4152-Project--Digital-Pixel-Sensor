`timescale 1 ns / 1 ps

module pixelTop_tb;
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

    logic data_out_clk;
    logic [WIDTH*BIT_DEPTH-1:0] data_out;

    PIXEL_TOP 
        #(
            .WIDTH(WIDTH),
            .HEIGHT(HEIGHT),
            .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH),
            .BIT_DEPTH(BIT_DEPTH)
        ) 
        ptop(
            .SYSTEM_CLK (system_clk),
            .SYSTEM_RESET (system_reset),
            .DATA_OUT_CLK (data_out_clk),
            .DATA_OUT(data_out)
    );

    initial
        begin
            

            $dumpfile("simulation/pixelTop_tb.vcd");
            $dumpvars(0,pixelTop_tb);

            system_reset = 1;

            #clk_period  system_reset=0;
            
            #sim_end
                $stop;


        end
endmodule
