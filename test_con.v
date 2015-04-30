

module test_con(clk, rst, address, , w_rn, go, valid, out_valid, in_valid);

	// Clock and active-low reset
	input clk;
	input rst;
	//

	// Memory controller signals
	output reg [12:0] address;
	output w_rn;
	output valid;
	output go;
	//
	
	// DSEC control signals
	output in_valid;
	input out_valid;	
	//
	
	// State variables
	reg [3:0] curState;
	reg [3:0] nextState;
	//	
	
	// States
	parameter [3:0] IDLE = 4'h0;
	//
		
	// State Transitions 	
	always@(posedge clk, negedge rst) begin
			if(~rst) 
				curState <= IDLE;
			else	
				curState <= nextState;	
	end
	//
	
	// State Machine
	always@(curState) begin
		case(curState)
			IDLE: begin
			
			end	
			default:begin
				nextState = IDLE;
			end
		endcase
	end
	//
	
	
	
	
	
endmodule