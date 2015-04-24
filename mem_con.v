


// //////////// SDRAM //////////
// output		    [12:0]		DRAM_ADDR;
// output		     [1:0]		DRAM_BA;
// output		          		DRAM_CAS_N;
// output		          		DRAM_CKE;
// output		          		DRAM_CLK;
// output		          		DRAM_CS_N;
// inout 		    [31:0]		DRAM_DQ;
// output		     [3:0]		DRAM_DQM;
// output		          		DRAM_RAS_N;
// output		          		DRAM_WE_N;


module mem_con(clk, rst,dram_addr, dram_ba, dram_cas_n, dram_cke, dram_clk, dram_cs_n, dram_dq, dram_dqm, dram_ras_n, dram_we_n, data, address, go, valid, led);
	
	input clk;
	input rst;	

	// DRAM control signals
	output 	    	[12:0]		dram_addr;
	output		     [1:0]		dram_ba;
	output reg	          		dram_cas_n;
	output		          		dram_cke;
	output		          		dram_clk;
	output		          		dram_cs_n;
	inout 		    [31:0]		dram_dq;
	output		     [3:0]		dram_dqm;
	output reg	          		dram_ras_n;
	output reg	          		dram_we_n;
	//

	// Interface
	output [63:0] data;
	input [12:0] address;
	input go;
	output reg valid;
	output reg [17:0] led;
	
	
	assign dram_cke = 1'b1;			// Clock Enable Bit
	assign dram_cs_n = 1'b0;		// Command Select - Determines whether command input is enabled within ram - Disabled when high, enabled when low
	
	
	assign dram_clk = clk;


	
	//assign dram_we_n = 1'b1;
	assign dram_ba = 2'b00;
	assign dram_dqm = 4'b0;
	
	//assign dram_dq = 32'habcdef10;

	

	
	// State Variables
	reg [3:0] curState;
	reg [3:0] nextState;
	
	parameter [3:0] IDLE = 4'd0;				// Do nothing
	parameter [3:0] ACTIVE = 4'd1;			// Activate RAM row or whatever
	parameter [3:0] READ_BEGIN = 4'd2;		// Set RAM module for reading
	parameter [3:0] READ_WAIT1 = 4'd3;		// Wait for CAS latency 
	parameter [3:0] READ_WAIT2 = 4'd4;		// Wait for CAS latency 
	parameter [3:0] READ1 = 4'd5;				// Read incoming data first half
	parameter [3:0] ACTIVE_WAIT1 = 4'd6;			
	parameter [3:0] ACTIVE_WAIT2 = 4'd7;				
	parameter [3:0] READ2 = 4'd8;				// Read incoming data second half
	//parameter [3:0] WRITE_BEGIN = 4'd7;	// Set RAM module for writing
	//parameter [3:0] WRITE1 = 4'd8;			// Write most significant word
	//parameter [3:0] WRITE2 = 4'd9;			// Write least significant word then Terminate Write
	//
	
	// Delay Variables
	parameter [1:0] CAS_LATENCY = 2'd2;
	
	reg [1:0] readWait;
	//
	
	// Data storage
	reg [31:0] lowWord;		// Store least signifcant part of data for output
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
	always@(curState,go) begin
		case(curState)
			IDLE: begin
				if(go)
					nextState = ACTIVE;
				else
					nextState = IDLE;
			end
			ACTIVE: begin
				nextState = ACTIVE_WAIT1;
			end
			ACTIVE_WAIT1: begin
				nextState = ACTIVE_WAIT2;
			end
			ACTIVE_WAIT2: begin
				nextState = READ_BEGIN;
			end
			READ_BEGIN: begin
				nextState = READ_WAIT1;
			end
			READ_WAIT1:
				nextState = READ_WAIT2;
			READ_WAIT2:
				nextState = READ1;
			READ1:begin
				nextState = READ2;
				
			end
			READ2:begin
				nextState = IDLE;
				
			end
			default:
				nextState = IDLE;
		endcase
	end
	//
	
	// Drive data
	assign data = {dram_dq,lowWord};
	//
	
	// Drive Address
	assign dram_addr = 0;
	//
	
	// Drive lowWord
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			lowWord <= 32'b0;
		end else if(curState == READ1) begin
			lowWord <= dram_dq;
		end else begin
			lowWord <= lowWord;
		end
	end
	//
	
	// Drive valid
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			valid <= 1'b0;
			//led[3] <= 1'b1;
		end else if (curState == READ2) begin
			valid <= 1'b1;
			//led[3] <= 1'b1;
		end else
			valid <= 1'b0;
	end
	//
	
	// Drive readWait 
	/*
	always@(posedge clk, negedge rst) begin
		if(~rst) 
			readWait <= 2'd0;
		else if (curState == READ_WAIT)
			readWait <= readWait + 2'd1;
		else	
			readWait <= 2'd0;			
	end
	*/
	//
	

	// Write command RAS = 1 , CAS = 0, WE = 0
	// Read command RAS = 1 , CAS = 0, WE = 1
	// Idle command RAS = 1 , CAS = 1, WE = 1
	// Active command RAS = 0 , CAS = 1, WE = 1
	// Burst Stop command RAS = 1 , CAS = 1, WE = 0
	// No-Op command RAS = 1 , CAS = 1, WE = 1
	
	// Drive RAS, CAS, and WE
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == IDLE) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;		
		end else if(curState == READ_BEGIN) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b0;
			dram_we_n <= 1'b1;
		end else if(curState == READ_WAIT1) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == READ_WAIT2) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;	
		end else if(curState == ACTIVE) begin
			dram_ras_n <= 1'b0;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == ACTIVE_WAIT1) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == ACTIVE_WAIT2) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == READ1) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;	
		end else begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end						
	end		
	//
	
	// Drive/Read dram_dq
	/*
	always@(posedge clk, negedge rst) begin
		if(~rst)
			dram_dq <= 32'hzzzzzzzz;
		else if(curState == READ1) begin
			mostSigWord <= dram_dq;
		end else if(curState == READ2) begin			
			data_in <= {mostSigWord,dram_dq};
			in_valid <= 1'b1;
		end else
			dram_dq <= 32'hzzzzzzzz;
		
	end
	*/
	//
	
	// Drive curReadAddr
	/*
	always@(posedge clk, negedge rst) begin
		if(~rst)
			curReadAddr <= 10'b0000000000;
		else if(curState == READ2 )
			curReadAddr <= curReadAddr + 2;
		else
			curReadAddr <= curReadAddr;
	end	
	*/	
	//
	
	// Drive curWriteAddr
	/*
	always@(posedge clk, negedge rst) begin
		if(~rst)
			curWriteAddr <= 10'b0000000000;
		else if(curState == WRITE2)
			curWriteAddr <= curWriteAddr + 2;
		else
			curWriteAddr <= curWriteAddr;
	end	
	*/
	//
	
	
endmodule



