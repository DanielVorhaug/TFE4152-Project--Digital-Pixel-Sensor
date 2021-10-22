`timescale 1 ns / 1 ps

module pixelArray_tb;

    logic clk =0;
    logic reset =0;
    logic write_enable =1;
    parameter integer clk_period = 500;
    parameter integer sim_period = clk_period *10.2;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;

    parameter real dv_pixel = 0.5;  //Set the expected photodiode current (0-1)

    //Analog signals
    logic ana_bias1;
    logic ana_ramp;
    logic read_clk;

    logic expose;
    logic read;
    logic convert;
    tri[7:0] pixData; //  We need this to be a wire, because we're tristating it
   
    assign anaRamp = convert ? clk : 0;
    assign anaBias1 = expose ? clk : 0;
    assign read_clk = read ? clk : 0;

    PIXEL_ARRAY #() pa1(
        .POWER_ENABLE (),
        .WRITE_ENABLE (write_enable),
        .COUNTER_RESET (reset),
        .COUNTER_CLOCK (clk),
        .ANALOG_RAMP (ana_ramp),
        .RESET (),
        .ERASE (),
        .EXPOSE (expose),
        .SYSTEM_CLK (),
        .READ_RESET (),
        .READ_CLK_IN (read_clk),
        .VBN1 (ana_bias1),
        .DATA_OUT ()
        );



    initial
        begin
            reset = 1;

            #clk_period  reset=0;

            $dumpfile("simulation/pixelArray_tb.vcd");
            $dumpvars(0,pixelArray_tb);
            
            #sim_period
                write_enable = 0;
            #sim_period
                write_enable = 1;

            #sim_end
                reset = 1;
            #clk_period
                reset = 0;

            #sim_period
                write_enable = 0;
            #sim_period
                write_enable = 1;
                expose = 1;
            #sim_period
                expose = 0;
                convert = 1;
            #sim_period
                convert = 0;
            #clk_period
                write_enable = 0;
            #clk_period
                read = 1;
            #sim_end
                $stop;


        end
    
endmodule