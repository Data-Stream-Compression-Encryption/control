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

reg [63:0] tempData;
	

mem_con u1(.clk(clk), .rst(rst) ,.dram_addr(dram_addr), .dram_ba(dram_ba), .dram_cas_n(dram_cas_n), .dram_cke(dram_cke), .dram_clk(dram_clk), .dram_cs_n(dram_cs_n), .dram_dq(dram_dq), .dram_dqm(dram_dqm), .dram_ras_n(dram_ras_n), .dram_we_n(dram_we_n), .dataToWrite(dataToWrite), .dataToRead(dataToRead), .address(address), .w_rn(w_rn), .go(go), .valid(valid), .led(led));
	

initial begin
rst = 1;
#40 rst = 0;
#40 rst = 1;
	  
end

always@(posedge clk, negedge rst)begin
	if(~rst) begin
		w_rn <= 1'b0;
		go <= 1'b1;
		address<=13'd0;
		dataToWrite <= 64'h000000190000001a;//64'hdeadbeefb00b1e50;
	end else if(valid)begin
		if(w_rn)begin
			go <= 1'b0;
			w_rn <= 1'b0;
			address<=13'd0;
		end else begin		
			go <= 1'b0;
			tempData <= dataToRead;
			w_rn <= 1'b1;
			address<=13'd0;
		end

	end else	begin
		go <= 1'b1;
		
		

	end
		
end




  
endmodule