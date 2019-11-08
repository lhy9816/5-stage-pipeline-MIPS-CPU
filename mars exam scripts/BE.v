`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:15:47 12/18/2017 
// Design Name: 
// Module Name:    BE 
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
`define SW 3'b000
`define SH 3'b001
`define SB 3'b010
module BE(Byte_in, S_Instr, Byte_out);
	input [1:0] Byte_in;
	input [2:0] S_Instr;
	output [3:0] Byte_out;
	
	assign Byte_out[3] = (S_Instr == `SB)? Byte_in[1] && Byte_in[0]:
								(S_Instr == `SH)? Byte_in[1]:
								(S_Instr == `SW)? 1'b1:
															1'b0;
	assign Byte_out[2] = (S_Instr == `SB)? Byte_in[1] && ~Byte_in[0]:
								(S_Instr == `SH)? Byte_in[1]:
								(S_Instr == `SW)? 1'b1:
															1'b0;
	assign Byte_out[1] = (S_Instr == `SB)? ~Byte_in[1] && Byte_in[0]:
								(S_Instr == `SH)? ~Byte_in[1]:
								(S_Instr == `SW)? 1'b1:
															1'b0;
	assign Byte_out[0] = (S_Instr == `SB)? ~Byte_in[1] && ~Byte_in[0]:
								(S_Instr == `SH)? ~Byte_in[1]:
								(S_Instr == `SW)? 1'b1:
															1'b0;
endmodule
