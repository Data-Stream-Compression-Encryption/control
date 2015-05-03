/*

Author: Alex Clarke
Date: 3/24/2015

This module tests the top level DSEC module

*/

module TB_mem_con;

reg clk;
reg rst;


// Generate a 50 MHz clock
initial
	clk = 1'b0;
always
	#10 clk = ~clk; 
	
	
wire [12:0]		dram_addr;
wire [1:0]			dram_ba;
wire 							dram_cas_n;
wire								dram_cke;
wire								dram_clk;
wire								dram_cs_n;
wire	[31:0]		dram_dq;
wire	[3:0]			dram_dqm;
wire								dram_ras_n;
wire								dram_we_n;

reg  	[63:0] 		dataToWrite;
wire [63:0] 		dataToRead;
reg  	[12:0] 		address;
reg									w_rn;					//Indicates whether to write (1) or read (0)
reg									go;
wire								valid;
wire	[17:0] 		led;

wire out_valid;
wire in_valid;
wire dsec_rdy;


reg [63:0] tempData;
	

mem_con u1(.clk(clk), .rst(rst) ,.dram_addr(dram_addr), .dram_ba(dram_ba), .dram_cas_n(dram_cas_n), .dram_cke(dram_cke), .dram_clk(dram_clk), .dram_cs_n(dram_cs_n), .dram_dq(dram_dq), .dram_dqm(dram_dqm), .dram_ras_n(dram_ras_n), .dram_we_n(dram_we_n), .dataToWrite(dataToWrite), .dataToRead(dataToRead), .address(address), .w_rn(w_rn), .go(go), .valid(valid), .led(led));
test_con u2(.clk(clk),.rst(rst), .address(address), .w_rn(w_rn), .go(go), .memValid(valid), .dsec_out_valid(out_valid), .dsec_in_valid(in_valid), .dsec_rdy(dsec_rdy));

initial begin
rst = 1;
#40 rst = 0;
#40 rst = 1;
	  
end






  
endmodule