`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:10:49 12/06/2017 
// Design Name: 
// Module Name:    controller 
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
`define E_En 1'b1
`define M_En 1'b1
`define W_En 1'b1
module controller(//clk, reset, Instr, Zero, LT0, BG0, ExtOp, PC_sel, nPC_sel, ALU_A_sel_E, ALU_B_sel_E, ALUctr_E, Mem_to_Reg_sel_W, MemWrite_M, RegWrite_W, S_Instr_M, L_Instr_W, A3_M, PC_En, D_En, E_reset, MF_CMP_V1_E_RD1_sel, MF_CMP_V2_E_RD2_sel, MF_ALU_A_sel, MF_ALU_B_V2_M_sel, MF_WD_sel, Busy_start_E);
	input clk,
	input reset,
	input [31:0] Instr,
	input Zero,
	input LT0,
	input BG0,
	//input Busy,
	
	input flush,
	
	output [1:0] ExtOp,
	output [1:0] PC_sel,
	output [1:0] nPC_sel,
	output ALU_A_sel_E,
	output ALU_B_sel_E,
	output [3:0] ALUctr_E,
	output [1:0] Mem_to_Reg_sel_W,
	output MemWrite_M,
	output RegWrite_W,
	output [2:0] S_Instr_M,
	output [2:0] L_Instr_W,
	output [4:0] A3_M,						//传给datapath在W级写入的数据地址
	output [4:0] Rd_CP0_M,
	output PC_En,								//PC暂停条件，暂停则使能关闭
	output D_En,								//D级寄存器暂停条件，暂停则使能关闭
	output E_reset,							//E级寄存器暂停条件，暂停则清零
	output [2:0] MF_CMP_V1_E_RD1_sel,
	output [2:0] MF_CMP_V2_E_RD2_sel,
	output [1:0] MF_ALU_A_sel,
	output [1:0] MF_ALU_B_V2_M_sel,
	output  MF_WD_sel,
	//output Busy_start_E,						//E级乘除start信号
	//output [2:0] Mul_Div_ctr_E,				//E级MD运算选择信号
	//output [1:0] HiLo_E,
	output CP0_sel_M,							//CP0回写寄存器信号mfc0
	output D_flush,
	output Illegal_Instr
	);
	

	
	wire ALU_A_sel;
	wire ALU_B_sel;
	wire [3:0] ALUctr;
	wire [1:0] Mem_to_Reg_sel;
	wire MemWrite;
	wire RegWrite;
	wire [1:0] A3_sel;
	wire [2:0] S_Instr;						//s类指令的编号分类
	wire [2:0] L_Instr;						//l类指令的编号分类 lw lh lhu lb lbu
	//wire M_D_Instr;
	//wire Busy_start;
	//wire [2:0] Mul_Div_ctr;					//MD运算选择信号
	//wire [1:0] HiLo;
	wire CP0_sel;
	//没有_CAPITAL的都是D级译码产生的
	
	wire [4:0] A1_D;
	wire [4:0] A2_D;
	wire [4:0] A3_D;
	wire [4:0] Rd_CP0;						//for cp0读入选择信号mfc0
	wire Tuse_RS0;
	wire Tuse_RS1;
	wire Tuse_RT0;
	wire Tuse_RT1;
	wire Tuse_RT2;
	wire Tuse_CP0_0;
	wire Tuse_CP0_2;
	wire [1:0] Res;
	wire [1:0] Res_CP0;
	//A_T_coder新增的中间变量
	
	wire [4:0] A1_E;
	wire [4:0] A2_E;
	wire [4:0] A3_E;
	wire [1:0] Res_E;
	wire [1:0] Res_CP0_E;
	//wire ALU_B_sel_E;
	//wire [3:0] ALUctr_E;
	wire MemWrite_E;
	wire RegWrite_E;
	wire [1:0] Mem_to_Reg_sel_E;
	wire [2:0] S_Instr_E;
	wire [2:0] L_Instr_E;
	//wire Busy_start_E;
	//wire [2:0] Mul_Div_ctr_E;
	wire [4:0] Rd_CP0_E;
	wire CP0_sel_E;
	//E级control寄存器中间变量
	
	
	//wire [4:0] A1_M;
	wire [4:0] A2_M;
	//wire [4:0] A3_M;
	wire [1:0] Res_M;
	wire [1:0] Res_CP0_M;
	//wire MemWrite_M;
	wire RegWrite_M;
	wire [1:0] Mem_to_Reg_sel_M;
	wire [2:0] L_Instr_M;
	//wire [2:0] S_Instr_M;//端口已经定义
	//wire LH_M;
	//M级control流水线寄存器中间变量
	
	wire [4:0] A3_W;
	wire [1:0] Res_W;
	wire MemWrite_W;
	//wire RegWrite_W;
	//wire [1:0] Mem_to_Reg_sel_W;
	//W级control寄存器中间变量
	
	main_control ctr_main_control (
		.Instr(Instr),
		.Op(Instr[31:26]), 
		.Funct(Instr[5:0]), 
		.Rt(Instr[20:16]),
		.Zero(Zero), 
		.LT0(LT0),
		.BG0(BG0),
		.ExtOp(ExtOp), 
		.PC_sel(PC_sel), 
		.nPC_sel(nPC_sel), 
		.ALU_A_sel(ALU_A_sel),
		.ALU_B_sel(ALU_B_sel), 
		.ALUctr(ALUctr), 
		.Mem_to_Reg_sel(Mem_to_Reg_sel), 
		.A3_sel(A3_sel), 
		.MemWrite(MemWrite), 
		.RegWrite(RegWrite),
		.S_Instr(S_Instr),
		.L_Instr(L_Instr),
		//.M_D_Instr(M_D_Instr),
		//.Busy_start(Busy_start),
		//.Mul_Div_ctr(Mul_Div_ctr),
		//.HiLo(HiLo),
		.CP0_sel(CP0_sel),
		.D_flush(D_flush),
		.Illegal_Instr(Illegal_Instr)
	);
		
	A_T_coder ctr_A_T_coder (
		.Instr(Instr),
		.A3_sel(A3_sel),		
		.BG0(BG0),
		.A1_D(A1_D), 
		.A2_D(A2_D), 
		.A3_D(A3_D), 
		.Rd_CP0(Rd_CP0),
		.Tuse_RS0(Tuse_RS0), 
		.Tuse_RS1(Tuse_RS1), 
		.Tuse_RT0(Tuse_RT0), 
		.Tuse_RT1(Tuse_RT1), 
		.Tuse_RT2(Tuse_RT2), 
		.Tuse_CP0_0(Tuse_CP0_0),
		.Tuse_CP0_2(Tuse_CP0_2),
		.Res(Res),
		.Res_CP0(Res_CP0)
	);
	
	hazard_detector ctr_hazard_detector (
		.A1_D(A1_D), 
		.A2_D(A2_D), 
		.A3_D(A3_D), 
		.A3_E(A3_E), 
		.A3_M(A3_M), 
		.Res_E(Res_E), 
		.Res_M(Res_M), 
		.Tuse_RS0(Tuse_RS0), 
		.Tuse_RS1(Tuse_RS1), 
		.Tuse_RT0(Tuse_RT0), 
		.Tuse_RT1(Tuse_RT1), 
		//.Tuse_RT2(Tuse_RT2), 
		.Tuse_CP0_0(Tuse_CP0_0),
		.Tuse_CP0_2(Tuse_CP0_2),
		.Res(Res),
		.Res_CP0(Res_CP0),
		.Res_CP0_E(Res_CP0_E),
		.Res_CP0_M(Res_CP0_M),
		//.Start_E(Busy_start_E),
		//.Busy(Busy),
		//.M_D_Instr(M_D_Instr),
		.Stall(Stall)
	);
	
	stall_controller ctr_stall_controller (
		.Stall(Stall), 
		.PC_En(PC_En), 
		.D_En(D_En), 
		.E_reset(E_reset)
	);

	forward_controller ctr_forward_controller (
		.A1_D(A1_D), 
		.A2_D(A2_D), 
		.A1_E(A1_E), 
		.A2_E(A2_E), 
		.A2_M(A2_M), 
		.A3_M(A3_M), 
		.A3_W(A3_W), 
		.Res_M(Res_M), 
		.Res_W(Res_W), 
		.MF_CMP_V1_E_RD1_sel(MF_CMP_V1_E_RD1_sel), 
		.MF_CMP_V2_E_RD2_sel(MF_CMP_V2_E_RD2_sel), 
		.MF_ALU_A_sel(MF_ALU_A_sel), 
		.MF_ALU_B_V2_M_sel(MF_ALU_B_V2_M_sel), 
		.MF_WD_sel(MF_WD_sel)
	);
	
	E_R_Pipe R_ALU_A_sel_E(ALU_A_sel, ALU_A_sel_E, clk, reset, flush, E_reset, `E_En);
	defparam R_ALU_A_sel_E.WIDTH_DATA = 1;//control中ALU_A_sel的选择信号在E级(for shamt)
	
	E_R_Pipe R_ALU_B_sel_E(ALU_B_sel, ALU_B_sel_E, clk, reset, flush, E_reset, `E_En);
	defparam R_ALU_B_sel_E.WIDTH_DATA = 1;//control中ALU_B_sel的选择信号在E级
	
	E_R_Pipe R_ALUctr_E(ALUctr, ALUctr_E, clk, reset, flush, E_reset, `E_En);
	defparam R_ALUctr_E.WIDTH_DATA = 4;//control中ALUctr的选择信号在E级
	
	E_R_Pipe R_MemWrite_E(MemWrite, MemWrite_E, clk, reset, flush, E_reset, `E_En);
	defparam R_MemWrite_E.WIDTH_DATA = 1;//control中MemWrite的选择信号在E级
	
	E_R_Pipe R_RegWrite_E(RegWrite, RegWrite_E, clk, reset, flush, E_reset, `E_En);
	defparam R_RegWrite_E.WIDTH_DATA = 1;//control中RegWrite的选择信号在E级
	
	E_R_Pipe R_Mem_to_Reg_sel_E(Mem_to_Reg_sel, Mem_to_Reg_sel_E, clk, reset, flush, E_reset, `E_En);
	defparam R_Mem_to_Reg_sel_E.WIDTH_DATA = 2;//control中Mem_to_Reg_sel的选择信号在E级
	
	E_R_Pipe R_A1_E(A1_D, A1_E, clk, reset, flush, E_reset, `E_En);
	defparam R_A1_E.WIDTH_DATA = 5;//control中A1_E的选择地址在E级
	
	E_R_Pipe R_A2_E(A2_D, A2_E, clk, reset, flush, E_reset, `E_En);
	defparam R_A2_E.WIDTH_DATA = 5;//control中A2_E的选择地址在E级
	
	E_R_Pipe R_A3_E(A3_D, A3_E, clk, reset, flush, E_reset, `E_En);
	defparam R_A3_E.WIDTH_DATA = 5;//control中A3_E的选择地址在E级
	
	E_R_Pipe R_Rd_CP0_E(Rd_CP0, Rd_CP0_E, clk, reset, flush, E_reset, `E_En);
	defparam R_Rd_CP0_E.WIDTH_DATA = 5;//control中A1_E的选择地址在E级
	
	E_R_Pipe R_Res_E(Res, Res_E, clk, reset, flush, E_reset, `E_En);
	defparam R_Res_E.WIDTH_DATA = 2;//control中Res_E的选择信号在E级
	
	
	E_R_Pipe R_Res_CP0_E(Res_CP0, Res_CP0_E, clk, reset, flush, E_reset, `E_En);
	defparam R_Res_CP0_E.WIDTH_DATA = 2;
	
	E_R_Pipe R_S_Instr_E(S_Instr, S_Instr_E, clk, reset, flush, E_reset, `E_En);
	defparam R_S_Instr_E.WIDTH_DATA = 3;//control中S_Instr_E的选择信号在E级
	
	E_R_Pipe R_L_Instr_E(L_Instr, L_Instr_E, clk, reset, flush, E_reset, `E_En);
	defparam R_L_Instr_E.WIDTH_DATA = 3;//control中L_Instr_E的选择信号在E级
	
	/*E_R_Pipe R_Busy_start_E(Busy_start, Busy_start_E, clk, reset, flush, E_reset, `E_En);
	defparam R_Busy_start_E.WIDTH_DATA = 1;//control中Busy_start的选择信号在E级*/
	
	/*E_R_Pipe R_Mul_Div_ctr_E(Mul_Div_ctr, Mul_Div_ctr_E, clk, reset, flush, E_reset, `E_En);
	defparam R_Mul_Div_ctr_E.WIDTH_DATA = 3;//control中Busy_start的选择信号在E级*/
	
	/*E_R_Pipe R_HiLo_E(HiLo, HiLo_E, clk, reset, flush, E_reset, `E_En);
	defparam R_HiLo_E.WIDTH_DATA = 2;//control中Busy_start的选择信号在E级*/
	
	E_R_Pipe R_CP0_sel_E(CP0_sel, CP0_sel_E, clk, reset, flush, E_reset, `E_En);
	defparam R_CP0_sel_E.WIDTH_DATA = 1;
	//control的E级流水线寄存器
	
	
	R_Pipe R_MemWrite_M(MemWrite_E, MemWrite_M, clk, reset, flush, `M_En);
	defparam R_MemWrite_M.WIDTH_DATA = 1;//control中MemWrite的选择信号在E级
	
	R_Pipe R_RegWrite_M(RegWrite_E, RegWrite_M, clk, reset, flush, `M_En);
	defparam R_RegWrite_M.WIDTH_DATA = 1;//control中RegWrite的选择信号在E级
	
	R_Pipe R_Mem_to_Reg_sel_M(Mem_to_Reg_sel_E, Mem_to_Reg_sel_M, clk, reset, flush, `M_En);
	defparam R_Mem_to_Reg_sel_M.WIDTH_DATA = 2;//control中Mem_to_Reg_sel的选择信号在E级
	
	/*R_Pipe R_A1_M(A1_E, A1_M, clk, reset, flush, `M_En);
	defparam R_A1_M.WIDTH_DATA = 5;//control中A1_E的选择地址在E级*/
	
	R_Pipe R_A2_M(A2_E, A2_M, clk, reset, flush, `M_En);
	defparam R_A2_M.WIDTH_DATA = 5;//control中A2_E的选择地址在E级
	
	R_Pipe R_A3_M(A3_E, A3_M, clk, reset, flush, `M_En);
	defparam R_A3_M.WIDTH_DATA = 5;//control中A3_E的选择地址在E级
	
	R_Pipe R_Rd_CP0_M(Rd_CP0_E, Rd_CP0_M, clk, reset, flush, `M_En);
	defparam R_Rd_CP0_M.WIDTH_DATA = 5;
	
	R_Pipe R_Res_M(Res_E, Res_M, clk, reset, flush, `M_En);
	defparam R_Res_M.WIDTH_DATA = 2;//control中Res_M的选择信号在M级
	
	R_Pipe R_Res_CP0_M(Res_CP0_E, Res_CP0_M, clk, reset, flush, `M_En);
	defparam R_Res_CP0_M.WIDTH_DATA = 2;
	
	R_Pipe R_S_Instr_M(S_Instr_E, S_Instr_M, clk, reset, flush, `M_En);
	defparam R_S_Instr_M.WIDTH_DATA = 3;//control中L_Instr_M的选择信号在M级
	
	R_Pipe R_L_Instr_M(L_Instr_E, L_Instr_M, clk, reset, flush, `M_En);
	defparam R_L_Instr_M.WIDTH_DATA = 3;//control中L_Instr_M的选择信号在M级
	
	R_Pipe R_CP0_sel_M(CP0_sel_E, CP0_sel_M, clk, reset, flush, `M_En);
	defparam R_CP0_sel_M.WIDTH_DATA = 1;
	//control的M级流水线寄存器

	
	R_Pipe R_RegWrite_W(RegWrite_M, RegWrite_W, clk, reset, flush, `W_En);
	defparam R_RegWrite_W.WIDTH_DATA = 1;//control中RegWrite的选择信号在W级
	
	R_Pipe R_Mem_to_Reg_sel_W(Mem_to_Reg_sel_M, Mem_to_Reg_sel_W, clk, reset, flush, `W_En);
	defparam R_Mem_to_Reg_sel_W.WIDTH_DATA = 2;//control中Mem_to_Reg_sel的选择信号在W级
	
	R_Pipe R_A3_W(A3_M, A3_W, clk, reset, flush, `W_En);
	defparam R_A3_W.WIDTH_DATA = 5;//control中A3_W的选择地址在W级
	
	R_Pipe R_Res_W(Res_M, Res_W, clk, reset, flush, `W_En);
	defparam R_Res_W.WIDTH_DATA = 2;//control中Res_W的选择信号在W级
	
	R_Pipe R_L_Instr_W(L_Instr_M, L_Instr_W, clk, reset, flush, `W_En);
	defparam R_L_Instr_W.WIDTH_DATA = 3;//control中L_Instr_M的选择信号在M级
endmodule
