`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:07:02 12/05/2017 
// Design Name: 
// Module Name:    R_Pipe 
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
module R_Pipe(datain, dataout, clk, reset, flush, En);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] datain;
	input clk;
	input reset;//待定
	input flush;
	input En;//待定
	output reg [WIDTH_DATA:1] dataout;
	
	always@(posedge clk)
		begin
			if(reset)
				dataout <= 0;
			else if(flush)
				dataout <= 0;
			else
				begin
					if(En)
						dataout <= datain;
				end
				
		end
endmodule

module D_R_Pipe(datain, dataout, clk, reset, flush, D_flush, En);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] datain;
	input clk;
	input reset;//待定
	input flush;
	input D_flush;
	input En;//待定
	output reg [WIDTH_DATA:1] dataout;
	
	always@(posedge clk)
		begin
			if(reset)
				dataout <= 0;
			else if(flush)
				dataout <= 0;
			else if(D_flush && En == 1'b1)
				dataout <= 0;
			else
				begin
					if(En)
						dataout <= datain;
				end
				
		end
endmodule

module E_R_Pipe(datain, dataout, clk, reset, flush, E_reset, En);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] datain;
	input clk;
	input reset;//待定
	input flush;
	input E_reset;//暂停成立时E级寄存器清零
	input En;//待定
	output reg [WIDTH_DATA:1] dataout;
	
	always@(posedge clk)
		begin
			if(reset)
				dataout <= 0;
			else if(flush)
				dataout <= 0;
			else if(E_reset)
				dataout <= 0;
			else
				begin
					if(En)
						dataout <= datain;
				end
				
		end
endmodule