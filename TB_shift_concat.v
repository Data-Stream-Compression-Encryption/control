// Define the stimulus module -- Note the toplevel Stimulus module
//	has no ports!

`timescale 1 ns/ 1 ps

module TB_shift_concat;


// Declare the inputs to be connected
reg clk;
reg rst;
reg [63:0] test_value;
reg [6:0] valid_bits;
reg stall;
//reg data_valid;
reg msg_fin;

wire [63:0] out_value;
wire done;




// Instantiate the Module to be tested
shift_concat U1(.clk(clk),.rst(rst),.stall(stall),.data_in(test_value),.valid_bits(valid_bits),.msg_fin(msg_fin),.data_out(out_value),.done(done));
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
  //data_valid = 1'b0;
  msg_fin = 1'b0;
  rst = 1;
  stall = 0;
  #4 rst = 0;
  #8 rst = 1;
 
  while(1) begin
	 #20 test_value = 64'h000abcdef1234567;
	 msg_fin = 1'b0;
	 valid_bits = 7'd52;
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0;
	
	 #20 test_value = 64'h000000000000000e;	 	
	 msg_fin = 1'b0;
	 valid_bits = 7'd4;
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0;
	
   #20 test_value = 64'h000000000000ebf3;	 	
	 msg_fin = 1'b0;
	 valid_bits = 7'd16;
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0;
	
	 #20 test_value = 64'h00000000000000ec;	 	
	 msg_fin = 1'b0;
	 valid_bits = 7'd8;
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0;
	
	 #20 test_value = 64'hfedcba9876543210;	 	
	 msg_fin = 1'b0;
	 valid_bits = 7'd64;
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0;
	 msg_fin = 1'b1;
	
	 #20 test_value = 64'hfedcba9876543210;
	 msg_fin = 1'b0;
	 valid_bits = 7'd0;	
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0; 
	 
	 #20 test_value = 64'hfedcba9876543210;	 
	 msg_fin = 1'b0;
	 valid_bits = 7'd0;	
	 //#10 data_valid = 1'b1;
	 //#10 data_valid = 1'b0; 
	 
	end
	
end
	





endmodule
