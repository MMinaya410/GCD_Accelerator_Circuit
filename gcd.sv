
typedef enum logic [1:0]{
    IDLE = 2'b00,
    DIV = 2'b01,
    RESULT = 2'b10
	//your states here (if you so choose)
} state;

module gcd #(
        parameter WIDTH = 8								//Used to parameterize how many bits wide the inputs and output will be.
    )
    (
	    input  logic            		clk_i, reset_i,   		// global - module clock and reset
	    input  logic            		valid_i,        		// valid in - the inputs are valid to read in and begin processing
	    input  logic [WIDTH-1:0]		a_i, b_i,       		// operands - inputs to the gcd algo
	    output logic [WIDTH-1:0]		gcd_o,          		// gcd output - result of the gcd algo
	    output logic            		valid_o,         		// valid out - indicates the gcd output value is valid to read
	    output logic			ready_o				// ready out - outputs a 1'b1 when ready for new values, and a 1'b0 when computing a new GCD
    );

	/*
	* At the top of the file is where you typically declare signals that are used internally in the module
	*/

    logic[WIDTH-1:0] c_ind,a_ind,b_ind,gcd_ind, a_next, b_next, gcd_next;
	state state_next, state;
	
	
	/*
 	* This block is where you will write RTL to change the value of your registers (ie your sequential logic)
 	*/
	always_ff @(posedge clk_i) begin	//this line tells the block to evaluate on the positive (rising) edge of the clock signal
		if (reset_i) begin
            state <= IDLE;
            a_ind <= 8'd0;
            b_ind <= 8'd0;
            gcd_ind <= 8'd0;
			//reset logic
		end 
        else begin
            state <= state_next;
            a_ind <= a_next;
            b_ind <= b_next;
            gcd_ind <= gcd_next;
			//normal operation logic
		end
	end


	/*
 	* This block is where you will write RTL for combinational logic
  	*/
	always_comb begin

        case (state)
            IDLE: begin
                valid_o = 1'b0;
                gcd_o = 8'd0;
                ready_o = 1'b1;
                gcd_next = 8'b0;
                c_ind = 8'b0;
                a_next = 8'b0;
                b_next = 8'b0;

                if(valid_i) begin
                    ready_o = 1'b0;
                    a_next = a_i;
                    b_next = b_i;
                    state_next = DIV;

                end
                else begin
                    state_next = IDLE;
                end
            end

            DIV: begin
                valid_o = 1'b0;
                gcd_o = 8'd0;
                ready_o = 1'b0;
                if(a_ind > b_ind)begin
                    c_ind = a_ind-b_ind;
                    a_next = c_ind;

                    state_next = DIV;
                end
                else if(a_ind < b_ind) begin
                    c_ind = b_ind-a_ind;
                    b_next = c_ind;
                    state_next = DIV;
                end
                else begin
                    gcd_next = a_ind; 
                    state_next = RESULT;
                end
            end

            RESULT: begin
                if(gcd_ind > 0) begin
                    valid_o = 1'b1;
                    gcd_o = gcd_ind;
                    ready_o = 1'b0;
                    state_next = IDLE; 
                end
                else begin
                    valid_o = 1'b0;
                    gcd_o = 8'd0;
                    ready_o = 1'b0;
                    state_next =  IDLE;
                end
            end

            default: begin
                valid_o = 1'b0;
                gcd_o = 8'd0;
                ready_o = 1'b0;
                state_next = IDLE;
            end
        endcase
		

	end
endmodule