`timescale 1 ns / 1 ps

module PIXEL_ARRAY_COUNTER_tb;

    parameter BIT_DEPTH = 10;
    logic clk =0;
    logic reset =0;
    wire [BIT_DEPTH-1:0] counter;
    parameter integer clk_period = 500;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;

    


    PIXEL_ARRAY_COUNTER #(.BIT_DEPTH(BIT_DEPTH)) pa1(
        .COUNTER_RESET (reset),
        .COUNTER_CLOCK (clk),
        .DATA (counter) 
    );


    initial
        begin
            reset = 1;

            #clk_period  reset=0;

            $dumpfile("simulation/PIXEL_ARRAY_COUNTER_tb.vcd");
            $dumpvars(0,PIXEL_ARRAY_COUNTER_tb);

            #sim_end
                reset = 1;
            #clk_period
                reset = 0;
            #sim_end
                $stop;
        end
    
endmodule