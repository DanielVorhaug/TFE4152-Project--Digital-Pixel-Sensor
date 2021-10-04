

module PIXEL_ARRAY(
    input logic POWER_ENABLE,
    input logic WRITE_ENABLE,
    input logic COUNTER_RESET,
    input logic COUNTER_CLOCK,
    input real  ANALOG_RAMP,
    input logic RESET,       // Reset voltage in paper
    input logic ERASE,       // Pixel reset in paper
    input logic EXPOSE,      // PG in paper

    inout wire [7:0] DATA

);

logic [7:0] counter = '0;

always_ff @(posedge COUNTER_CLOCK or posedge COUNTER_RESET) begin
    if (COUNTER_RESET) begin
        counter = 0;
    end else begin
        counter++;
    end
end

endmodule