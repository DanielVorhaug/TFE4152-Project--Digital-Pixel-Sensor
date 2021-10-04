

module PIXEL_ARRAY(
    input logic POWER_ENABLE,
    input logic WRITE_ENABLE,
    inout logic COUNTER_RESET,
    inout logic COUNTER_CLOCK,
    input real  ANALOG_RAMP,
    input logic RESET,       // Reset voltage in paper
    input logic ERASE,       // Pixel reset in paper
    input logic EXPOSE,      // PG in paper

    inout wire [7:0] DATA    //Will have to expand this to account for more pixels

);

logic [7:0] counter = '0;

// always_comb
// begin
//     assign DATA = (WRITE_ENABLE) ? counter : DATA;
// end

endmodule