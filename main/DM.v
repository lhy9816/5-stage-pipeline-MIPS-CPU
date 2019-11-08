`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:04:09 11/26/2017 
// Design Name: 
// Module Name:    DM 
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
module DM(clk, reset, times_M, Instr_addr, MemWrite, MemAddr, Byte_sel, DataIn, MemOut);
    input clk; //clock
    input reset; // reset
	 input [31:0] times_M;
	 input [31:0] Instr_addr;
    input MemWrite; // 写使能
    input [31:0] MemAddr; // 写入内存的具体地址
	 input [3:0] Byte_sel;//写入内存的字节偏移
    input [31:0] DataIn; // 32位写入内存的数据
    output [31:0] MemOut; // 32位从内存读出的数据
	 
	 wire [31:0] WD;//经过Byte_sel后的写入数据
	 //reg [31:0] DataMem [2047:0]; //内存存储器
	 //integer i;
	 
	 /*initial
		begin
			for(i = 0; i < 4096; i = i + 1) DataMem[i] <= 0; 
		end*/
		
	 /*assign MemOut = DataMem[MemAddr[13:2]]; //读出相应地址的数据*/
	 assign WD = (Byte_sel == 4'b1111) ? DataIn:
					 (Byte_sel == 4'b1100) ? {DataIn[15:0], MemOut[15:0]}:
				    (Byte_sel == 4'b0011) ? {MemOut[31:16], DataIn[15:0]}:
					 (Byte_sel == 4'b1000) ? {DataIn[7:0], MemOut[23:0]}:
					 (Byte_sel == 4'b0100) ? {MemOut[31:24], DataIn[7:0], MemOut[15:0]}:
					 (Byte_sel == 4'b0010) ? {MemOut[31:16], DataIn[7:0], MemOut[7:0]}:
					 (Byte_sel == 4'b0001) ? {MemOut[31:8], DataIn[7:0]}:
																					MemOut;


	DM_ip _DM (
		.clka(clk), // input clka
		.rsta(reset), // input rsta
		.ena(MemWrite), // input ena
		.wea(Byte_sel), // input [3 : 0] wea
		.addra(MemAddr[12:2]), // input [10 : 0] addra
		.dina(DataIn), // input [31 : 0] dina
		.douta(MemOut) // output [31 : 0] douta
	);
	/*always@(posedge clk)
		begin
			if(MemWrite && ~reset)
				$display("%d@%h: *%h <= %h", times_M, Instr_addr, {MemAddr[31:2], 2'b0}, WD);
				//$display("*%h <= %h", MemAddr, DataIn);
		end*/
	 /*always@(posedge clk)
		begin
			if(reset)
				begin
					for(i = 0; i < 2047; i = i + 1) DataMem[i] <= 0; //reset触发寄存器清零
				end
			else
				begin
					if(MemWrite)
						begin
							DataMem[MemAddr[13:2]] <= WD; //写入相应地址的数据
							$display("%d@%h: *%h <= %h", times_M, Instr_addr, {MemAddr[31:2], 2'b0}, WD);
							//$display("*%h <= %h", MemAddr, DataIn);
									
						end
				end
		end*/

endmodule
