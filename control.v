// Top-level control module
// ==============================
// Handles control signals for top-level data stream compression and encryption module
// ==============================
// Author: Alex Clarke
// Date: 2/20/2015

`timescale 1 ns/ 1 ps

module control(clk,rst,key_config,in_valid,out_rcvd,rdy,error,error_code,out_valid,comp_rdy,encry_rdy,stall);
  input clk;                
  input rst;
  
  input key_config;             // Indicates that encryption keys are being configured so stall all modules
  input in_valid;               // Indicates that valid input is present on the bus, thus modules should proceed  
  input out_rcvd;               // Indicates that the DSEC receiving device has recieved outputted data
  
  output reg stall;             // Indicates that all modules should maintain state (Asychronous)
  output reg rdy;               // Indicates that the DSEC module is ready to recieve data  
  output reg [63:0] error_code; // Identifies the last error encountered based on code
  output reg error;             // Indicates that an error occurred
  output reg out_valid;              // Indicates that the output of the DSEC module is valid
  
  
  
  input comp_rdy;               // Indicates that the compression module is ready for input
  input encry_rdy;              // Indicates that the encryption module is ready for input
  
  
  
  // reg error_reg;             // Indicates error
  // wire out_rcvd_since_done;  // Indicates whether out_rcvd was driven high since the last done was driven high
  
  // ==============================
  // Output drivers
  // ==============================
  
  // Drive stall signal
  always@(rst,in_valid,key_config,done,out_rcvd,error) begin
    if(rst)
      stall <= 1'b0;
    else if ( in_valid == 1'b0 )
      stall <= 1'b1;
    else if( key_config == 1'b1 )
      stall <= 1'b1;
    else if( (done == 1'b1) && (out_rcvd == 1'b0) )
      stall <= 1'b1;
    else if( error == 1'b1)
      stall <= 1'b1;
    else
      stall <= 1'b0;   
  end
  
  // Drive rdy signal
  always@(comp_rdy) begin
    if(comp_rdy == 1'b1)
      rdy == 1'b1;
    else
      rdy == 1'b0;
  end
  
  // Drive error code
  // ...
  
  // Drive error
  // ...
  
  // Drive done 
  
  
  
  
  
endmodule