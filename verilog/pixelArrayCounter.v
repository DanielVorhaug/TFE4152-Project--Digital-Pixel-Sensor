
module PIXEL_ARRAY_COUNTER (
    input   logic COUNTER_RESET,
    input   logic COUNTER_CLOCK,
    output  logic [BIT_DEPTH - 1:0] DATA 
);    

    parameter BIT_DEPTH = 10;

    logic [BIT_DEPTH - 1:0] check;

    logic [BIT_DEPTH - 1:0] counter = '0;

    always_ff @(posedge COUNTER_CLOCK or posedge COUNTER_RESET) begin
        if (COUNTER_RESET) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
        DATA <= {counter[BIT_DEPTH-1], counter[BIT_DEPTH-1:1] ^ counter[BIT_DEPTH-2:0]};
    end

    genvar i;
    generate
        assign check[BIT_DEPTH-1] = DATA[BIT_DEPTH-1];
        for (i = 2; i < BIT_DEPTH+1; i++) begin
            assign check[BIT_DEPTH-i] = check[BIT_DEPTH-i+1] ^ DATA[BIT_DEPTH-i];
        end
    endgenerate
    
endmodule
