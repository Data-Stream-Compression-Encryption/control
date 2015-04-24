/*  Filename     : SevenSegmentDisplayDriver.v
    Author       : <Your Name Here>
    Date         : <The Date>
    Version      : 1
   Description:  	This file contains a possible solution to
						HW4, ...
						This module decodes the Hex values 0-F to properly display them on a seven segment Display
						based on a 5 bit input vector, If the MSB on the input vector =1 then the Dispay is off otherwise 
						the HEX value corrosponding to the input is displayed:
						
						Note this module is written using only continuous dataflow!
						Note: The outputs must be active low!
						
						
											a bit(0)
										-------------
									  |				  |
									  |				  |
					 e bit(5) |			          	  | b bit(1)
									  |				  |
									  |	g bit(6)	  |
									   -------------
									  |				  |
									  |               |
				   e bit(4) |				          | c bit(2)
									  |				  |
									  |				  |
									   -------------
						               d bit(3)
						
						
						
*/

module SevenSegmentDisplayDriver(d, seg);

// Declare Inputs and Ouputs
input [4:0] d;          // Input d[4] = 1 => off; 
output [6:0] seg;       // Decoded LED Sequence

assign seg = ( d[4] == 1 )? (7'b1111111 ) :			//Handle the "off" case
				( d == 0 )? ( 7'b1000000 ) : 				
				( d == 1 )? ( 7'b1111001 ) :
				( d == 2 )? ( 7'b0100100 ) :
				( d == 3 )? ( 7'b0110000 ) :
				( d == 4 )? ( 7'b0011001 ) :
				( d == 5 )? ( 7'b0010010 ) :
				( d == 6 )? ( 7'b0000010 ) :
				( d == 7 )? ( 7'b1111000 ) :
				( d == 8 )? ( 7'b0000000 ) :
				( d == 9 )? ( 7'b0010000 ) :
				( d == 10 )? ( 7'b0001000 ) :
				( d == 11 )? ( 7'b0000011 ) :
				( d == 12 )? ( 7'b1000110 ) :
				( d == 13 )? ( 7'b0100001 ) :
				( d == 14 )? ( 7'b0000110 ) :
				( 7'b0001110 );



endmodule