`timescale 1 ns / 1 ps

module pixelArrayCounter_tb;

    logic clk =0;
    logic reset =0;
    wire [7:0] counter = '0;
    parameter integer clk_period = 500;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;



    PIXEL_ARRAY_COUNTER #() pa1(
        .COUNTER_RESET (reset),
        .COUNTER_CLOCK (clk),
        .DATA (counter) );

    //------------------------------------------------------------
    // Testbench stuff
    //------------------------------------------------------------
    initial
        begin
            reset = 1;

            #clk_period  reset=0;

            $dumpfile("simulation/pixelArrayCounter_tb.vcd");
            $dumpvars(0,pixelArrayCounter_tb);

            #sim_end
                reset = 1;
            #clk_period
                reset = 0;
            #sim_end
                $stop;


        end
    
endmodule