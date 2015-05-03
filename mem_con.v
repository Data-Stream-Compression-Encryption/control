


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

`timescale 1 ns/ 1 ps

module mem_con(clk, rst,dram_addr, dram_ba, dram_cas_n, dram_cke, dram_clk, dram_cs_n, dram_dq, dram_dqm, dram_ras_n, dram_we_n, dataToWrite, dataToRead, address, w_rn, go, valid, led);
	
	// Clock and active-low reset
	input clk;
	input rst;	
	//

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
	input [63:0] dataToWrite;
	output reg [63:0] dataToRead;
	input [12:0] address;
	input w_rn;					//Indicates whether to write (1) or read (0)
	input go;
	output reg valid;
	output reg [17:0] led;
	//
	
	//
	assign dram_cke = 1'b1;			// Clock Enable Bit
	assign dram_cs_n = 1'b0;		// Command Select - Determines whether command input is enabled within ram - Disabled when high, enabled when low
	//
	
	// Assign clock to RAM clock (Possibly a timing error , may need a PLL)
	assign dram_clk = clk;
	//

	
	assign dram_ba = 2'b00;
	assign dram_dqm = 4'b0;
	
	//assign dram_dq = 32'habcdef10;

	

	
	// State Variables
	reg [4:0] curState;
	reg [4:0] nextState;
	//
	
	// Write command RAS = 1 , CAS = 0, WE = 0
	// Read command RAS = 1 , CAS = 0, WE = 1
	// Idle command RAS = 1 , CAS = 1, WE = 1
	// Active command RAS = 0 , CAS = 1, WE = 1
	// Burst TERMINATE command RAS = 1 , CAS = 1, WE = 0
	// No-Op command RAS = 1 , CAS = 1, WE = 1
	// Mode Register select (MRS) RAS = 0 , CAS = 0, WE = 0
	// Precharge all banks command RAS = 0  , CAS = 1 , WE = 1
	// Auto Refresh command RAS = 0  , CAS = 0 , WE = 1
	
	// States
	parameter [4:0] IDLE = 5'd0;												// Do nothing
	parameter [4:0] ACTIVE = 5'd1;										// Activate RAM row or whatever
	parameter [4:0] READ_BEGIN = 5'd2;						// Set RAM module for reading
	parameter [4:0] READ_WAIT1 = 5'd3;					// Wait for CAS latency 
	parameter [4:0] READ_WAIT2 = 5'd4;					// Wait for CAS latency 
	parameter [4:0] READ1 = 5'd5;										// Read incoming data first half
	parameter [4:0] ACTIVE_WAIT1 = 5'd6;				// Wait 2 clocks cycles for row to be activated (1st clock)
	parameter [4:0] ACTIVE_WAIT2 = 5'd7;				// Wait 2 clocks cycles for row to be activated (2nd clock)			
	parameter [4:0] READ2 = 5'd8;										// Read incoming data second half
	parameter [4:0] WRITE1 = 5'd9;									// Set RAM module for writing and write least significant word
	parameter [4:0] WRITE2 = 5'd10;								// Write most significant word
	parameter [4:0] TERMINATE = 5'd11;						// Terminate current action
	parameter [4:0] MRS = 5'd12;											// Mode Register Select - Configure the memory
	parameter [4:0] POWERUP = 5'd13;							// Initial powerup delay state
	parameter [4:0] PRECHARGE_AB = 5'd14;		// Precharge all banks, bust be performed before MRS initialization	
	parameter [4:0] INIT_REFRESH = 5'd15;  		// Required intital refresh operation repeated 8 times
	parameter [4:0] INIT_REFRESH_BACKOFF =5'd16;		// Wait tstat between initial refresh operations
	parameter [4:0] MRS_DELAY	=	5'd17;				// Delay required to set mode register fully
	//
	
	// Delay Variables
	parameter [1:0] CAS_LATENCY = 2'd2;
	
	reg [1:0] readWait;
	reg [12:0] powerupCounter;
	parameter [12:0] POWERUP_WAIT_PERIOD = 13'd5000;
	
	reg [3:0] initRefreshWaitCounter;
	reg [3:0] initRefreshBackoffCounter;	
	parameter [3:0] INIT_REFRESH_PERIOD = 4'd8;
	parameter [3:0] INIT_REFRESH_BACKOFF_PERIOD = 4'd7;
	
	//
	
	// RAM Mode for MRS configuration/////cba9876543210
	parameter [12:0] MEM_MODE = 13'b0001000110001;
	//
	
	
	// Data storage
	reg [63:0] writeData;   // Store data for writing
	reg [31:0] writeDataHalf;
	
	reg [12:0] curAddress;
	//
	
	// Signals
	reg command;			// Current Command (read=0, write=1)
	reg writeNow;
	//
	
	// Command parameters
	parameter WRITE = 1'b1;
	parameter READ = 1'b0;
	//

	
	// State Transitions 	
	always@(posedge clk, negedge rst) begin
			if(~rst) 
				curState <= POWERUP;
			else	
				curState <= nextState;	
	end
	//
	
	// State Machine
	always@(curState,go,command,powerupCounter,initRefreshBackoffCounter, initRefreshWaitCounter) begin
		case(curState)
			IDLE: begin
				if(go)begin
					nextState = ACTIVE;
				end else
					nextState = IDLE;
			end
			ACTIVE: begin
				nextState = ACTIVE_WAIT1;
			end
			ACTIVE_WAIT1: begin
				nextState = ACTIVE_WAIT2;
			end
			ACTIVE_WAIT2: begin
				if(~command) begin
					nextState = READ_BEGIN;
				end else begin
					nextState = WRITE1;
				end					
			end
			READ_BEGIN: begin
				nextState = READ_WAIT1;
			end
			READ_WAIT1:
				nextState = READ_WAIT2;
			READ_WAIT2:begin
				nextState = READ1;
			end
			READ1:begin
				nextState = READ2;				
			end
			READ2:begin
				nextState = IDLE;
			end
			WRITE1:begin				
				nextState = WRITE2;								
			end
			WRITE2:begin
				nextState = IDLE;
			end
			MRS:begin
				nextState = MRS_DELAY;
			end
			MRS_DELAY:begin
				nextState = IDLE;
			end
			POWERUP: begin
				if(powerupCounter > POWERUP_WAIT_PERIOD)begin
					nextState = PRECHARGE_AB;
				end else begin
					nextState = POWERUP;
				end
			end
			PRECHARGE_AB: begin
				nextState = INIT_REFRESH_BACKOFF;
			end
			INIT_REFRESH_BACKOFF:begin
				if(initRefreshBackoffCounter >= INIT_REFRESH_BACKOFF_PERIOD)begin
					if(initRefreshWaitCounter >= INIT_REFRESH_PERIOD)begin
						nextState = MRS;
					end else begin
						nextState = INIT_REFRESH;
					end					
				end else begin
					nextState = INIT_REFRESH_BACKOFF;
				end
			end
			INIT_REFRESH:begin
				nextState = INIT_REFRESH_BACKOFF;
			end
			default:
				nextState = IDLE;
		endcase
	end
	//
	
	// Drive valid
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			valid <= 1'b0;
		end else if (curState==READ2) begin
			valid <= 1'b1;
		end else if (curState==WRITE2) begin
			valid <= 1'b1;
		end else
			valid <= 1'b0;
	end
	//
	
	
	// Drive dram_addr
	assign dram_addr = curAddress;
	//
	
	// Drive curAddress
	always@(negedge clk, negedge rst) begin
		if(~rst) begin	
			curAddress <= 13'b0010000000000;
		end else if(curState == IDLE) begin
			curAddress <= {address[12:11],1'b1,address[9:0]};
		end else if(curState == READ_WAIT1) begin
			curAddress <= curAddress + 13'd1;
		end else if(curState == WRITE2) begin
			curAddress <= curAddress + 13'd1;	
		end else if(curState == POWERUP) begin
			curAddress <= MEM_MODE;
		end else begin
			curAddress <= curAddress;
		end
	end
	//
	
	
	// Drive dram_dq
	assign dram_dq = (writeNow)? writeDataHalf :
		32'hzzzzzzzz;
	//
	
	
	// Drive dataToRead 
	always@(posedge clk ,negedge rst) begin
		if(~rst) begin
			dataToRead <= 64'b0;
			led[0] <= 1'b0;	
			led[1] <= 1'b0;
		end else if(curState == READ1) begin
			dataToRead <= {dram_dq,32'h10101010}; 
			if(curAddress == 13'd0)begin
				led[0] <= 1'b1;
			end else begin
			end
		end else if(curState == READ2) begin
			if(curAddress == 13'd1)begin
				led[1] <= 1'b1;
			end else begin
			end
			dataToRead <= {dataToRead[63:32],dram_dq};  // down showing data  //{msw,lsw}			
		end else begin
			dataToRead <= dataToRead;
		end
	end
	//
	
	// Drive writeData
	always@(posedge clk ,negedge rst) begin
		if(~rst) begin
			writeData <= 64'b0;
		end else if(go == 1'b1 && nextState == ACTIVE && command == WRITE ) begin
			writeData <= dataToWrite;
		end else begin
			writeData <= writeData;
		end
	end
	//
	
	// Drive writeDataHalf and writeNow
	always@(negedge clk ,negedge rst) begin
		if(~rst) begin
			writeDataHalf <= 32'd0;
			writeNow <= 1'd0;
			led[17] <= 1'b0;
			led[16] <= 1'b0;
			led[15] <= 1'b0;
		end else if(curState == WRITE1) begin			
			writeDataHalf <= writeData[63:32];
			writeNow <= 1'd1;
			if(curAddress == 13'd0)begin
				led[17] <= 1'b1;
			end else begin
			end			
		end else if(curState == WRITE2) begin
			writeDataHalf <= writeData[31:0];
			writeNow <= 1'd1;
			if(curAddress == 13'd1)begin
				led[16] <= 1'b1;	
			end else if(curAddress == 13'd0)begin
				led[15] <= 1'b1;
			end else begin
			end
		end else begin
			writeDataHalf <= 32'hdeadbeef;//writeDataHalf;
			writeNow <= 1'd0;
		end
	end
	//
	
	/*
	// Drive writeSecond
	always@(posedge clk ,negedge rst) begin
		if(~rst) begin
			writeSecond <= 1'b0;
			led[4] <= 1'b0;
			led[5] <= 1'b0;
		end else if(curState == IDLE) begin
			writeSecond <= 1'b0;
			led[5] <= 1'b1;
		end else if(nextState == WRITE1) begin
			writeSecond <= 1'b1;
			led[4] <= 1'b1;			
		end else begin
			writeSecond <= writeSecond;
		end
	end
	//
	*/
	
	// Drive command
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			command <= 1'b0;
		end else if (go && curState == IDLE) begin
			command <= w_rn;
		end else
			command <= command;
	end
	//
	

	// Write command RAS = 1 , CAS = 0, WE = 0
	// Read command RAS = 1 , CAS = 0, WE = 1
	// Idle command RAS = 1 , CAS = 1, WE = 1
	// Active command RAS = 0 , CAS = 1, WE = 1
	// Burst TERMINATE command RAS = 1 , CAS = 1, WE = 0
	// No-Op command RAS = 1 , CAS = 1, WE = 1
	// Mode Register select (MRS) RAS = 0 , CAS = 0, WE = 0
	// Precharge all banks command RAS = 0  , CAS = 1 , WE = 1
	// Auto Refresh command RAS = 0  , CAS = 0 , WE = 1
	
	// Drive RAS, CAS, and WE
	always@(negedge clk, negedge rst) begin
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
			dram_cas_n <= 1'b0;
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
		end else if(curState == READ2) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == WRITE1) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b0;
			dram_we_n <= 1'b0;
		end else if(curState == WRITE2) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b0;
			dram_we_n <= 1'b0;
		end else if(curState == TERMINATE) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b0;
		end else if(curState == MRS) begin
			dram_ras_n <= 1'b0;
			dram_cas_n <= 1'b0;
			dram_we_n <= 1'b0;
		end else if(curState == POWERUP) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == PRECHARGE_AB) begin
			dram_ras_n <= 1'b0;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == INIT_REFRESH_BACKOFF) begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end else if(curState == INIT_REFRESH) begin
			dram_ras_n <= 1'b0;
			dram_cas_n <= 1'b0;
			dram_we_n <= 1'b1;
		end else begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end						
	end		
	//

	

		
	// Drive powerupCounter
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			powerupCounter <= 13'd0;
		end else if(curState == POWERUP) begin
			powerupCounter <= powerupCounter + 13'd1;
		end else begin
		end	
	end
	//
	
	// Drive initRefreshWaitCounter
	always@(posedge clk, negedge rst) begin
		if(~rst) begin	
			initRefreshWaitCounter <= 4'd0;
		end else if( curState==INIT_REFRESH )begin
			initRefreshWaitCounter <= initRefreshWaitCounter + 4'd1;
		end else begin
			initRefreshWaitCounter <= initRefreshWaitCounter;
		end
	end
	//
	
	// Drive initRefreshBackoffCounter
	always@(posedge clk, negedge rst) begin
		if(~rst) begin	
			initRefreshBackoffCounter <= 4'd0;
		end else if (curState==INIT_REFRESH_BACKOFF)begin
			initRefreshBackoffCounter <= initRefreshBackoffCounter + 4'd1;
		end else begin
			initRefreshBackoffCounter <= 4'd0;
		end
	end
	//
	

	
	// TroUBLESHOOTING
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			
			led[14] <= 1'b0;
			
			led[13] <= 1'b0;
			led[12] <= 1'b0;
			led[11] <= 1'b0;
			led[10] <= 1'b0;
			led[2] <= 1'b0;
			led[3] <= 1'b0;
		end else if(curState == WRITE1) begin
		end else if(curState == WRITE2) begin
		
		end else begin
		end		
	end
	//
	

	
endmodule



