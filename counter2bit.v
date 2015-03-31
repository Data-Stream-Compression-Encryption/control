// 2-bit counter module
// ==============================
// 2-bit counter for selecting bewteen data and encryption
//   keys in data stream compression and encryption top
//   level module
// ==============================
// Author: Alex Clarke
// Date: 2/23/2015

`timescale 1 ns/ 1 ps

module counter2bit(rst,in_valid,key_config,count);
  input rst;
  
  input in_valid;             // Signal indicating that the counter should increment (Device should configure the next encryption key)
  input key_config;           // Enable the counter -- if key_config low the counter should reset to 0
  
  output reg [1:0] count; // Counter value output, mirrors count reg 
    

  always@(posedge in_valid, posedge rst) begin
    if(rst == 1'b1) begin
      count <= 2'b0;
    end else if(key_config == 1'b0) begin
      count <= 2'b0;
    end else
      count <= count + 2'b1;   
         
  end
  
  

endmodule