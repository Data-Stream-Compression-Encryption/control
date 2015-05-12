// Top-level control module
// ==============================
// Handles control signals for top-level data stream compression and encryption module
// ==============================
// Author: Alex Clarke
// Date: 2/20/2015

`timescale 1 ns/ 1 ps

module control(clk,rst,key_config,in_valid,out_rcvd,rdy,error,error_code,out_valid,comp_rdy,stall, scon_done, valid_bits, valid_to_comp);
  input clk;                
  input rst;
  
  input key_config;             // Indicates that encryption keys are being configured 
  input in_valid;               // Indicates that valid input is present on the bus
  input out_rcvd;               // Indicates that the DSEC receiving device has recieved outputted data
  input [6:0] valid_bits;       // Indicates the number of valid bits presented on the output of the compression module
  
  
  output reg stall;             // Indicates that all modules should maintain state (Asychronous)
  output reg rdy;               // Indicates that the DSEC module is ready to recieve data  
  output reg [63:0] error_code; // Identifies the last error encountered based on code
  output reg error;             // Indicates that an error occurred
  output reg out_valid;         // Indicates that the output of the DSEC module is valid
  //output reg dump_comp;         // Indicates to the compression module to send remaining data
  output reg valid_to_comp;     // Indicates that the data input to the compression module is valid
  
  input comp_rdy;               // Indicates that the compression module is ready for input
  //input encry_rdy;              // Indicates that the encryption module is ready for input
  input scon_done;              // Indicates that the shift-concatenation module has compiled 64-bits and the output of the module is now valid

  reg data_rcvd;                // Indicates whether data on the output of the top-level module has been received since the last new data was put on the bus
  
  
  // reg error_reg;             // Indicates error
  // wire out_rcvd_since_done;  // Indicates whether out_rcvd was driven high since the last done was driven high
  
  // ==============================
  // Register drivers
  // ==============================
  
  always@( out_rcvd, rst, out_valid, data_rcvd)
    if(~rst)
      data_rcvd <= 1'b0;
    else if(out_valid == 1'b0)
      data_rcvd <= 1'b0;
    else if(out_rcvd == 1'b1)
      data_rcvd <= 1'b1;
    else
      data_rcvd <= data_rcvd;

  
  // ==============================
  // Output drivers
  // ==============================
  
  // Drive stall signal
  always@(key_config,data_rcvd,error) begin
    if( key_config == 1'b1 )
      stall = 1'b1;
    else if( error == 1'b1)
      stall = 1'b1;
    else
      stall = 1'b0;   
  end
  
  // Drive rdy signal
  always@(comp_rdy) begin
    if(comp_rdy == 1'b1)
      rdy = 1'b1;
    else
      rdy = 1'b0;
  end
  
  // Drive valid_to_comp
  always@(in_valid,key_config) begin
    if( key_config )
      valid_to_comp = 1'b0;
    else if( ~in_valid )
      valid_to_comp = 1'b0;
    else
      valid_to_comp = 1'b1;
  end
  
  // Drive error code
  
  
  // Drive error
  always@(in_valid,rdy) begin
		error <= 1'b0; 
		/*
    if(in_valid && ~rdy && ~key_config)
      error <= 1'b1;
    else
      error <= 1'b0;       
		*/
  end
  
  // Drive out_valid 
  always@(posedge clk, negedge rst) begin
    if(~rst)
      out_valid <= 1'b0;
    else if(key_config)
      out_valid <= 1'b0;
    else if(scon_done)
      out_valid <= 1'b1;
    else
      out_valid <= 1'b0;
      
  end

  
  
endmodule