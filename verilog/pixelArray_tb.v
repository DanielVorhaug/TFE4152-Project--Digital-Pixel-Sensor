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

`timescale 1 ns / 1 ps

module pixelArray_tb;

    // Clock
    logic clk = 0;
    logic reset = 0;
    parameter integer clk_period = 500;
    parameter integer sim_period = clk_period *10.2;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;

    parameter WIDTH = 44;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 8;

    parameter real dv_pixel = 0.5;  //Set the expected photodiode current (0-1)

    // Analog signals
    logic ana_bias1;            // Amount of posedges decides how low photodiode voltage is
    

    // Digital 
    logic power_enable = 0;     // unused 
    logic write_enable = 0;     // Puts counter on data-bus
    logic counter_reset = 0;
    logic ana_ramp;
    logic reset_voltage = 0;    // unused
    logic erase = 0;            // Pixel reset in paper
    logic expose = 0;
    logic read_reset = 0;
    logic read = 0;
    logic data_out_clk;
    logic [OUTPUT_BUS_PIXEL_WIDTH*BIT_DEPTH-1:0] data_out;
    
   
    assign ana_ramp = convert ? clk : 0;
    assign ana_bias1 = expose ? clk : 0;
    //assign read_clk = read ? clk : 0;

    PIXEL_ARRAY #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH), .BIT_DEPTH(BIT_DEPTH), .dv_pixel(dv_pixel)) pa1(
        .POWER_ENABLE (power_enable),
        .WRITE_ENABLE (write_enable),
        .COUNTER_RESET (counter_reset),
        .COUNTER_CLOCK (ana_ramp),
        .ANALOG_RAMP (ana_ramp),
        .RESET (reset_voltage),
        .ERASE (erase),
        .EXPOSE (expose),
        .SYSTEM_CLK (clk),
        .READ_RESET (read_reset),
        .READ_CLK_IN (read),
        .VBN1 (ana_bias1),
        .DATA_OUT_CLK (data_out_clk),
        .DATA_OUT (data_out)        
        );

    
    //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4;

    logic               convert = 0;
    logic               convert_stop;
    logic [2:0]         state,next_state;   //States
    integer             counter;            //Delay counter in state machine

    //State duration in clock cycles
    parameter integer c_erase = 5;
    parameter integer c_expose = 255;
    parameter integer c_convert = 255;
    parameter integer c_read = (2+WIDTH/OUTPUT_BUS_PIXEL_WIDTH)*HEIGHT + 1;

    // Control the output signals
    always_ff @(negedge clk ) begin
        case(state)
            ERASE: begin
                power_enable <= 0;
                write_enable <= 0;
                counter_reset <= 1;
                reset_voltage <= 0;
                erase <= 1;
                expose <= 0;
                convert <= 0;
                read_reset <= 0;
                read <= 0;
                
            end
            EXPOSE: begin
                power_enable <= 1;
                write_enable <= 1;
                counter_reset <= 0;
                reset_voltage <= 0;
                erase <= 0;
                expose <= 1;
                convert <= 0;
                read_reset <= 0;
                read <= 0;
                
            end
            CONVERT: begin
                power_enable <= 1;
                write_enable <= 1;
                counter_reset <= 0;
                reset_voltage <= 0;
                erase <= 0;
                expose <= 0;
                convert = 1;
                read_reset <= 0;
                read <= 0;
                
            end
            READ: begin
                power_enable <= 1;
                write_enable <= 0;
                counter_reset <= 0;
                reset_voltage <= 0;
                erase <= 0;
                expose <= 0;
                convert <= 0;
                read_reset <= 0;
                read <= 1;

            end
            IDLE: begin
                power_enable <= 0;
                write_enable <= 0;
                counter_reset <= 0;
                reset_voltage <= 0;
                erase <= 0;
                expose <= 0;
                convert <= 0;
                read_reset <= 0;
                read <= 0;

            end
        endcase // case (state)
    end // always @ (state)


    // Control the state transitions
    //TODO: The counter should probably be an always_comb. Might be a good idea
    //to also reset the counter from the state machine, i.e provide the count
    //down value, and trigger on 0
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state = IDLE;
            next_state = ERASE;
            counter  = 0;
            convert  = 0;
        end
        else begin
            case (state)
            ERASE: begin
                if(counter == c_erase) begin
                    next_state <= EXPOSE;
                    state <= IDLE;
                end
            end
            EXPOSE: begin
                if(counter == c_expose) begin
                    next_state <= CONVERT;
                    state <= IDLE;
                end
            end
            CONVERT: begin
                if(counter == c_convert) begin
                    next_state <= READ;
                    state <= IDLE;
                end
            end
            READ:
                if(counter == c_read) begin
                    state <= IDLE;
                    next_state <= ERASE;
                end
            IDLE:
                state <= next_state;
            endcase // case (state)
            if(state == IDLE)
            counter = 0;
            else
            counter = counter + 1;
        end
    end // always @ (posedge clk or posedge reset)


    initial
        begin
            reset = 1;

            #clk_period  reset=0;

            $dumpfile("simulation/pixelArray_tb.vcd");
            $dumpvars(0,pixelArray_tb);
            
            #sim_end
                $stop;


        end
    
endmodule