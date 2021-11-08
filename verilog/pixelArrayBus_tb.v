`timescale 1ns/1ps

module PIXEL_ARRAY_BUS_tb ();


parameter integer BIT_DEPTH = 8;
parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2;
parameter integer WIDTH = 6;
logic READ_CLK = 0;
logic [WIDTH*8-1:0] INPUT;
wire [15:0] OUT;
parameter integer sim_period = 300;
logic WRITE_CLK = 0;
always #10 WRITE_CLK = ~WRITE_CLK;

PIXEL_ARRAY_BUS #(.WIDTH(WIDTH), .BIT_DEPTH(BIT_DEPTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH)) pab1(
    .DATA(INPUT), .READ_CLK(READ_CLK), .OUT(OUT), .WRITE_CLK(WRITE_CLK)
    );

initial
    begin
        $dumpfile("simulation/PIXEL_ARRAY_BUS_tb.vcd");
        $dumpvars(0, PIXEL_ARRAY_BUS_tb);
        INPUT = 'h103256237777;
        #sim_period
        READ_CLK = 1;
        #10
        READ_CLK = 0;
        #sim_period
        INPUT = 0;
        #sim_period
        $stop;
    end


endmodule