`timescale 1 ns / 1 ps

module PIXEL_ARRAY_COUNTER_tb;

    parameter BIT_DEPTH = 10;
    logic clk =0;
    logic reset =0;
    logic [BIT_DEPTH-1:0] counter;
    parameter integer clk_period = 500;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;

    


    PIXEL_ARRAY_COUNTER #(.BIT_DEPTH(BIT_DEPTH)) pa1(
        .COUNTER_RESET (reset),
        .COUNTER_CLOCK (clk),
        .DATA (counter) 
    );


        // Converts back to regular binary
    logic [BIT_DEPTH - 1:0] check;
    genvar i;
    generate
        assign check[BIT_DEPTH-1] = counter[BIT_DEPTH-1];
        for (i = 2; i < BIT_DEPTH+1; i++) begin
            assign check[BIT_DEPTH-i] = check[BIT_DEPTH-i+1] ^ counter[BIT_DEPTH-i];
        end
    endgenerate


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