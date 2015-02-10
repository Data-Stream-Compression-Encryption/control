// Define the stimulus module -- Note the toplevel Stimulus module
//	has no ports!

`timescale 1 ns/ 1 ps

module TB_shift_concat;


// Declare the inputs to be connected
reg clk;
reg rst;
reg [63:0] test_value;
reg [6:0] valid_bits;
reg data_valid;
reg msg_fin;

wire [63:0] out_value;
wire done;




// Instantiate the Module to be tested
shift_concat U1(.clk(clk),.rst(rst),.data_in(test_value),.valid_bits(valid_bits),.data_valid(data_valid),.msg_fin(msg_fin),.data_out(out_value),.done(done));
// Stimulate the inputs

// Define the input stimulus module

// Generate a 50 MHz clock
initial
	clk = 1'b0;
always
	#10 clk = ~clk;

// Toggle the SW inputs	
initial begin
  test_value = 64'h0;
  valid_bits = 7'b0;
  data_valid = 1'b0;
  msg_fin = 1'b0;
  rst = 0;
  #4 rst = 1;
  #8 rst = 0;
 
  while(1) begin
	 test_value = 64'h000abcdef1234567;
	 valid_bits = 7'd52;	
	 msg_fin = 1'b0;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0;
	
	 test_value = 64'h000000000000000e;
	 valid_bits = 7'd4;	
	 msg_fin = 1'b0;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0;
	
   test_value = 64'h000000000000ebf3;
	 valid_bits = 7'd16;	
	 msg_fin = 1'b0;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0;
	
	 test_value = 64'h00000000000000ec;
	 valid_bits = 7'd8;	
	 msg_fin = 1'b0;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0;
	
	 test_value = 64'hfedcba9876543210;
	 valid_bits = 7'd64;	
	 msg_fin = 1'b1;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0;
	 msg_fin = 0'b1;
	
	 test_value = 64'hfedcba9876543210;
	 valid_bits = 7'd0;	
	 msg_fin = 1'b0;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0; 
	 
	 test_value = 64'hfedcba9876543210;
	 valid_bits = 7'd0;	
	 msg_fin = 1'b0;
	 #10 data_valid = 1'b1;
	 #10 data_valid = 1'b0; 
	 
	end
	
end
	





endmodule
