// Shift concatenation module
// ==============================
// Takes inputs of various lengths from 1 to 64 bits (data_in) 
//    and "stacks" those inputs into 64 bit segments (data_out)

`timescale 1 ns/ 1 ps

module shift_concat(clk, rst, data_in, data_valid, valid_bits, msg_fin, data_out, done);
  input clk;
  input rst;
  
  input [63:0] data_in;       // Data to "shift concatenate"
  input [6:0] valid_bits;     // Indicates number of valid bits in a particular input
  input data_valid;           // Indicates that the data on data_in is valid
  input msg_fin;              // Indicates for the module to output remaining data regardless of completeness 
  
  output done;                // Indicates to subsequent modules that the output is valid
  output [63:0] data_out;     // Data output
  
  reg [127:0] concat_reg;     // Register for "stacking" input segments
  reg [7:0] concat_reg_valid; // Indicates the number of valid bits in the least significant 64 bits ot the concat_reg            
  reg msg_fin_reg;
  
  wire [63:0] valid_mask;
  
  // ==============================
  // Output drivers
  // ==============================
  
  assign data_out = concat_reg;
  assign done = ( concat_reg_valid >= 64 )? 1 : 
                  (msg_fin_reg)? 1 : 
                  0 ;
                  
  assign valid_mask = 64'hffffffffffffffff >> (64 - valid_bits);
  
  // ==============================
  // register drivers
  // ==============================
  
  // Drive concat_reg
  always@(posedge clk, posedge rst)
    if( rst )
      concat_reg <= 0;     
    else if( (data_valid) && (concat_reg_valid >= 64) )
      concat_reg <= ((data_in & valid_mask) << concat_reg_valid - 64) | (concat_reg >> 64);
    else if(concat_reg_valid >= 64)
      concat_reg <= concat_reg >> 64;
    else if(data_valid && (valid_bits != 64'b0))  
      concat_reg <= (concat_reg)|((data_in & valid_mask) << concat_reg_valid);
    else if (msg_fin_reg)
      concat_reg <= 0; 
    else
      concat_reg <= concat_reg;   
  
  
  // Drive concat_reg_valid
  always@(posedge clk, posedge rst)
    if( rst )
      concat_reg_valid <= 0;     
    else begin                  
      if( (data_valid) && (concat_reg_valid >= 64) )
        concat_reg_valid <= concat_reg_valid + valid_bits - 64;
      else if(concat_reg_valid >= 64)
        concat_reg_valid <= concat_reg_valid - 64;
      else if(data_valid && (valid_bits != 64'b0) )
        concat_reg_valid <= concat_reg_valid + valid_bits;
      else if(msg_fin_reg)
        concat_reg_valid <= 0; 
      else
        concat_reg_valid <= concat_reg_valid;   
    end

  // Drive msg_fin_reg
  always@(posedge clk, posedge rst)
    if( rst )
      msg_fin_reg <= 0;     
    else if( msg_fin )
      msg_fin_reg <= 1;
    else if( concat_reg_valid <= 64 )
      msg_fin_reg <= 0;
    else
      msg_fin_reg <= msg_fin_reg;   



endmodule

