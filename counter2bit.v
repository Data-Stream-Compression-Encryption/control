// 2-bit counter module
// ==============================
// 2-bit counter for selecting bewteen data and encryption
//   keys in data stream compression and encryption top
//   level module
// ==============================
// Author: Alex Clarke
// Date: 2/23/2015

`timescale 1 ns/ 1 ps

module counter2bit(clk,rst,in_valid,key_config,counter_value);
  input clk;
  input rst;
  
  input in_valid;             // Signal indicating that the counter should increment (Device should configure the next encryption key)
  input key_config;           // Enable the counter -- if key_config low the counter should reset to 0
  
  output [1:0] counter_value; // Counter value output, mirrors count reg 
    
  reg [1:0] count;            // Counter value, counts 0 to 3
  reg in_valid_last_sampled;  // If key_config is high, this value will be high if invalid was last sampled high, low if low.  If key_config is low, this value will be low

  assign counter_value = count;

  always@(posedge clk, posedge rst) begin
    if(rst == 1'b1) begin
      count <= 2'b0;
      in_valid_last_sampled <= 1'b0;
    end else if(key_config == 1'b0) begin
      count <= 2'b0;
      in_valid_last_sampled <= 1'b0;
    end else
      if( in_valid == 1'b1 ) begin
        if( in_valid_last_sampled == 1'b0 )
          count <= count + 2'b1;
        in_valid_last_sampled <= 1'b1;
      end else
        in_valid_last_sampled <= 1'b0;     
  end
  
  

endmodule