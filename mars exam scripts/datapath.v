`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
`define E_En 1'b1
`define M_En 1'b1
`define W_En 1'b1
`define Int 5'd0
`define AdEL 5'd4
`define AdES 5'd5
`define RI 5'd10
`define Ov 5'd12
module datapath(//clk, reset, times, ExtOp, PC_sel, nPC_sel, ALU_A_sel, ALU_B_sel, ALUctr, Mem_to_Reg_sel, MemWrite, RegWrite, S_Instr, L_Instr, /*LH, */A3_in, PC_En, D_En, E_reset, MF_CMP_V1_E_RD1_sel, MF_CMP_V2_E_RD2_sel, MF_ALU_A_sel, MF_ALU_B_V2_M_sel, MF_WD_sel, Zero, LT0, BG0, IR_D);
	input clk,
	input clk_,
	input reset,
	input [31:0] times,
	input [1:0] ExtOp,
	input [1:0] PC_sel,
	input [1:0] nPC_sel,
	input ALU_A_sel,
	input ALU_B_sel,
	input [3:0] ALUctr,
	input [1:0] Mem_to_Reg_sel,
	input MemWrite,
	input RegWrite,
	input [2:0] S_Instr,
	input [2:0] L_Instr,						//L_Instr
	input [4:0] A3_in,						//在W级写入的数据地址
	input [4:0] Rd_CP0,						//mfc0读入
	input PC_En,								//PC暂停条件，暂停则使能关闭
	input D_En,									//D级寄存器暂停条件，暂停则使能关闭
	input E_reset,								//E级寄存器暂停条件，暂停则清零
	input [2:0] MF_CMP_V1_E_RD1_sel,
	input [2:0] MF_CMP_V2_E_RD2_sel,
	input [1:0] MF_ALU_A_sel,
	input [1:0] MF_ALU_B_V2_M_sel,
	input  MF_WD_sel,
	//input Start,
	//input [2:0] Mul_Div_ctr,
	//input [1:0] HiLo,									//HiLo寄存器回写选择讯号
	input CP0_sel,
	input D_flush,
	input Illegal_Instr,
	
	//input [31:0] EPC;
	output Zero,
	output LT0,
	output BG0,
	//output Busy,
	output [31:0] IR_D,						//D级指令输出进入控制器
	
	//bridge
	input [31:0] PrRD,						//回到流水线与DMOut形成2to1
	input [7:2] HWInt,						//设备中断请求6位
	output [31:0] ALUOut_M,
	output [31:0] V2_M_AMF,
	output [3:0] Byte_sel,
	output PrWe,								   //M级产生的写设备信号
	
	//CP0
	output dp_flush							//中断或异常后面指令的清除信号
	);
	
	
	//模块内变量
	
	//PC----------
	
	wire [31:0] NPC;
	wire [31:0] Current_PC;

	//NPC----------
	
	//wire Zero;


	// Outputs
	wire [31:0] PC4;
	//wire [31:0] NPC;
	
	
	//IM----------
	// Inputs
	//reg [31:0] Instr_addr;

	// Outputs
	wire [31:0] Instr_Out;
	
	//RF----------
	// Inputs
	
	
	wire [4:0] A1;
	wire [4:0] A2;
	wire [4:0] A3;
	wire [31:0] RegData;
	
	
	wire [31:0] RD1;
	wire [31:0] RD2;
	
	//ALU----------
	
	wire [31:0] SrcA;
	wire [31:0] SrcB;

	wire [31:0] ALUResult;
	
	//EXT----------
	// Inputs
	
	// Outputs
	wire [31:0] ExOut;
	
	//DM----------
	
	// Inputs
	
	wire [31:0] MemAddr;//MemAddr = ALUResult
	wire [31:0] DataIn;//DataIn = RD2

	// Outputs
	wire [31:0] MemOut;
	
	
	//新加变量
	wire [31:0] ADD4;
	wire [31:0] N_PC;						//功能多选器后的PC
	wire [31:0] N_PC_CP0;				//经过异常选择后的CP0
	
	wire PC_EI;								//控制进入中断异常处理00004180的PC选择信号
	
	wire [31:0] RF_RD1;
	wire [31:0] RF_RD2;
	wire [31:0] RF_RD1_AM;//经过转发多选器后的RF_RD1
	wire [31:0] RF_RD2_AM;//经过转发多选器后的RF_RD2
	wire [31:0] Current_PC_D, Current_PC_E, Current_PC_M, Current_PC_W;
	wire [31:0] times_D, times_E, times_M, times_W;
	
	//M级wire
	wire [31:0] DM_EXT_out;//DM_EXT扩展后数据
	Mux3to1 MUX_PC(
		.in0(ADD4),
		.in1(NPC),
		.in2(RF_RD1_AM),
		.sel(PC_sel),
		.out(N_PC)
	);
	defparam MUX_PC.WIDTH_DATA = 32;
	
	assign N_PC_CP0 = (PC_EI == 1)? 32'h00004180: N_PC;
	
	//*****Exc*****//
	wire ExcReq_PC, ExcReq_D, ExcReq_D_out, ExcReq_E, ExcReq_E_out, ExcReq_M, ExcReq;	//刚流出寄存器的原因信号 	//流水线各级是否有异常发生
	wire [6:2] ExcCode_PC;
	wire [6:2] ExcCode_D;									//寄存器出来的值
	wire [6:2] ExcCode_D_out;
	wire [6:2] ExcCode_E;									//寄存器出来的值
	wire [6:2] ExcCode_E_out;
	wire [6:2] ExcCode_M;									//寄存器出来的值
	wire [6:2] ExcCode;
	
	//检测PC异常//
	//wire PC_in_ov;
	//assign PC_in_ov = (N_PC_CP0 > 32'h00004fff) || (N_PC_CP0 < 32'h00003000);
	assign ExcReq_PC = ((Current_PC[1:0] != 2'b00) || (Current_PC > 32'h00004ffc) || (Current_PC < 32'h00003000));
	assign ExcCode_PC = (ExcReq_PC == 1)? `AdEL: 5'b0;
	//********//
	PC dp_PC (
		.clk(clk), 
		.reset(reset),
		.PC_En(PC_En || (N_PC_CP0 == 32'h00004180)),
		.N_PC(N_PC_CP0), 
		.Current_PC(Current_PC)
	);
	
	//新加变量
	wire [31:0] ADD8;
	assign ADD4 = Current_PC + 4;
	assign ADD8 = Current_PC + 8;//为PC+8做准备

	IM dp_IM (
		.clk(clk_),
		.Instr_addr(Current_PC), 
		.Instr_Out(Instr_Out)
	);
	//IM----------
	
	//新增变量
	
	//wire D_En;
	wire [31:0] PC4_D;
	wire [31:0] EPC;
	
	
	//wire [31:0] IR_D;
	
	//*****PC8*****//
	wire [31:0] PC8_D;
	wire [31:0] PC8_E;
	wire [31:0] PC8_M;
	wire [31:0] PC8_W;
	//*************//
	
	D_R_Pipe R_IR_D(Instr_Out, IR_D, clk, reset, dp_flush, D_flush, D_En);
	defparam R_IR_D.WIDTH_DATA = 32;
	
	D_R_Pipe R_PC4_D(ADD4, PC4_D, clk, reset, dp_flush, D_flush, D_En);
	defparam R_PC4_D.WIDTH_DATA = 32;
	
	D_R_Pipe R_PC8_D(ADD8, PC8_D, clk, reset, dp_flush, D_flush, D_En);
	defparam R_PC8_D.WIDTH_DATA = 32;
	
	D_R_Pipe R_Current_PC_D(Current_PC, Current_PC_D, clk, reset, dp_flush, D_flush, D_En);
	defparam R_Current_PC_D.WIDTH_DATA = 32;
	
	D_R_Pipe R_ExcReq_D(ExcReq_PC, ExcReq_D, clk, reset, dp_flush, D_flush, D_En);
	defparam R_ExcReq_D.WIDTH_DATA = 1;
	
	D_R_Pipe R_ExcCode_D(ExcCode_PC, ExcCode_D, clk, reset, dp_flush, D_flush, D_En);
	defparam R_ExcCode_D.WIDTH_DATA = 5;
	
	R_Pipe R_times_D(times, times_D, clk, reset, 1'b0, 1'b1);
	defparam R_times_D.WIDTH_DATA = 32;
	
	//D级流水线寄存器-------------------
	
	assign ExcReq_D_out = (Illegal_Instr || ExcReq_D);			//当前级产生异常或者前一级流水产生异常都会导致当前级异常
	assign ExcCode_D_out = (ExcReq_D)? ExcCode_D:
								  (Illegal_Instr)? `RI:
															5'b0;
	
	NPC dp_NPC (
		
		.imm(IR_D[25:0]), 
		.EPC(EPC),				//再看一下
		.PC4(PC4_D),
		.nPC_sel(nPC_sel),
		.NPC(NPC)
	);
	//NPC----------
	
	//wire RF_En;
	wire [4:0] A3_W;
	RF dp_RF (
		.A1(IR_D[25:21]),
		.A2(IR_D[20:16]),
		.A3(A3_W), 
		.Current_PC(Current_PC_W),
		.RegData(RegData), 
		.clk(clk), 
		.reset(reset), 
		.times_W(times_W),
		.RegWrite(RegWrite), 
		.RD1(RF_RD1), 
		.RD2(RF_RD2)
	);
	
	//RF----------
	
	EXT dp_EXT (
		.imm16(IR_D[15:0]), 
		.ExtOp(ExtOp), 
		.ExOut(ExOut)
	);
	
	//EXT----------
	//wire [31:0] RF_RD1_AM;//经过转发多选器后的RF_RD1
	//wire [31:0] RF_RD2_AM;//经过转发多选器后的RF_RD2
	//wire [1:0] MF_CMP_V1_E_RD1_sel;//input定义
	//wire [1:0] MF_CMP_V2_E_RD2_sel;//input定义
	wire [31:0] DR_W;
	wire [31:0] ALUOut_W;
	
	Mux6to1 MF_CMP_V1_E_RD1(RF_RD1, DM_EXT_out, ALUOut_W, ALUOut_M, PC8_W, PC8_M, MF_CMP_V1_E_RD1_sel, RF_RD1_AM);
	defparam MF_CMP_V1_E_RD1.WIDTH_DATA = 32;
	
	Mux6to1 MF_CMP_V2_E_RD2(RF_RD2, DM_EXT_out, ALUOut_W, ALUOut_M, PC8_W, PC8_M, MF_CMP_V2_E_RD2_sel, RF_RD2_AM);
	defparam MF_CMP_V2_E_RD2.WIDTH_DATA = 32;
	
	//wire Zero;
	CMP dp_CMP(
		.RD1(RF_RD1_AM),
		.RD2(RF_RD2_AM),
		.Zero(Zero),
		.LT0(LT0),
		.BG0(BG0)
	);
	
	wire [31:0] IR_E, IR_M, IR_W;
	wire [31:0] V1_E;
	wire [31:0] V2_E;
	wire [31:0] EXT32_E;
	//wire E_reset;
	
	E_R_Pipe R_IR_E(IR_D, IR_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_IR_E.WIDTH_DATA = 32;
	
	E_R_Pipe R_V1_E(RF_RD1_AM, V1_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_V1_E.WIDTH_DATA = 32;//rs的数据在E级
	
	E_R_Pipe R_V2_E(RF_RD2_AM, V2_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_V2_E.WIDTH_DATA = 32;//rt的数据在E级
	
	E_R_Pipe R_EXT32_E(ExOut, EXT32_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_EXT32_E.WIDTH_DATA = 32;//扩展imm16后数据在E级
	
	E_R_Pipe R_PC8_E(PC8_D, PC8_E, clk, reset, dp_flush, /*E_reset*/1'b0, `E_En);
	defparam R_PC8_E.WIDTH_DATA = 32;//PC8数据在E级
	
	E_R_Pipe R_Current_PC_E(Current_PC_D, Current_PC_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_Current_PC_E.WIDTH_DATA = 32;//Current_PC的数据在E级
	
	E_R_Pipe R_ExcReq_E(ExcReq_D_out, ExcReq_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_ExcReq_E.WIDTH_DATA = 1;
	
	E_R_Pipe R_ExcCode_E(ExcCode_D_out, ExcCode_E, clk, reset, dp_flush, E_reset, `E_En);
	defparam R_ExcCode_E.WIDTH_DATA = 5;
	
	R_Pipe R_times_E(times_D, times_E, clk, reset, 1'b0, 1'b1);
	defparam R_times_E.WIDTH_DATA = 32;
	//E级流水线寄存器-------------------------------
	
	
	wire [31:0] V1_E_AMF;//经过转发多选器后的V1_E
	//wire [1:0] MF_ALU_A_sel;//会改为输入端口
	Mux4to1 MF_ALU_A(V1_E, DM_EXT_out, ALUOut_W, ALUOut_M, MF_ALU_A_sel, V1_E_AMF);
	defparam MF_ALU_A.WIDTH_DATA = 32;
	
	wire [31:0] V2_E_AMF;//经过转发多选器后的V2_E
	//wire [1:0] MF_ALU_B_V2_M_sel;//会改为输入端口
	Mux4to1 MF_ALU_B_V2_M(V2_E, DM_EXT_out, ALUOut_W, ALUOut_M, MF_ALU_B_V2_M_sel, V2_E_AMF);
	defparam MF_ALU_B_V2_M.WIDTH_DATA = 32;
	
	wire [31:0] V1_E_AM;//经过移位选择器后的V1_E
	Mux2to1 MUX_ALU_A(V1_E_AMF, {27'b0, IR_E[10:6]}, ALU_A_sel, V1_E_AM);
	defparam MUX_ALU_A.WIDTH_DATA = 32;
	
	wire [31:0] V2_E_AM;//经过与ext32功能多选器后的V2_E
	Mux2to1 MUX_ALU_B(V2_E_AMF, EXT32_E, ALU_B_sel, V2_E_AM);
	defparam MUX_ALU_B.WIDTH_DATA = 32;
	
	//*****溢出检测*****//
	wire Overflow;
	assign ExcReq_E_out = (Overflow || ExcReq_E);			//当前级产生异常或者前一级流水产生异常都会导致当前级异常
	assign ExcCode_E_out = (ExcReq_E)? ExcCode_E:
										  (Overflow)? `Ov: 
															5'b0;
	
	ALU dp_ALU (
		.IR_E(IR_E),
		.SrcA(V1_E_AM), 
		.SrcB(V2_E_AM), 
		.ALUctr(ALUctr), 
		.ALUResult(ALUResult),
		.Overflow(Overflow)
	);
	
	
	//*********Mul_Div 变量*******//
	/*wire [31:0] HI;
	wire [31:0] LO;
	wire EI_HILO_ctr;					//异常级前面是乘除指令，则清除hilo寄存器
	
	MUL_DIV dp_Mul_Div(
		clk,
		reset,
		V1_E_AM,
		V2_E_AM,
		Mul_Div_ctr,
		Start,
		EI_HILO_ctr,
		ExcReq_E,
		Busy,
		HI,
		LO
	);*/
	
	/*wire [31:0] MD_ALU_out;		//HI与LO与ALUResult中选一个进行流水
	Mux3to1 MUX_MD_ALU(ALUResult, LO, HI, HiLo, MD_ALU_out);*/
	//E级部件-------------
	
	wire [31:0] V2_M;
	
	R_Pipe R_IR_M(IR_E, IR_M, clk, reset, dp_flush, `M_En);
	defparam R_IR_M.WIDTH_DATA = 32;
	
	R_Pipe R_ALUOut_M(ALUResult, ALUOut_M, clk, reset, dp_flush, `M_En);
	defparam R_ALUOut_M.WIDTH_DATA = 32;//alu计算结果的数据在M级
	
	R_Pipe R_V2_M(V2_E_AMF, V2_M, clk, reset, dp_flush, `M_En);
	defparam R_V2_M.WIDTH_DATA = 32;//rt（经过多选器转换）的数据在M级
	
	R_Pipe R_PC8_M(PC8_E, PC8_M, clk, reset, dp_flush, `M_En);
	defparam R_PC8_M.WIDTH_DATA = 32;//PC8的数据在M级
	
	R_Pipe R_Current_PC_M(Current_PC_E, Current_PC_M, clk, reset, dp_flush, `M_En);
	defparam R_Current_PC_M.WIDTH_DATA = 32;
	
	R_Pipe R_ExcReq_M(ExcReq_E_out, ExcReq_M, clk, reset, dp_flush, `M_En);
	defparam R_ExcReq_M.WIDTH_DATA = 1;
	
	R_Pipe R_ExcCode_M(ExcCode_E_out, ExcCode_M, clk, reset, dp_flush, `M_En);
	defparam R_ExcCode_M.WIDTH_DATA = 5;
	
	R_Pipe R_times_M(times_E, times_M, clk, reset, 1'b0, 1'b1);
	defparam R_times_M.WIDTH_DATA = 32;
	
	//M级流水线寄存器-----------
	
	//wire [31:0] V2_M_AMF;			//output给bridge
	
	//wire MF_WD_sel;//会有input定义
	Mux2to1 MF_WD(V2_M, DM_EXT_out, MF_WD_sel, V2_M_AMF);
	defparam MF_WD.WIDTH_DATA = 32;
	//W到M的转发多选器
	
	BE dp_BE(ALUOut_M[1:0], S_Instr, Byte_sel);//产生选择字节信号
	
	
	wire DMWr;											//防止因写设备而误写DM的情况
	wire HitDM;
	wire HitDev;
	assign HitDev = (((ALUOut_M >= 32'h00007f00) && (ALUOut_M <= 32'h00007f0b)) || ((ALUOut_M >= 32'h00007f10) && (ALUOut_M <= 32'h00007f43)));
	assign HitDM = ((ALUOut_M >= 32'h00000000) && (ALUOut_M < 32'h00003000));
	assign DMWr = MemWrite && HitDM && ~S_DataAddrExc && ~ExlSet;
	assign PrWe = MemWrite && HitDev && ~S_DataAddrExc && ~ExlSet;
	
	//******EI_ctr CP0*******//
	wire ExlSet;
	wire ExlClr;
	wire BD;								//SR的BD位
	wire CP0We;
	wire [31:0] PCWrong;				//中断或异常的PC
	//wire EI_HILO_ctr;					//异常级前面是乘除指令，则清除hilo寄存器
	
	wire [31:0] CP0Out;				//mfc0读出寄存器CP0寄存器的值
	
	assign CP0We = (IR_M[31:21] == 11'b01000000100);//M级指令为MTC0
	
	//*****Exc_detector*****//
	wire S_DataAddrExc;
	wire L_DataAddrExc;
	wire IntReq;
	
	assign ExcReq = (S_DataAddrExc | L_DataAddrExc | ExcReq_M);
	assign ExcCode = (IntReq)? `Int:
						  (ExcReq_M)? ExcCode_M:
						  (S_DataAddrExc)? `AdES:
						  (L_DataAddrExc)? `AdEL:
													5'b0;
													
	
	Exc_detector_M dp_Exc_detector_M (
		.IR_M(IR_M), 
		.ADDR(ALUOut_M), 
		.HitDM(HitDM), 
		.HitDev(HitDev), 
		.CP0We(CP0We), 
		.Rd_CP0(Rd_CP0), 
		.S_DataAddrExc(S_DataAddrExc), 
		.L_DataAddrExc(L_DataAddrExc)
	);
	
	EI_controller dp_EI_controller(
		.IntReq(IntReq), 
		.ExcReq(ExcReq), 				//流水线逻辑产生。还没做
		.IR_E(IR_E), 
		.IR_M(IR_M), 
		.IR_W(IR_W), 
		.PC8_D(PC8_D), 
		.PC8_E(PC8_E), 
		.PC8_M(PC8_M), 
		.dp_flush(dp_flush), 		//异常或中断后产生的清除信号，所有DEMW级都用，还没做
		.ExlSet(ExlSet), 
		.ExlClr(ExlClr), 
		.BD(BD), 
		.PC_EI(PC_EI), 
		//.PC_ERET(PC_ERET), EI内部没改
		//.EI_HILO_ctr(EI_HILO_ctr),				//异常级前面是乘除指令，则清除hilo寄存器
		.PCWrong(PCWrong)
	);
	
	CP0 dp_CP0(
		.clk(clk), 
		.reset(reset), 
		.A1_R(Rd_CP0), 
		.A2_W(A3_in), 
		.DataIn(ALUOut_M), 
		.PC(PCWrong), 
		.PC_forward(V2_M_AMF),	//W级为mfc0，M级为mtc0
		.ExcCode_I(ExcCode),    //悬而未决
		.HWInt(HWInt), 
		.We(CP0We), 
		.ExlSet(ExlSet), 
		.ExlClr(ExlClr), 
		.BD_I(BD), 					//W级为跳转指令，此时W级不要写寄存器堆
		.IntReq(IntReq), 
		.EPC_O(EPC), 
		.DataOut(CP0Out)
	);
	
	wire [31:0] DMOut;
	DM dp_DM (
		.clk(clk_), 
		.reset(reset), 
		.times_M(times_M),
		.Instr_addr(Current_PC_M),
		.MemWrite(DMWr), 
		.MemAddr(ALUOut_M), 
		.Byte_sel(Byte_sel),
		.DataIn(V2_M_AMF/*V2_W*/), 
		.MemOut(DMOut)
	);
	//此处DMOut与CP0和Bridge返回的数据有一个多选器
	
	wire [31:0] DMOut_Bri_CP0;				//由DM，Bridge，CP0选择一个回去
	
	assign DMOut_Bri_CP0 = (CP0_sel == 1)? CP0Out://是啥呢
								  (HitDM)? DMOut:
												PrRD;								  
	//M级部件----------------

	
	R_Pipe R_IR_W(IR_M, IR_W, clk, reset, dp_flush, `W_En);
	defparam R_IR_W.WIDTH_DATA = 32;
	
	R_Pipe R_ALUOut_W(ALUOut_M, ALUOut_W, clk, reset, dp_flush, `W_En);
	defparam R_ALUOut_W.WIDTH_DATA = 32;//alu计算结果的数据在W级
	
	R_Pipe R_DR_W(DMOut_Bri_CP0, DR_W, clk, reset, dp_flush, `W_En);
	defparam R_DR_W.WIDTH_DATA = 32;//DM取出的数据在W级
	
	R_Pipe R_PC8_W(PC8_M, PC8_W, clk, reset, dp_flush, `W_En);
	defparam R_PC8_W.WIDTH_DATA = 32;//PC8的数据在W级
	
	R_Pipe R_A3_W(A3_in, A3_W, clk, reset, dp_flush, `W_En);
	defparam R_A3_W.WIDTH_DATA = 5;//写回至A3的数据索引在W级
	
	R_Pipe R_Current_PC_W(Current_PC_M, Current_PC_W, clk, reset, dp_flush, `W_En);
	defparam R_Current_PC_W.WIDTH_DATA = 32;
	
	R_Pipe R_times_W(times_M, times_W, clk, reset, dp_flush, 1'b1);
	defparam R_times_W.WIDTH_DATA = 32;
	
	//W级流水线寄存器
	
	//wire [31:0] DM_EXT_out;//DM_EXT扩展后数据
	DM_EXT dp_DM_EXT(DR_W, ALUOut_W[1:0], L_Instr, DM_EXT_out);
	
	Mux3to1 MUX_Mem_to_Reg(ALUOut_W, DM_EXT_out, PC8_W, Mem_to_Reg_sel, RegData);
	defparam MUX_Mem_to_Reg.WIDTH_DATA = 32;//写回regfile的数据功能选择器
	
endmodule
