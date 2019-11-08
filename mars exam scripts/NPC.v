`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:31:42 11/26/2017 
// Design Name: 
// Module Name:    NPC 
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
module NPC(imm, PC4, nPC_sel, EPC, NPC);
    input [25:0] imm; //jal/beq的立即数
    input [31:0] PC4; // PC+4地址输出
	 input [1:0] nPC_sel;//b或j类指令选择信号
	 input [31:0] EPC;
    output [31:0] NPC; //32
	 
	 wire [31:0] B_Instr;
	 wire [31:0] J_Instr;
	 /*wire [31:0] beq;
	 wire [31:0] jal;
	 
	 assign PC4 = PC + 4;
	 assign beq = {{15{imm[15]}}, imm[14:0], 2'b0};//符号扩展至32位
	 assign jal = {4'b0, imm, 2'b0}; //扩展至32位*/
	

	 /*assign NPC = (nPC_sel[1] == 1)? (nPC_sel[0] == 1? jr: jal):
	
											((nPC_sel[0] == 1)? (Zero == 1? (beq+4+PC): PC4): PC4);*/
	assign B_Instr = {{15{imm[15]}}, imm[14:0], 2'b00} + PC4;
	assign J_Instr = {PC4[31:28], imm, 2'b0}; 
	Mux3to1 MUX_NPC(B_Instr, J_Instr, EPC, nPC_sel, NPC);
	defparam MUX_NPC.WIDTH_DATA = 32;

endmodule
