/*

Author: Alex Clarke
Date: 3/24/2015

This module tests the top level DSEC module

*/
`timescale 1 ns/ 1 ps

module TB_DSEC;

reg clk;
reg rst;

reg key_config;
reg in_valid;
reg out_rcvd;
reg [63:0] data_in;

wire [63:0] data_out;
wire rdy, error, out_valid;

integer inFile, outFile;

dsec u1(.clk(clk),.rst(rst),.data_in(data_in),.key_config(key_config),.in_valid(in_valid),.out_rcvd(out_rcvd),.rdy(rdy),.data_out(data_out),.error(error),.out_valid(out_valid));
 
// Generate a 50 MHz clock
initial
	clk = 1'b0;
always
	#10 clk = ~clk; 
	
initial begin
	
	inFile = $fopen("testData/testData1.bmp","r");
	outFile = $fopen("testData/testData1Out","w");

  rst = 1'b0;
  #20 rst = 1'b1;
  key_config = 1'b0;
  in_valid = 1'b0;
  out_rcvd = 1'b0;
  
  
  #20 key_config = 1'b1;
  data_in = 64'h1111111111111111;
  #20 in_valid = 1'b1;
  #20 in_valid = 1'b0;
  data_in = 64'h2222222222222222;
  #20 in_valid = 1'b1;
  #20 in_valid = 1'b0;
  data_in = 64'h3333333333333333;
  #20 in_valid = 1'b1;
  #20 in_valid = 1'b0;
  key_config = 1'b0;
  
	while(1) begin
	
		data_in[63:56] =  $fgetc(inFile);
		data_in[55:48] =  $fgetc(inFile);
		data_in[47:40] =  $fgetc(inFile);
		data_in[39:32] =  $fgetc(inFile);
		
		data_in[31:24] =  $fgetc(inFile);
		data_in[23:16] =  $fgetc(inFile);
		data_in[15:8] =  $fgetc(inFile);
		data_in[7:0] =  $fgetc(inFile);
		
		#20 in_valid = 1'b1;
		#20 in_valid = 1'b0;   
		#20 out_rcvd = 1'b1;
		#20 out_rcvd = 1'b0;
		 
		
	end
	
	$fclose(inFile);
	  
end


always@(negedge clk)begin
	if(out_valid) begin
		$fwrite(outFile, "%h", data_out);
	end
end
  
endmodule