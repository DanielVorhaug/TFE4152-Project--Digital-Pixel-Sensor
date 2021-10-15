`timescale 1ns/1ps

module PIXEL_ARRAY_BUS_tb ();


parameter integer WIDTH = 2;
logic READ_CLK = 0;
logic [WIDTH*8-1:0] INPUT;
wire [15:0] OUT;
parameter integer sim_period = 300;

PIXEL_ARRAY_BUS #(.WIDTH(WIDTH)) pab1(
    .DATA(INPUT), .READ_CLK(READ_CLK), .OUT(OUT)
    );

initial
    begin
        $dumpfile("simulation/PIXEL_ARRAY_BUS_tb.vcd");
        $dumpvars(0, PIXEL_ARRAY_BUS_tb);
        INPUT = 69;
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