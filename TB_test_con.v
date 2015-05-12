/*

Author: Alex Clarke
Date: 3/24/2015

This module tests the top level DSEC module

*/

`timescale 1 ns/ 1 ps

module TB_test_con;

reg clk;
reg rst;


// Generate a 50 MHz clock
initial
	clk = 1'b0;
always
	#10 clk = ~clk; 
	
	
wire [12:0]		DRAM_ADDR;
wire [1:0]			DRAM_BA;
wire 							DRAM_CAS_N;
wire							DRAM_CKE;
wire							DRAM_CLK;
wire							DRAM_CS_N;
wire	[31:0]		DRAM_DQ;
wire	[3:0]			DRAM_DQM;
wire							DRAM_RAS_N;
wire							DRAM_WE_N;

wire 	[63:0] 		dataToWrite;
wire [63:0] 		dataToRead;
wire  	[12:0] 		address;
wire									w_rn;					//Indicates whether to write (1) or read (0)
wire									go;
wire								valid;
wire	[17:0] 		LEDR;

wire dsec_out_valid;
wire dsec_in_valid;
wire dsec_rdy;
wire dsec_out_rcvd;
wire [63:0] fromTest;
wire key_config;


reg [63:0] tempData;
	
mem_con u1(.clk(clk),.rst(rst),.dram_addr(DRAM_ADDR), .dram_ba(DRAM_BA), .dram_cas_n(DRAM_CAS_N), .dram_cke(DRAM_CKE), .dram_clk(DRAM_CLK), .dram_cs_n(DRAM_CS_N), .dram_dq(DRAM_DQ), .dram_dqm(DRAM_DQM), .dram_ras_n(DRAM_RAS_N), .dram_we_n(DRAM_WE_N), .dataToWrite(dataToWrite), .dataToRead(dataToRead), .address(address), .w_rn(w_rn), .go(go), .valid(ramValid),.led(LEDR[9:0]));
test_con u2(.clk(clk),.rst(rst), .address(address), .w_rn(w_rn), .go(go), .memValid(ramValid), .dsec_out_valid(dsec_out_valid), .dsec_in_valid(dsec_in_valid), .dsec_rdy(dsec_rdy),.key_config(key_config),  .out_rcvd(dsec_out_rcvd) , .fromTest(fromTest) , .dataToRead(dataToRead) ,  .ledr(LEDR[17:10]));
dsec u3(.clk(clk),.rst(rst),.data_in(fromTest),.key_config(key_config),.in_valid(dsec_in_valid),.out_rcvd(dsec_out_rcvd),.rdy(dsec_rdy),.data_out(dataToWrite),.error(error),.out_valid(dsec_out_valid));


parameter [31:0] fileEnd = 10000;
initial begin
	rst = 1'b1;
	#40 rst = 1'b0;
	#40 rst = 1'b1;	  
end

reg [9:0] pb;

always@(posedge clk, negedge rst) begin
	if(~rst)begin
		pb <= 10'd0;
	end else if( valid && ~w_rn ) begin
		pb[0] <= 1'b0;
		pb[1] <= pb[0];
		pb[2] <= pb[1];
		pb[3] <= pb[2];
		pb[4] <= pb[3];
		pb[5] <= pb[4];
		pb[6] <= pb[5];
		pb[7] <= pb[6];
		pb[8] <= pb[7];
		pb[9] <= pb[8];
	end else begin
	end
end
  
endmodule