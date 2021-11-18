`timescale 1ns/1ps

module PIXEL_ARRAY_BUS_tb ();


parameter integer BIT_DEPTH = 10;
parameter integer OUTPUT_BUS_PIXEL_WIDTH = 4;
parameter integer WIDTH = 8;
logic READ_CLK = 0;
logic [WIDTH*BIT_DEPTH-1:0] INPUT;
wire [BIT_DEPTH*OUTPUT_BUS_PIXEL_WIDTH-1:0] OUT;
parameter integer sim_period = 300;
logic WRITE_CLK = 0;
//always #10 WRITE_CLK = ~WRITE_CLK;

PIXEL_ARRAY_BUS #(.WIDTH(WIDTH), .BIT_DEPTH(BIT_DEPTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH)) pab1(
    .DATA(INPUT), .READ_CLK(READ_CLK), .OUT(OUT), .WRITE_CLK(WRITE_CLK)
    );

initial
    begin
        $dumpfile("simulation/PIXEL_ARRAY_BUS_tb.vcd");
        $dumpvars(0, PIXEL_ARRAY_BUS_tb);
        INPUT = 'h10325623777788885555;
        #sim_period
        READ_CLK = 1;
        #10
        READ_CLK = 0;
        #10
        WRITE_CLK = 1;
        #10
        WRITE_CLK = 0;
        #10
        WRITE_CLK = 1;
        #10
        WRITE_CLK = 0;
        #sim_period
        INPUT = 0;
        #sim_period
        $stop;
    end


endmodule