module PIXEL_ARRAY_MEMORY_CONTROLLER (
    input logic SYSTEM_CLK,
    input logic READ_RESET,
    input logic READ_CLK_IN,
    output logic READ_CLK_OUT = 0,
    output logic WRITE_CLK_OUT,
    output logic [$clog2(HEIGHT):0] MEMORY_ROW = -1,
    output logic MEMORY_READ_ENABLE = 0
    // Maybe add output to state machine to tell when it's done reading
);

    parameter integer WIDTH = 2;
    parameter integer HEIGHT = 2;
    parameter integer OUTPUT_BUS_PIXEL_WIDTH = 2; // Needs to go up in WIDTH

    parameter integer point_to_row = 0, read_to_buffer = 1, write_out = 2, done = 3;

    logic [1:0] state = done;
    logic control_clk;
    logic state_enable = 0;
    logic write_out_enable = 0; 

    logic [$clog2(WIDTH):0] write_number = 0;

    always_ff @(posedge READ_CLK_IN) begin
        state_enable <= 1;
        state <= 0;
        MEMORY_READ_ENABLE <= 1;
        MEMORY_ROW = -1;
    end

    assign control_clk = state_enable ? SYSTEM_CLK : 0;
    assign WRITE_CLK_OUT = write_out_enable ? control_clk : 0;

    always_ff @(posedge control_clk) begin

        case (state)
            point_to_row:
            begin
                write_out_enable <= 0;

                MEMORY_ROW <= MEMORY_ROW + 1;
                state <= read_to_buffer;
            end

            read_to_buffer:
            begin
                READ_CLK_OUT <= 1;
                state <= write_out;
                write_number <= 0;
            end

            write_out:
            begin
                READ_CLK_OUT <= 0;
                write_out_enable <= 1;  
                write_number <= write_number + 1;

                if (write_number == WIDTH/OUTPUT_BUS_PIXEL_WIDTH - 1)
                begin
                    state <= (MEMORY_ROW == HEIGHT - 1) ? done : point_to_row;
                end
            end

            done:
            begin
                MEMORY_READ_ENABLE <= 0;
                MEMORY_ROW <= -1;
                state_enable <= 0;
            end

            default: 
            begin
                
            end
        endcase

    end
endmodule