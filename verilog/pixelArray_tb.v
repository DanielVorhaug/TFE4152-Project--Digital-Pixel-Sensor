`timescale 1 ns / 1 ps

module pixelArray_tb;

    logic clk =0;
    logic reset =0;
    parameter integer clk_period = 500;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;



    PIXEL_ARRAY #() pa1(
        .POWER_ENABLE (),
        .WRITE_ENABLE (),
        .COUNTER_RESET (reset),
        .COUNTER_CLOCK (clk),
        .ANALOG_RAMP (),
        .RESET (),
        .ERASE (),
        .EXPOSE (),
        .DATA () );

    //------------------------------------------------------------
    // Testbench stuff
    //------------------------------------------------------------
    initial
        begin
            reset = 1;

            #clk_period  reset=0;

            $dumpfile("pixelArray_tb.vcd");
            $dumpvars(0,pixelArray_tb);

            #sim_end
                reset = 1;
            #clk_period
                reset = 0;
            #sim_end
                $stop;


        end
    
endmodule