/*

Author: Alex Clarke
Date: 2/23/2015

This module implements the top-level block for the Data-stream encryption and compression device.

*/

`timescale 1 ns/ 1 ps

module dsec(clk,rst,data_in,key_config,in_valid,out_rcvd,rdy,data_out,error,out_valid);
  input clk;
  input rst;
  
  input [63:0] data_in;
  input key_config;
  input in_valid;
  input out_rcvd;
  
  output rdy;
  output reg [63:0] data_out;
  output error;
  output out_valid;  
  
  reg [63:0] key_1, key_2, key_3;
  wire [1:0] counter_value;
  
  wire[63:0] comp_in, comp_out, encrypt_in, encrypt_out, error_code;
  wire[6:0] valid_bits;
  
  wire msg_fin, scon_done, stall, comp_rdy, dump_comp, valid_to_comp;
  
  // Modules
  counter2bit u1(.clk(clk),.rst(rst),.in_valid(in_valid),.key_config(key_config),.counter_value(counter_value));
  shift_concat u2(.clk(clk),.rst(rst),.stall(stall),.data_in(comp_out),.valid_bits(valid_bits),.msg_fin(msg_fin),.data_out(encrypt_in),.done(concat_done));
  control u3(.clk(clk),.rst(rst),.key_config(key_config),.in_valid(in_valid),.out_rcvd(out_rcvd),.rdy(rdy),.error(error),.error_code(error_code),.out_valid(out_valid),.comp_rdy(comp_rdy),.stall(stall), .scon_done(scon_done),.dump_comp(dump_comp), .valid_bits(valid_bits), .valid_to_comp(valid_to_comp));
  dummy_compression u4(.clk(clk),.rst(rst),.valid_to_comp(valid_to_comp),.valid_bits(valid_bits),.comp_rdy(comp_rdy),.stall_comp(stall),.dump(dump),.data_in(comp_in),.data_out(comp_out));
  TripleDES_Encryption u5(.data_in(encrypt_in), .data_out(encrypt_out), .key_1(key_1), .key_2(key_2), .key_3(key_3));
  
  // Route data_in to encryption module for setting encryption keys
  assign comp_in = ( counter_value == 0 )? data_in : 64'bx;
  
  always@(counter_value, data_in,  rst)
    if( ~rst )      
      case(counter_value)
        00: begin
          key_1 <= 64'bx; 
          key_2 <= 64'bx;
          key_3 <= 64'bx;
        end
        01: begin
          key_1 <= data_in;
        end
        10: begin
          key_2 <= data_in;
        end
        11: begin
          key_3 <= data_in;
        end
        default: begin
        end
      endcase
    else begin
      key_1 <= 64'bx; 
      key_2 <= 64'bx;
      key_3 <= 64'bx;
    end
    
  always@(error, encrypt_out, error_code)begin
    if(error)
      data_out <= error_code;
    else
      data_out <= encrypt_out;
  end



endmodule
