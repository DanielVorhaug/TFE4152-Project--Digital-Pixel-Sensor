
module PIXEL_ARRAY_COUNTER (
    input logic COUNTER_RESET,
    input logic COUNTER_CLOCK,
    output logic [7:0] DATA 
);    

    logic [7:0] counter = '0;

    always_comb begin
        counter = DATA + 1;
    end

    always_ff @(posedge COUNTER_CLOCK or posedge COUNTER_RESET) begin
        if (COUNTER_RESET) begin
            DATA <= 0;
        end else begin
            DATA <= counter;
        end
    end
    
endmodule