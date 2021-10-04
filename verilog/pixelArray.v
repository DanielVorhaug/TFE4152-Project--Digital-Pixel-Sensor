

module PIXEL_ARRAY(
    input logic POWER_ENABLE,
    input logic WRITE_ENABLE,
    input logic COUNTER_RESET,
    input logic COUNTER_CLOCK,
    input real  ANALOG_RAMP,
    input logic RESET,       // Reset voltage in paper
    input logic ERASE,       // Pixel reset in paper
    input logic EXPOSE,      // PG in paper

    inout wire [7:0] DATA    //Will have to expand this to account for more pixels

);

    PIXEL_ARRAY_COUNTER #() pac1(
        .COUNTER_RESET (COUNTER_RESET),
        .COUNTER_CLOCK (COUNTER_CLOCK),
        .DATA (DATA) );
        
// always_comb
// begin
//     assign DATA = (WRITE_ENABLE) ? counter : DATA;
// end

endmodule