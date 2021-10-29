`timescale 1ns/1ps

module PIXEL_ARRAY_READ_POINTER_tb ();

parameter integer HEIGHT = 4;
logic [$clog2(HEIGHT):0] CONTROL = '0;
wire [HEIGHT-1: 0] ROW_SELECT;
logic ENABLE = 0;
parameter integer sim_period = 300;

PIXEL_ARRAY_READ_POINTER #(.HEIGHT(HEIGHT)) parp1(
    .CONTROL(CONTROL), .ROW_SELECT(ROW_SELECT), .ENABLE(ENABLE)
);


initial begin
    $dumpfile("simulation/PIXEL_ARRAY_READ_POINTER_tb.vcd");
    $dumpvars(0, PIXEL_ARRAY_READ_POINTER_tb);
    #sim_period
    for (CONTROL = 0;CONTROL < HEIGHT; CONTROL++) begin
        if (CONTROL == 0) ENABLE = 1;
        #sim_period;
    end
    for (CONTROL = 0;CONTROL < HEIGHT; CONTROL++) begin
        if (CONTROL == 0) ENABLE = 0;
        #sim_period;
    end
    #sim_period;
end

endmodule