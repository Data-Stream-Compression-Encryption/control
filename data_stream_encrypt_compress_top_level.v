/*

Author: Alex Clarke
Date: 2/23/2015

This module implements the top-level block for the Data-stream encryption and compression device.

*/



module dsec(
  input clk,
  input rst,
  input [63:0] data_in,
  input key_config,
  input in_valid,
  input out_rcvd,
  output rdy,
  output [63:0] data_out,
  output error,
  output done
  );
  
  wire [63:0] comp_in;
  reg [63:0] key1, key2, key3;
  wire [1:0] counter_value;
  
  // Route data_in to encryption module for setting encryption keys
  assign comp_in = ( counter_value == 0 )? data_in : 64'b0;
  
  always@(counter_value, rst)
    if( ~rst )      
      case(counter_value)
        00: begin
        end
        01: begin
          key1 <= data_in;
        end
        10: begin
          key2 <= data_in;
        end
        11: begin
          key3 <= data_in;
        end
        default: begin
        end
      endcase
    else begin
      key1 <= 64'b0; 
      key2 <= 64'b0;
      key3 <= 64'b0;
    end



endmodule
