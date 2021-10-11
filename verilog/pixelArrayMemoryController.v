module PIXEL_ARRAY_MEMORY_CONTROLLER (
    input logic SYSTEM_CLK,
    input logic READ_RESET,
    input logic READ_CLK_IN,
    output logic READ_CLK_OUT,
    output logic WRITE_CLK_OUT,
    output logic MEMORY_ROW,
    output logic MEMORY_READ_ENABLE
);

    parameter integer WIDTH = 2;
    parameter integer HEIGHT = 2;
    parameter integer log2_height = $clog2(HEIGHT);

    parameter integer read_to_buffer = 0, write_out = 1, done = 2;

    

        // Might not be needed
    READ_CLK_OUT <= 0;
    WRITE_CLK_OUT <= ;
    MEMORY_ROW <= -1; 
    MEMORY_READ_ENABLE <= 0;

    logic state_enable <= 0;
    logic control_clk;
    logic write_out_enable <= 0; 

    logic [log2_height:0] write_number = 0;

    always_ff @(posedge READ_CLK_IN) begin
        state_enable <= 1;
        MEMORY_READ_ENABLE <= 1;
    end

    assign control_clk = state_enable ? SYSTEM_CLK : 0;
    assign WRITE_CLK_OUT = write_out_enable ? control_clk : 0;

    always_ff @(posedge control_clk) begin

        case (state)
            read_to_buffer:
            begin
                MEMORY_ROW <= MEMORY_ROW + 1;
                READ_CLK_OUT <= 1;
                state <= write_out;
                write_number <= 0;

                if (MEMORY_ROW == HEIGHT) state = done;

            end

            write_out:
            begin
                write_out_enable <= 1;
                write_number <= write_number + 1;

                if (write_number[log2_height - 1])
                begin
                    state <= read_to_buffer;
                    write_number <= 0;
                end
            end

            done:
            begin
                MEMORY_READ_ENABLE = 0;
                MEMORY_ROW = -1;
                state_enable = 0;
                state = read_to_buffer;

            end

            default: 
            begin
                
            end
        endcase


    end




endmodule