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
  
  reg [63:0] key_1, key_2, key_3, comp_in;
  wire [1:0] counter_value;
  
  wire[63:0] comp_out, encrypt_in, encrypt_out, error_code;
  wire[6:0] valid_bits;
  
  wire scon_done, stall, comp_rdy, dump_comp, valid_to_comp, dump;
  
  // Modules
  counter2bit counter2bit1(.rst(rst),.in_valid(in_valid),.key_config(key_config),.count(counter_value));
  shift_concat shift_concat1(.clk(clk),.rst(rst),.stall(stall),.data_in(comp_out),.valid_bits(valid_bits),.msg_fin(dump),.data_out(encrypt_in),.done(scon_done));
  control control1(.clk(clk),.rst(rst),.key_config(key_config),.in_valid(in_valid),.out_rcvd(out_rcvd),.rdy(rdy),.error(error),.error_code(error_code),.out_valid(out_valid),.comp_rdy(comp_rdy),.stall(stall), .scon_done(scon_done),.dump_comp(dump_comp), .valid_bits(valid_bits), .valid_to_comp(valid_to_comp));
  //dummy_compression dummy_compression1(.clk(clk),.rst(rst),.valid_to_comp(valid_to_comp),.valid_bits(valid_bits),.comp_rdy(comp_rdy),.stall_comp(stall),.dump(dump),.data_in(comp_in),.data_out(comp_out));
  Compression_Top #(.COMP_POINT(3)) compression1(.clock(clk), .reset(~rst), .stall(stall), .data_in_valid(valid_to_comp),.data_in(comp_in),.comp_rdy(comp_rdy), .dump(dump),.valid_bits(valid_bits),.data_out(comp_out));
  TripleDES_Encryption TripleDES_Encryption1(.data_in(encrypt_in), .data_out(encrypt_out), .key_1(key_1), .key_2(key_2), .key_3(key_3));
  
  
  //assign comp_in = ( counter_value == 0 )? data_in : 64'bx;
  assign valid_to_comp = ( (counter_value == 0) && in_valid )? 1'b1 : 1'b0;
  
  // Drive encryption key registers
  always@(posedge rst, posedge clk) begin
    if( rst ) begin
      key_1 <= 64'bx; 
      key_2 <= 64'bx;
      key_3 <= 64'bx;
    end else begin        
      case(counter_value)
        2'b00: begin
          comp_in <= data_in;
			 key_1 <= key_1; 
          key_2 <= key_2;
          key_3 <= key_3;
        end
        2'b01: begin
          key_1 <= data_in;
			 key_2 <= key_2;
          key_3 <= key_3;
        end
        2'b10: begin
		    key_1 <= key_1; 
          key_2 <= data_in; 
			 key_3 <= key_3;
        end
        2'b11: begin
          key_1 <= key_1; 
          key_2 <= key_2;
          key_3 <= data_in; 
        end
        default: begin
          key_1 <= key_1; 
          key_2 <= key_2;
          key_3 <= key_3;          
        end
      endcase
    end

  end
    
  always@(error, encrypt_out, error_code)begin
    if(error)
      data_out <= error_code;
    else
      data_out <= encrypt_out;
  end



endmodule
