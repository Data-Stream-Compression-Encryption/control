// Shift concatenation module
// ==============================
// Takes inputs of various lengths from 1 to 64 bits (data_in) 
//    and "stacks" those inputs into 64 bit segments (data_out)

`timescale 1 ns/ 1 ps

module shift_concat(clk, rst, data_in, data_valid, valid_bits, msg_fin, data_out, done);
  input [63:0] data_in;       // Data to "shift concatenate"
  input [6:0] valid_bits;     // Indicates number of valid bits in a particular input
  input data_valid;           // Indicates that the data on data_in is valid
  input msg_fin;              // Indicates for the module to output remaining data regardless of completeness 
  
  output done;
  output [63:0] data_out;
  
  reg [127:0] concat_reg;     // Register for "stacking" input segments
  reg [7:0] concat_reg_valid; // Indicates the number of valid bits in the least significant 64 bits ot the concat_reg
  reg init_reg;             
  reg msg_fin_reg;
  
  
  
  // Drive concat_reg
  always@(posedge clk, posedge rst)
    if( rst )
      concat_reg <= 0;     
    else if( data_valid )
      concat_reg <= (concat_reg)|(data_in << concat_reg_valid);
    else
      concat_reg <= concat_reg;   
  end
  
  // Drive concat_reg_valid
  always@(posedge clk, posedge rst)
    if( rst )
      concat_reg_valid <= 0;     
    else begin                  
      if( (data_valid) && (concat_reg_valid >= 64) )
        concat_reg_valid <= concat_reg_valid + valid_bits - 64;
      else if(concat_reg_valid >= 64)
        concat_reg_valid <= concat_reg_valid - 64;
      else if(data_valid)
        concat_reg_valid <= concat_reg_valid + valid_bits;
      else if(msg_fin_reg)
        concat_reg_valid <= 0; 
      else
        concat_reg_valid <= concat_reg_valid;   
    end
  end

  //



endmodule

