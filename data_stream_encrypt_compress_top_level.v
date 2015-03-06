/*

Author: Alex Clarke
Date: 2/23/2015

This module implements the top-level block for the Data-stream encryption and compression device.

*/

`timescale 1 ns/ 1 ps

module dsec(clk,rst,data_in,key_config,in_valid,out_rcvd,rdy,data_out,error,done);
  input clk;
  input rst;
  
  input [63:0] data_in;
  input key_config;
  input in_valid;
  input out_rcvd;
  
  output rdy;
  output [63:0] data_out;
  output error;
  output done;  
  
  reg [63:0] key1, key2, key3;
  wire [1:0] counter_value;
  
  wire[63:0] comp_in, comp_out, encrypt_in, encrypt_out;
  wire[6:0] valid_bits;
  
  wire msg_fin, concat_in_valid, concat_done, stall;
  
  // Modules
  counter2bit u1(.clk(clk),.rst(rst),.in_valid(in_valid),.key_config(key_config),.counter_value(counter_value));
  shift_concat u2(.clk(clk),.rst(rst),.stall(stall),.data_in(comp_out),.data_valid(concat_in_valid),.valid_bits(valid_bits),.msg_fin(msg_fin),.data_out(encrypt_in),.done(concat_done));
  
  // Route data_in to encryption module for setting encryption keys
  assign comp_in = ( counter_value == 0 )? data_in : 64'bx;
  
  always@(counter_value, rst)
    if( ~rst )      
      case(counter_value)
        00: begin
          key1 <= 64'bx; 
          key2 <= 64'bx;
          key3 <= 64'bx;
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
      key1 <= 64'bx; 
      key2 <= 64'bx;
      key3 <= 64'bx;
    end



endmodule
