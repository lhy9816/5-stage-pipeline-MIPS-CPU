`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:05:58 11/26/2017 
// Design Name: 
// Module Name:    IM 
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
module IM(clk, Instr_addr, Instr_Out);
	 input clk;
    input [31:0] Instr_addr; //指令索引位
    output [31:0] Instr_Out; //指令输出
	 
	 wire [31:0] PC_addr;
	 
	 assign PC_addr = Instr_addr - 32'h00003000;
	
	 IM_ip _IM (
		.clka(clk), // input clka
		.wea(1'b0), // input [0 : 0] wea
		.addra(PC_addr[12:2]), // input [10 : 0] addra
		.dina(32'b0), // input [31 : 0] dina
		.douta(Instr_Out) // output [31 : 0] douta
	);
	
	 //reg [31:0] instr_mem[/*1023*/2047:0];// 指令内存数组
	 /*initial
		begin
			$readmemh("code.txt", instr_mem);
			$readmemh("code_handler.txt", instr_mem, 1120, 2047);
		end*/
	 //assign Instr_Out = instr_mem[Instr_addr[14:2] - 12'b110000000000]; //指令索引位上的指令码

endmodule
