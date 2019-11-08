`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:29:00 11/26/2017 
// Design Name: 
// Module Name:    RF 
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
module RF(A1, A2, A3, Current_PC, RegData, clk, reset, times_W, RegWrite, RD1, RD2);
    input [4:0] A1; //rs
    input [4:0] A2; //rt
	 //input [31:0] Instr_Out;
    input [4:0] A3; //待写入寄存器
	 input [31:0] Current_PC;
    input [31:0] RegData; //待写入数据
	 input clk; //clock
    input reset; 
	 input [31:0] times_W;
    input RegWrite; //写使能
    output [31:0] RD1; //输出rs中数据
    output [31:0] RD2; //输出rt中数据
    
	
	 reg [31:0] RegFile[31:0]; //寄存器堆
	 integer i;
	 
	 //assign A1 = Instr_Out[25:21];
	 //assign A2 = Instr_Out[20:16];
	 assign RD1 = RegFile[A1];
	 assign RD2 = RegFile[A2];
	
	 always@(posedge clk)
		begin
			if(reset)
				begin
					for(i = 0; i < 32; i = i + 1) RegFile[i] <= 0;
				end
			else
				begin
					if (RegWrite)
						begin
							if(A3 != 0)
								RegFile[A3] <= RegData;
							$display("%d@%h: $%d <= %h", times_W, Current_PC, A3, RegData);
							//$display("$%d <= %h", A3, RegData);
						end
				end
		end


endmodule
