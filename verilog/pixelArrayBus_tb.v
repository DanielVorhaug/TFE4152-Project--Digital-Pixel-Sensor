`timescale 1ns/1ps

module PIXEL_ARRAY_BUS_tb ();


parameter integer WIDTH = 2;
parameter integer HEIGHT = 2;
parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2;
parameter integer BIT_DEPTH = 8;
integer output_bus_width = OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH;

logic READ_CLK = 0;
logic WRITE_CLK = 0;
logic [output_bus_width-1:0] INPUT;
wire [output_bus_width-1:0] OUT;

parameter integer clk_period = 500;
parameter integer sim_period = clk_period *10.2;
// always #clk_period READ_CLK=~READ_CLK;
// always #clk_period WRITE_CLK=~WRITE_CLK;

PIXEL_ARRAY_BUS #(.WIDTH(WIDTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH), .BIT_DEPTH(BIT_DEPTH)) pab1(
    .DATA(INPUT), .READ_CLK(READ_CLK), .WRITE_CLK(WRITE_CLK), .OUT(OUT)
);

initial
    begin
        $dumpfile("simulation/PIXEL_ARRAY_BUS_tb.vcd");
        $dumpvars(0, PIXEL_ARRAY_BUS_tb);
        INPUT = 69;
        #sim_period
        READ_CLK = 1;
        #10
        WRITE_CLK = 1;
        #10
        READ_CLK = 0;
        #sim_period
        INPUT = 0;
        #sim_period
        $stop;
    end


endmodule