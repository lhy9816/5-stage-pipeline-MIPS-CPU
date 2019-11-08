`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:01:05 11/26/2017 
// Design Name: 
// Module Name:    EXT 
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
module EXT(imm16, ExtOp, ExOut);
    input [15:0] imm16;
    input [1:0] ExtOp;
    output [31:0] ExOut;

	 wire [31:0] ori;
	 wire [31:0] lw_sw;
	 wire [31:0] lui;
	 
	 assign ori = {16'b0, imm16};//0
	 assign lw_sw = {{16{imm16[15]}}, imm16};//1
	 assign lui = {imm16, 16'b0};//2
	 
	 Mux3to1 MUX_EXT(ori, lw_sw, lui, ExtOp, ExOut);
	 defparam MUX_EXT.WIDTH_DATA = 32;
	
	 
	 
endmodule
