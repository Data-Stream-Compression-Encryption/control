/*

Author: Alex Clarke
Date: 2/23/2015

This module implements a 2-bit counter for data stream encryption and compression top-level module.

*/

module TB_counter2bit();

  reg clk;
  reg rst;
  reg key_config;
  reg in_valid;
  wire [1:0] counter;
  
  // Generate a 50 MHz clock
  initial
	 clk = 1'b0;
  always
	 #10 clk = ~clk;

  counter2bit u1(.clk(clk),.rst(rst),.in_valid(in_valid),.key_config(key_config),.counter_value(counter));


  // Toggle the SW inputs	
  initial begin
	 key_config <= 0;
	 in_valid <= 0;
	 rst <= 1;
	 
	 
	 #15 rst = 0;
	 key_config = 1;
	 in_valid = 1;
	 #20 in_valid = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;	
	 #50 key_config = 0; 
	 
	 #10 key_config = 1;
	 in_valid = 1;
	 #20 in_valid = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;
	 #50 key_config = 0;
	 
	 #10 key_config = 1;
	 in_valid = 1;
	 #20 in_valid = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;
	 #5 rst = 1;
	 #5 rst = 0;
	 #10 in_valid = 1;
	 #20 in_valid = 0;	
	 #50 key_config = 0; 
	 
	 #10 key_config = 1;
	 in_valid = 1;
	 #20 in_valid = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;
	 #5 rst = 1;
	 #15 in_valid = 1;
	 #20 in_valid = 0;	
	 #50 key_config = 0; 
	 
	 #20 rst = 0;
	 #10 key_config = 1;
	 in_valid = 1;
	 #20 in_valid = 0;
	 key_config = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;
	 #20 in_valid = 1;
	 #20 in_valid = 0;	
	 #50 key_config = 0; 
  end 



endmodule