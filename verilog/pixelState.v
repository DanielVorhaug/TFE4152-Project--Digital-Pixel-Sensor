

module PIXEL_STATE_MACHINE (
    input  logic SYSTEM_CLK,
    input  logic SYSTEM_RESET,
    output logic POWER_ENABLE = 0,
    output logic WRITE_ENABLE = 0,
    output logic COUNTER_RESET = 0,
    output logic COUNTER_CLOCK,
    output real  ANALOG_RAMP,
    output logic RESET = 0,             // Reset voltage in paper
    output logic ERASE = 0,         // Pixel reset in paper
    output logic EXPOSE = 0,        // PG in paper
    //output logic SYSTEM_CLK,
    output logic READ_RESET = 0,
    output logic READ_CLK_IN = 0,
    output logic VBN1               // ana_bias1          
);

    parameter WIDTH = 2;
    parameter HEIGHT = 2;
    parameter OUTPUT_BUS_PIXEL_WIDTH = 2;
    parameter BIT_DEPTH = 10;

    parameter real dv_pixel = 0.5;  //Set the expected photodiode current (0-1)
   
   
    assign ANALOG_RAMP = convert ? SYSTEM_CLK : 0;
    assign COUNTER_CLOCK = ANALOG_RAMP;
    assign VBN1 = EXPOSE ? SYSTEM_CLK : 0; // Amount of posedges decides how low photodiode voltage is
    
    //------------------------------------------------------------
    // State Machine
    //------------------------------------------------------------
    parameter STATE_ERASE=0, STATE_EXPOSE=1, STATE_CONVERT=2, STATE_READ=3, STATE_IDLE=4;
        
    parameter counter_size = ($clog2((2+WIDTH/OUTPUT_BUS_PIXEL_WIDTH)*HEIGHT)+1) > (BIT_DEPTH-1) ? ($clog2((2+WIDTH/OUTPUT_BUS_PIXEL_WIDTH)*HEIGHT)+1) : (BIT_DEPTH-1);

    logic                   convert = 0;
    logic                   convert_stop;
    logic [2:0]             state,next_state;   //States
    logic [counter_size:0]  counter;            //Delay counter in state machine, Assumes the longest state will be read

    //State duration in clock cycles
    parameter integer c_erase = 5;
    parameter integer c_expose = 255;
    parameter integer c_convert = 2**BIT_DEPTH - 1;
    parameter integer c_read = (2+WIDTH/OUTPUT_BUS_PIXEL_WIDTH)*HEIGHT + 1;

    // Control the output signals
    always_ff @(negedge SYSTEM_CLK ) begin
        case(state)
            STATE_ERASE: begin
                POWER_ENABLE <= 0;
                WRITE_ENABLE <= 0;
                COUNTER_RESET <= 1;
                RESET <= 0;
                ERASE <= 1;
                EXPOSE <= 0;
                convert <= 0;
                READ_RESET <= 0;
                READ_CLK_IN <= 0;
                
            end
            STATE_EXPOSE: begin
                POWER_ENABLE <= 1;
                WRITE_ENABLE <= 1;
                COUNTER_RESET <= 0;
                RESET <= 0;
                ERASE <= 0;
                EXPOSE <= 1;
                convert <= 0;
                READ_RESET <= 0;
                READ_CLK_IN <= 0;
                
            end
            STATE_CONVERT: begin
                POWER_ENABLE <= 1;
                WRITE_ENABLE <= 1;
                COUNTER_RESET <= 0;
                RESET <= 0;
                ERASE <= 0;
                EXPOSE <= 0;
                convert = 1;
                READ_RESET <= 0;
                READ_CLK_IN <= 0;
                
            end
            STATE_READ: begin
                POWER_ENABLE <= 1;
                WRITE_ENABLE <= 0;
                COUNTER_RESET <= 0;
                RESET <= 0;
                ERASE <= 0;
                EXPOSE <= 0;
                convert <= 0;
                READ_RESET <= 0;
                READ_CLK_IN <= 1;

            end
            STATE_IDLE: begin
                POWER_ENABLE <= 0;
                WRITE_ENABLE <= 0;
                COUNTER_RESET <= 0;
                RESET <= 0;
                ERASE <= 0;
                EXPOSE <= 0;
                convert <= 0;
                READ_RESET <= 0;
                READ_CLK_IN <= 0;

            end
        endcase // case (state)
    end // always @ (state)


    // Control the state transitions
    //TODO: The counter should probably be an always_comb. Might be a good idea
    //to also reset the counter from the state machine, i.e provide the count
    //down value, and trigger on 0
    always_ff @(posedge SYSTEM_CLK or posedge SYSTEM_RESET) begin
        if(SYSTEM_RESET) begin
            state = STATE_IDLE;
            next_state = STATE_ERASE;
            counter  = 0;
            convert  = 0;
        end
        else begin
            case (state)
            STATE_ERASE: begin
                if(counter == c_erase) begin
                    next_state <= STATE_EXPOSE;
                    state <= STATE_IDLE;
                end
            end
            STATE_EXPOSE: begin
                if(counter == c_expose) begin
                    next_state <= STATE_CONVERT;
                    state <= STATE_IDLE;
                end
            end
            STATE_CONVERT: begin
                if(counter == c_convert) begin
                    next_state <= STATE_READ;
                    state <= STATE_IDLE;
                end
            end
            STATE_READ:
                if(counter == c_read) begin
                    state <= STATE_IDLE;
                    next_state <= STATE_ERASE;
                end
            STATE_IDLE:
                state <= next_state;
            endcase // case (state)
            if(state == STATE_IDLE) counter = 0;
            else counter = counter + 1;
        end
    end // always @ (posedge clk or posedge reset)
    
endmodule