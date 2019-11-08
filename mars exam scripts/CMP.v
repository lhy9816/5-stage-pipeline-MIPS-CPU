`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:46:19 12/05/2017 
// Design Name: 
// Module Name:    cmp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CMP(RD1, RD2, Zero, LT0, BG0);
	input [31:0] RD1;
	input [31:0] RD2;
	output Zero;
	output LT0;
	output BG0;
	
	assign Zero = (RD1 == RD2);
	assign LT0 = ($signed(RD1) < 0);
	assign BG0 = ($signed(RD1) > 0);
endmodule
