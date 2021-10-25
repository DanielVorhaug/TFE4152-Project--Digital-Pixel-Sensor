`timescale 1 ns / 1 ps

module pixelArray_tb;

    // Clock
    logic clk = 0;
    logic reset = 0;
    parameter integer clk_period = 500;
    parameter integer sim_period = clk_period *10.2;
    parameter integer sim_end = clk_period*2400;
    always #clk_period clk=~clk;

    parameter real dv_pixel = 0.5;  //Set the expected photodiode current (0-1)

    parameter WIDTH = 2;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 8;


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

    tri[7:0] pixData; //  We need this to be a wire, because we're tristating it
   
    assign ana_ramp = convert ? clk : 0;
    assign ana_bias1 = expose ? clk : 0;
    //assign read_clk = read ? clk : 0;

    PIXEL_ARRAY #(.HEIGHT(HEIGHT), .WIDTH(WIDTH), .OUTPUT_BUS_PIXEL_WIDTH(OUTPUT_BUS_PIXEL_WIDTH), .BIT_DEPTH(BIT_DEPTH)) pa1(
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
        .DATA_OUT ()
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
    parameter integer c_read = 5;

    // Control the output signals
    always_ff @(negedge clk ) begin
        case(state)
            ERASE: begin
                power_enable <= 0;
                write_enable <= 0;
                counter_reset <= 0;
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

                    counter_reset <= 1;
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

    //------------------------------------------------------------
    // DAC and ADC model
    //------------------------------------------------------------
    logic[7:0] data;

    // If we are to convert, then provide a clock via anaRamp
    // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
    // however, we cheat
    assign anaRamp = convert ? clk : 0;

    // During expoure, provide a clock via anaBias1.
    // Again, no resemblence to real world, but we cheat.
    assign anaBias1 = expose ? clk : 0;

    // If we're not reading the pixData, then we should drive the bus
    //assign pixData = read ? 8'bZ: data;

    // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
    // data bus.
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            data =0;
        end
        if(convert) begin
            data +=  1;
        end
        else begin
            data = 0;
        end
    end



    initial
        begin
            reset = 1;

            #clk_period  reset=0;

            $dumpfile("simulation/pixelArray_tb.vcd");
            $dumpvars(0,pixelArray_tb);
            
            #sim_period
                write_enable = 0;
            #sim_period
                write_enable = 1;

            #sim_end
                reset = 1;
            #clk_period
                reset = 0;

            #sim_period
                write_enable = 0;
            #sim_period
                write_enable = 1;
                expose = 1;
            #sim_period
                expose = 0;
                convert = 1;
            #sim_end
                convert = 0;
            #clk_period
                write_enable = 0;
            #clk_period
                read = 1;
            #sim_end
                $stop;


        end
    
endmodule