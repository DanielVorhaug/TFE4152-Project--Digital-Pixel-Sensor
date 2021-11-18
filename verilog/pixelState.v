//====================================================================
//        Copyright (c) 2021 Carsten Wulff Software, Norway
// ===================================================================
// Created       : wulff at 2021-7-21
// ===================================================================
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//====================================================================

module PIXEL_STATE_MACHINE (
    input  logic SYSTEM_CLK,
    input  logic SYSTEM_RESET,
    output logic POWER_ENABLE = 0,
    output logic WRITE_ENABLE = 0,
    output logic COUNTER_RESET = 0,
    output logic COUNTER_CLOCK,
    output real  ANALOG_RAMP,
    output logic RESET = 0,             // Reset voltage in paper
    output logic ERASE = 0,             // Pixel reset in paper
    output logic EXPOSE = 0,            // PG in paper
    output logic READ_RESET = 0,
    output logic READ_CLK_IN = 0,
    output logic VBN1                   // ana_bias1          
);

    parameter WIDTH = 2;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 10;

    parameter real dv_pixel = 0.5;  //Set the expected photodiode current (0-1)
   
   
    assign COUNTER_CLOCK    = ANALOG_RAMP;
    assign ANALOG_RAMP      = convert ? SYSTEM_CLK : 0;
    assign VBN1             = EXPOSE  ? SYSTEM_CLK : 0; // Amount of posedges decides how low photodiode voltage is
    
    //------------------------------------------------------------
    // State Machine
    //------------------------------------------------------------
    parameter STATE_ERASE=0, STATE_EXPOSE=1, STATE_CONVERT=2, STATE_READ=3, STATE_IDLE=4;

    //State duration in clock cycles
    parameter integer c_erase   = 5;
    parameter integer c_expose  = 2**BIT_DEPTH - 1;
    parameter integer c_convert = 2**BIT_DEPTH - 1;
    parameter integer c_read    = (2+WIDTH/OUTPUT_BUS_PIXEL_WIDTH)*HEIGHT + 1;
        
    parameter integer counter_max = (c_erase > c_expose ? c_erase : c_expose) > (c_convert > c_read ? c_convert : c_read) ? (c_erase > c_expose ? c_erase : c_expose) : (c_convert > c_read ? c_convert : c_read); // Finds which state duration is longest
    
    logic [$clog2(counter_max)-1:0] counter;                // Delay counter in state machine, Assumes the longest state will be read   
    logic                           convert = 0;
    logic                           convert_stop;
    logic [2:0]                     state, next_state;      // States
    

    // Control the output signals
    always_ff @(negedge SYSTEM_CLK ) begin
        case(state)
            STATE_ERASE: begin
                POWER_ENABLE    <= 0;
                WRITE_ENABLE    <= 0;
                COUNTER_RESET   <= 1;
                RESET           <= 0;
                ERASE           <= 1;
                EXPOSE          <= 0;
                convert         <= 0;
                READ_RESET      <= 0;
                READ_CLK_IN     <= 0;
            end

            STATE_EXPOSE: begin
                POWER_ENABLE    <= 1;
                WRITE_ENABLE    <= 1;
                COUNTER_RESET   <= 0;
                RESET           <= 0;
                ERASE           <= 0;
                EXPOSE          <= 1;
                convert         <= 0;
                READ_RESET      <= 0;
                READ_CLK_IN     <= 0;             
            end

            STATE_CONVERT: begin
                POWER_ENABLE    <= 1;
                WRITE_ENABLE    <= 1;
                COUNTER_RESET   <= 0;
                RESET           <= 0;
                ERASE           <= 0;
                EXPOSE          <= 0;
                convert         <= 1;
                READ_RESET      <= 0;
                READ_CLK_IN     <= 0;
            end

            STATE_READ: begin
                POWER_ENABLE    <= 1;
                WRITE_ENABLE    <= 0;
                COUNTER_RESET   <= 0;
                RESET           <= 0;
                ERASE           <= 0;
                EXPOSE          <= 0;
                convert         <= 0;
                READ_RESET      <= 0;
                READ_CLK_IN     <= 1;
            end

            STATE_IDLE: begin
                POWER_ENABLE    <= 0;
                WRITE_ENABLE    <= 0;
                COUNTER_RESET   <= 0;
                RESET           <= 0;
                ERASE           <= 0;
                EXPOSE          <= 0;
                convert         <= 0;
                READ_RESET      <= 0;
                READ_CLK_IN     <= 0;
            end

        endcase // case (state)
    end // always @ (state)


    // Control the state transitions
    always_ff @(posedge SYSTEM_CLK or posedge SYSTEM_RESET) begin
        if(SYSTEM_RESET) begin
            state       = STATE_IDLE;
            next_state  = STATE_ERASE;
            counter     = 0;
            convert     = 0;
        end
        else begin
            case (state)
                STATE_ERASE: begin
                    if(counter == c_erase) begin
                        next_state  <= STATE_EXPOSE;
                        state       <= STATE_IDLE;
                    end
                end

                STATE_EXPOSE: begin
                    if(counter == c_expose) begin
                        next_state  <= STATE_CONVERT;
                        state       <= STATE_IDLE;
                    end
                end

                STATE_CONVERT: begin
                    if(counter == c_convert) begin
                        next_state  <= STATE_READ;
                        state       <= STATE_IDLE;
                    end
                end

                STATE_READ: begin
                    if(counter == c_read) begin
                        state       <= STATE_IDLE;
                        next_state  <= STATE_ERASE;
                    end
                end

                STATE_IDLE:
                    state <= next_state;

            endcase // case (state)

            if(state == STATE_IDLE)
                counter = 0;
            else 
                counter = counter + 1;

        end
    end // always @ (posedge clk or posedge reset)
    
endmodule
