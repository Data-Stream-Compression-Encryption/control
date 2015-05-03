

module test_con(clk, rst, address, w_rn, go, memValid, dsec_out_valid, dsec_in_valid, dsec_rdy);

	// Clock and active-low reset
	input clk;
	input rst;
	//

	// Memory controller signals
	output reg [12:0] address;
	output reg w_rn;
	output reg memValid;
	output reg go;
	//
	
	// DSEC control signals
	output reg dsec_in_valid;
	input dsec_out_valid;	
	input dsec_rdy;
	//
	
	// Working Addresses
	reg [12:0] writeAddress;
	reg [12:0] readAddress;
	//
	
	// State variables
	reg [3:0] curState;
	reg [3:0] nextState;
	//	
	
	// States
	parameter [3:0] IDLE = 4'd0;
	parameter [3:0] READ_DATA = 4'd1;
	parameter [3:0] WRITE_DATA = 4'd2;
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
	always@(curState,dsec_out_valid, dsec_rdy) begin
		case(curState)
			IDLE: begin
				if(dsec_out_valid)begin
					nextState = WRITE_DATA;
				end else if(dsec_rdy)begin
					nextState = READ_DATA;
				end else begin
					nextState = IDLE;
				end
			end	
			READ_DATA:begin
				if(memValid)begin
					nextState = IDLE;
				end else begin
					nextState = READ_DATA;
				end
			end
			WRITE_DATA:begin
				if(memValid)begin
					nextState = IDLE;
				end else begin
					nextState = WRITE_DATA;
				end
			end
			default:begin
				nextState = IDLE;
			end
		endcase
	end
	//
	
	// Drive address
	always@(posedge clk, negedge rst) begin
			if(~rst)begin
				address <= 13'd0;
			end else if(curState==READ_DATA) begin
				address <= readAddress;
			end else if(curState==WRITE_DATA) begin
				address <= writeAddress;
			end else begin
				address <= 13'd0;
			end
	end
	//
	
	// Drive writeAddress
	always@(posedge clk, negedge rst) begin
			if(~rst)begin
				writeAddress <= 13'd0;
			end else if(curState==WRITE_DATA && nextState==IDLE) begin
				writeAddress <= writeAddress + 13'd1;
			end else begin
				writeAddress <= writeAddress;
			end
	end
	//
	
	// Drive readAddress
	always@(posedge clk, negedge rst) begin
			if(~rst)begin
				readAddress <= 13'd0;
			end else if(curState==READ_DATA && nextState==IDLE) begin
				readAddress <= readAddress + 13'd1;
			end else begin
				readAddress <= readAddress;
			end
	end
	//	
	
endmodule