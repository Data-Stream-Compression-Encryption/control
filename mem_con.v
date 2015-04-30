


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

	
	//assign dram_we_n = 1'b1;
	assign dram_ba = 2'b00;
	assign dram_dqm = 4'b0;
	
	//assign dram_dq = 32'habcdef10;

	

	
	// State Variables
	reg [3:0] curState;
	reg [3:0] nextState;
	//
	
	// States
	parameter [3:0] IDLE = 4'd0;				// Do nothing
	parameter [3:0] ACTIVE = 4'd1;			// Activate RAM row or whatever
	parameter [3:0] READ_BEGIN = 4'd2;		// Set RAM module for reading
	parameter [3:0] READ_WAIT1 = 4'd3;		// Wait for CAS latency 
	parameter [3:0] READ_WAIT2 = 4'd4;		// Wait for CAS latency 
	parameter [3:0] READ1 = 4'd5;				// Read incoming data first half
	parameter [3:0] ACTIVE_WAIT1 = 4'd6;	// Wait 2 clocks cycles for row to be activated (1st clock)
	parameter [3:0] ACTIVE_WAIT2 = 4'd7;	// Wait 2 clocks cycles for row to be activated (2nd clock)			
	parameter [3:0] READ2 = 4'd8;				// Read incoming data second half
	parameter [3:0] WRITE1 = 4'd9;			// Set RAM module for writing and write least significant word
	parameter [3:0] WRITE2 = 4'd10;			// Write most significant word
	parameter [3:0] TERMINATE = 4'd11;		// Terminate current action
	//
	
	// Delay Variables
	parameter [1:0] CAS_LATENCY = 2'd2;
	
	reg [1:0] readWait;
	//
	
	// Data storage
	reg [63:0] writeData;   // Store data for writing
	//
	
	// Current Command (read=0, write=1)
	reg command;

	
	// State Transitions 	
	always@(posedge clk, negedge rst) begin
			if(~rst) 
				curState <= IDLE;
			else	
				curState <= nextState;	
	end
	//
	
	// State Machine
	always@(curState,go,command) begin
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
			READ_WAIT2:
				nextState = READ1;
			READ1:begin
				nextState = READ2;				
			end
			READ2:begin
				nextState = TERMINATE;				
			end
			WRITE1:begin
				nextState = WRITE2;				
			end
			WRITE2:begin
				nextState = TERMINATE;				
			end
			TERMINATE:begin
				nextState = IDLE;				
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
		end else if (curState == READ2) begin
			valid <= 1'b1;
		end else if (curState == TERMINATE && command == 1'b1) begin
			valid <= 1'b1;
		end else
			valid <= 1'b0;
	end
	//
	
	
	// Drive Address
	assign dram_addr = 0;
	//
	
	
	// Drive dram_dq
	assign dram_dq = (~rst)? 32'hzzzzzzzz :
		(curState == WRITE1)? writeData[63:32] :
		(curState == WRITE2)? writeData[31:0] :
		32'hzzzzzzzz;
	//
	
	
	// Drive dataToRead
	always@(posedge clk ,negedge rst) begin
		if(~rst) begin
			dataToRead <= 64'b0;
			led[7] <= 1'b0;
		end else if(curState == READ1) begin
			dataToRead <= {dram_dq,32'b0};  
		end else if(curState == READ2) begin
			dataToRead <= {dram_dq,dataToRead[31:0]};  // down showing data  //{msw,lsw}
			led[7] <= 1'b1;
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
	
	// Write and Read
	parameter WRITE = 1'b1;
	parameter READ = 1'b1;
	//
	
	// Drive command
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			command <= 1'b0;
		end else if (go && curState == IDLE) begin
			command <= w_rn;
		end else
			command <= 1'b0;
	end
	//
	

	// Write command RAS = 1 , CAS = 0, WE = 0
	// Read command RAS = 1 , CAS = 0, WE = 1
	// Idle command RAS = 1 , CAS = 1, WE = 1
	// Active command RAS = 0 , CAS = 1, WE = 1
	// Burst TERMINATE command RAS = 1 , CAS = 1, WE = 0
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
		end else begin
			dram_ras_n <= 1'b1;
			dram_cas_n <= 1'b1;
			dram_we_n <= 1'b1;
		end						
	end		
	//
	
	
	// TEST/TROUBLESHOOTING
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			
			led[17] <= 1'b0;
			led[16] <= 1'b0;
			led[15] <= 1'b0;
			led[14] <= 1'b0;
			
			led[13] <= 1'b0;
			led[12] <= 1'b0;
			led[11] <= 1'b0;
			led[10] <= 1'b0;
		end else if(dram_dq == 32'hffffffff) begin
			if(curState == READ1) begin
				led[17] <= 1'b1;
			end if(curState == READ2) begin
				led[16] <= 1'b1;
			end else if(curState == IDLE)begin
				led[15] <= 1'b1;
			end else begin
				led[14] <= 1'b1;
			end
		end else if(dram_dq == 32'h00000000) begin
			if(curState == READ1) begin
				led[13] <= 1'b1;
			end if(curState == READ2) begin
				led[12] <= 1'b1;
			end else if(curState == IDLE)begin
				led[11] <= 1'b1;
			end else begin
				led[10] <= 1'b1;
			end
		end else begin
		end
		
		
	end
	//
	
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			led[0] <= 1'b0;
			led[1] <= 1'b0;
		end else if(ACTIVE_WAIT2) begin
				if(~command) begin
					led[0] <= 1'b1;
				end else begin
					led[1] <= 1'b1;
				end	
		end else begin
		
		end		
	end
	
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			led[9] <= 1'b0;
			led[8] <= 1'b0;
		end else if(curState == READ2) begin
			if(dataToWrite == 64'h0000000000000000)begin
				led[9] <= 1'b1;
			end else if(valid == 1'b0)begin
				led[8] <= 1'b1;
			end else begin
			end
		end else begin
		end
		
	end
		

	
	
endmodule



