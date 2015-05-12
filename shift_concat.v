// Shift concatenation module
// ==============================
// Takes inputs of various lengths from 1 to 64 bits (data_in) 
//    and "stacks" those inputs into 64 bit segments (data_out)
// ==============================
// Author: Alex Clarke
// Date: 2/2/2015

`timescale 1 ns/ 1 ps

module shift_concat(clk, rst, stall, data_in,  valid_bits, msg_fin, data_out, done);
  input clk;
  input rst;
  input stall;
  
  input [63:0] data_in;       	// Data to "shift concatenate"
  input [6:0] valid_bits;     		// Indicates number of valid bits in a particular input
  input msg_fin;              		// Indicates for the module to output remaining data regardless of completeness 
  
  output done;               // Indicates to subsequent modules that the output is valid
  output [63:0] data_out;     // Data output
  

  reg [127:0] concatReg;     	// Register for "stacking" input segments
  reg [5:0] totalValidBits; 			// Indicates the number of valid bits in the least significant 64 bits ot the concat_reg            
	reg msgFinReg;								// Record whether a message done signal has been sent
  
	wire [127:0] shiftedZeroFilledInput;	// Shifted and zero fill input
	wire [127:0] ordInputWithPrevious;  // Value of or'd and processed previous value
	wire [127:0] previous;										// processed previous value
	wire [127:0] shiftedConcatReg;				// shifted concat_reg
	reg overflow;  															// Overflow signal for valid addition
	wire [6:0] validAddition;									// Addition of previous and new valid bits
	wire [63:0] maskedInput	;								// Input with non-valid bits changed to 0 to avoid rare bugs
	
	// Drive shiftedZeroFilledInput
	assign shiftedZeroFilledInput = (maskedInput	 << totalValidBits);
	//
	
	// Drive ordInputWithPrevious
	assign ordInputWithPrevious = shiftedZeroFilledInput | previous;
	//
	
	// Drive previous 
	assign previous = (overflow)? shiftedConcatReg : concatReg;
	//		
	
	// Drive shiftedConcatReg
	assign shiftedConcatReg = (concatReg >> 7'd64);
	//
	
	// Drive validAddition
	assign validAddition = ({1'b0,totalValidBits} + valid_bits);
	//
	
	// Drive masked input
	assign maskedInput	= data_in & ( 64'hffffffffffffffff >> (7'd64 - valid_bits));
	//
	
	// Drive done
	assign done = overflow;
	//		
	
	// Drive data_out
	assign data_out = concatReg[63:0];
	//
	
	// Drive concatReg
	always@(posedge clk, negedge rst) begin
    if( ~rst ) begin
			concatReg <= 128'd0;
		end else begin
			concatReg <= ordInputWithPrevious;
		end
  end
  //
	
	// Drive totalValidBits
	always@(posedge clk, negedge rst) begin
    if( ~rst ) begin
			totalValidBits <= 6'd0;
		end else if(msgFinReg) begin
			totalValidBits <= valid_bits[5:0];
		end else begin
			totalValidBits <= validAddition[5:0];
		end
  end
  //

	
	// Drive overflow
	always@(posedge clk, negedge rst) begin
    if( ~rst ) begin
			overflow <= 1'd0;
		end else if(msgFinReg && totalValidBits != 6'd0) begin
			overflow <= 1'b1;
		end else begin
			overflow <= validAddition[6];
		end
  end
  //
	
	// Drive msgFinReg
	always@(posedge clk, negedge rst) begin
    if( ~rst ) begin
			msgFinReg <= 1'd0;
		end else if (msg_fin) begin
			msgFinReg <= 1'b1;
		end else if (totalValidBits == 6'd0) begin
			msgFinReg <= 1'd0;
		end else begin
			msgFinReg <= msgFinReg ;
		end
  end
	//
	
	
endmodule


