`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:25:16 12/19/2017 
// Design Name: 
// Module Name:    MUL_DIV 
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
`define DIV_END 4'b1000
`define MUL_END 4'b0011

`define NE 3'b000
`define mthi 3'b001
`define mtlo 3'b010
`define multu 3'b011
`define mult 3'b100
`define divu 3'b101
`define div 3'b110
module MUL_DIV(
	input clk,
	input reset,
	input [31:0] SrcA,
	input [31:0] SrcB,
	input [2:0] Mul_Div_ctr,
	
	input Start,
	input EI_HILO_ctr,			//EI_ctr产生,M级出现中断异常时不允许乘除指令修改hilo寄存器
	input ExcReq_E,				//E级汇总后有异常产生，代表前面该乘除指令有错误
	
	output reg Busy,
	output reg [31:0] HI,
	output reg [31:0] LO
	);
	
	reg [3:0] count;//Busy的计数器
	
	reg [2:0] MD_ctr;//乘除信号寄存器
	
	/*wire [63:0] SrcA_Ext;//第一个操作数扩展后
	
	wire [63:0] SrcB_Ext;//第二个操作数扩展后
	
	reg [63:0] SrcA_reg;//第一个操作数的寄存器
	
	reg [63:0] SrcB_reg;//第二个操作数的寄存器*/
	wire [31:0] SrcA_Ext;//第一个操作数扩展后
	
	wire [31:0] SrcB_Ext;//第二个操作数扩展后
	
	reg [31:0] SrcA_reg;//第一个操作数的寄存器
	
	reg [31:0] SrcB_reg;//第二个操作数的寄存器

	/*initial
		begin
			count <= 0;
			MD_ctr <= 0;
			
			SrcA_reg <= 0;
			SrcB_reg <= 0;
			Busy <= 0;
			
			HI <= 0;
			LO <= 0;
		end*/
	
	/*assign SrcA_Ext = ((Mul_Div_ctr == `mult) || (Mul_Div_ctr == `div))?  {{32{SrcA[31]}}, SrcA}: //操作数扩展
							((Mul_Div_ctr == `multu) || (Mul_Div_ctr == `divu))?  {32'b0, SrcA}:
																									{32'b0, SrcA};
																									
	assign SrcB_Ext = ((Mul_Div_ctr == `mult) || (Mul_Div_ctr == `div))?  {{32{SrcB[31]}}, SrcB}: //操作数扩展
							((Mul_Div_ctr == `multu) || (Mul_Div_ctr == `divu))?  {32'b0, SrcB}:
																									{32'b0, SrcB};*/
	assign SrcA_Ext = ((Mul_Div_ctr == `mult) || (Mul_Div_ctr == `div))?  $signed(SrcA): //操作数扩展
							((Mul_Div_ctr == `multu) || (Mul_Div_ctr == `divu))?  $unsigned(SrcA):
																									$unsigned(SrcA);
																									
	assign SrcB_Ext = ((Mul_Div_ctr == `mult) || (Mul_Div_ctr == `div))?  $signed(SrcB): //操作数扩展
							((Mul_Div_ctr == `multu) || (Mul_Div_ctr == `divu))?  $unsigned(SrcB):
																									$unsigned(SrcB);
																									
	always@(posedge clk)                                                                         //不需延迟的部件输出
		begin
			if(reset)
				begin
					count <= 0;
					MD_ctr <= 0;
			
					SrcA_reg <= 0;
					SrcB_reg <= 0;
					Busy <= 0;
			
					HI <= 0;
					LO <= 0;
				end
			else
				begin
					if(MD_ctr == `multu)
						begin
							if(Busy)																								  //信号阻塞
								begin
									count <= count + 1;
								end
							if(count == `MUL_END)
								begin
									{HI, LO} <= SrcA_reg * SrcB_reg;
									Busy <= 0;
									count <= 0;
									MD_ctr <= `NE;
								end
						end
					else if(MD_ctr == `mult)
						begin
							if(Busy)																								  //信号阻塞
								begin
									count <= count + 1;
								end
							if(count == `MUL_END)
								begin
									{HI, LO} <= $signed(SrcA_reg) * $signed(SrcB_reg);
									Busy <= 0;
									count <= 0;
									MD_ctr <= `NE;
								end
						end
					else if(MD_ctr == `divu)
						begin
							if(Busy)
								begin
									count <= count + 1;
								end
							if(count == `DIV_END)
								begin
									HI <= SrcA_reg % SrcB_reg;
									LO <= SrcA_reg / SrcB_reg;
									Busy <= 0;
									count <= 0;
									MD_ctr <= `NE;
								end
						end
					
					else if(MD_ctr == `div)
						begin
							if(Busy)
								begin
									count <= count + 1;
								end
							if(count == `DIV_END)
								begin
									HI <= $signed(SrcA_reg) % $signed(SrcB_reg);
									LO <= $signed(SrcA_reg) / $signed(SrcB_reg);
									Busy <= 0;
									count <= 0;
									MD_ctr <= `NE;
								end
						end
				
					else if((Mul_Div_ctr == `mthi) && (EI_HILO_ctr == 0) && (ExcReq_E == 0))  HI <= SrcA; //当前M级无中断，而且E级的指令没有异常
					else if((Mul_Div_ctr == `mtlo) && (EI_HILO_ctr == 0) && (ExcReq_E == 0)) LO <= SrcA;
					else if((Start) && (EI_HILO_ctr == 0) && (ExcReq_E == 0))
						begin
							Busy <= 1'b1;
							MD_ctr <= Mul_Div_ctr;
							SrcA_reg <= SrcA_Ext;
							SrcB_reg <= SrcB_Ext;																			  //Busy启动，选择信号与两个操作数记录下来以备最后一个周期使用
						end
				end
		end
	
	/*always@(posedge clk)																								  //模拟延迟
		begin
			if(MD_ctr == `multu)
				begin
					if(Busy)																								  //信号阻塞
						begin
							count <= count + 1;
						end
					if(count == `MUL_END)
						begin
							{HI, LO} <= SrcA_reg * SrcB_reg;
							Busy <= 0;
							count <= 0;
							MD_ctr <= `NE;
						end
				end
			else if(MD_ctr == `mult)
				begin
					if(Busy)																								  //信号阻塞
						begin
							count <= count + 1;
						end
					if(count == `MUL_END)
						begin
							{HI, LO} <= $signed(SrcA_reg) * $signed(SrcB_reg);
							Busy <= 0;
							count <= 0;
							MD_ctr <= `NE;
						end
				end
			else if(MD_ctr == `divu)
				begin
					if(Busy)
						begin
							count <= count + 1;
						end
					if(count == `DIV_END)
						begin
							HI <= SrcA_reg % SrcB_reg;
							LO <= SrcA_reg / SrcB_reg;
							Busy <= 0;
							count <= 0;
							MD_ctr <= `NE;
						end
				end
				
			else if(MD_ctr == `div)
				begin
					if(Busy)
						begin
							count <= count + 1;
						end
					if(count == `DIV_END)
						begin
							HI <= $signed(SrcA_reg) % $signed(SrcB_reg);
							LO <= $signed(SrcA_reg) / $signed(SrcB_reg);
							Busy <= 0;
							count <= 0;
							MD_ctr <= `NE;
						end
				end
		end*/

endmodule
