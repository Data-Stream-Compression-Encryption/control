// Define the stimulus module -- Note the toplevel Stimulus module
//	has no ports!

`timescale 1 ns/ 1 ps

module TB_shift_concat;


// Declare the inputs to be connected
reg clk;
reg [63:0] test_value;
reg [5:0] valid_bits;
reg in_initial;
reg in_zero;

wire [63:0] out_value;
wire scon_done;




// Instantiate the Module to be tested

shift_concat U1(.in(test_value),.out(out_value));
// Stimulate the inputs

// Define the input stimulus module

// Generate a 50 MHz clock
initial
	clk = 1'b0;
always
	#10 clk = ~clk;

// Toggle the SW inputs	
initial begin
	test_value <= 64'h0000000000000001;
	counter <= 4'h0;
end
	





endmodule
