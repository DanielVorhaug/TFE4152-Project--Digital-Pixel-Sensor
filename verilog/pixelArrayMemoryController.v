module PIXEL_ARRAY_MEMORY_CONTROLLER (
    input   logic SYSTEM_CLK,
    input   logic READ_RESET,
    input   logic READ_CLK_IN,
    output  logic READ_CLK_OUT = 0,
    output  logic WRITE_CLK_OUT,
    output  logic [$clog2(HEIGHT):0] MEMORY_ROW = -1,
    output  logic MEMORY_READ_ENABLE = 0
);

    parameter integer WIDTH = 2;
    parameter integer HEIGHT = 2;
    parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2; // Needs to go up in WIDTH


    parameter integer POINT_TO_ROW = 0, READ_TO_BUFFER = 1, WRITE_OUT = 2, DONE = 3;

    logic control_clk;
    logic [1:0] state       = DONE;
    logic state_enable      = 0;
    logic write_out_enable  = 0; 

    logic [$clog2(WIDTH):0] write_number = 0;

    always_ff @(posedge READ_CLK_IN) begin
        state_enable        <= 1;
        state               <= 0;
        MEMORY_READ_ENABLE  <= 1;
        MEMORY_ROW          = -1;
    end

    assign control_clk   = state_enable     ? SYSTEM_CLK  : 0;
    assign WRITE_CLK_OUT = write_out_enable ? control_clk : 0;

    always_ff @(posedge control_clk) begin

        case (state)
            POINT_TO_ROW:
                begin
                    write_out_enable    <= 0;
                    MEMORY_ROW          <= MEMORY_ROW + 1;
                    state               <= READ_TO_BUFFER;
                end

            READ_TO_BUFFER:
                begin
                    READ_CLK_OUT        <= 1;
                    state               <= WRITE_OUT;
                    write_number        <= 0;
                end

            WRITE_OUT:
                begin
                    READ_CLK_OUT        <= 0;
                    write_out_enable    <= 1;  
                    write_number        <= write_number + 1;

                    if (write_number == WIDTH/OUTPUT_BUS_PIXEL_WIDTH - 1) begin
                        state <= (MEMORY_ROW == HEIGHT - 1) ? DONE : POINT_TO_ROW;
                    end
                end

            DONE:
                begin
                    MEMORY_READ_ENABLE  <= 0;
                    MEMORY_ROW          <= -1;
                    state_enable        <= 0;
                end

            default: 
                begin
                end
        endcase

    end

endmodule
