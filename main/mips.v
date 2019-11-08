`timescale 1ns / 1ps

module mips(//clk, reset);
	input clk_in, sys_rstn, uart_rxd,
	input[7:0] dip_switch0, dip_switch1, dip_switch2, dip_switch3, dip_switch4, dip_switch5, dip_switch6, dip_switch7,
	output uart_txd,
	input[7:0] user_key,
	output[31:0] led_light, 
	output[7:0] digital_tube0, digital_tube1, digital_tube2,
	output[3:0] digital_tube_sel0, digital_tube_sel1,
	output digital_tube_sel2
	);
	
	wire clk_1, clk_2;
	wire reset;
	wire [7:0] dip_switch00, dip_switch01, dip_switch02, dip_switch03, dip_switch04, dip_switch05, dip_switch06, dip_switch07;
	assign reset = ~sys_rstn;
	assign dip_switch00 = ~dip_switch0;
	assign dip_switch01 = ~dip_switch1;
	assign dip_switch02 = ~dip_switch2;
	assign dip_switch03 = ~dip_switch3;
	assign dip_switch04 = ~dip_switch4;
	assign dip_switch05 = ~dip_switch5;
	assign dip_switch06 = ~dip_switch6;
	assign dip_switch07 = ~dip_switch7;
	
	//为啥？？????
	//???????????
	
	
	//******CPU变量******//
	wire [31:0] Instr;
	wire Zero;
	wire LT0;
	wire BG0;
	wire Busy;
	wire [1:0] ExtOp;
	wire [1:0] PC_sel;
	wire [1:0] nPC_sel;
	wire ALU_A_sel_E;
	wire ALU_B_sel_E;
	wire [3:0] ALUctr_E;
	wire [1:0] Mem_to_Reg_sel_W;
	wire MemWrite_M;
	wire RegWrite_W;
	wire [2:0] S_Instr_M;
	wire [2:0] L_Instr_W;
	wire [4:0] A3_M;									//传给datapath在W级写入的数据地址
	wire [4:0] Rd_CP0_M;
	wire PC_En;											//PC暂停条件，暂停则使能关闭
	wire D_En;											//D级寄存器暂停条件，暂停则使能关闭
	wire E_reset;										//E级寄存器暂停条件，暂停则清零
	wire [2:0] MF_CMP_V1_E_RD1_sel;
	wire [2:0] MF_CMP_V2_E_RD2_sel;
	wire [1:0] MF_ALU_A_sel;
	wire [1:0] MF_ALU_B_V2_M_sel;
	wire  MF_WD_sel;
	//wire Busy_start_E;								//MD工作的触发信号
	//wire [2:0] Mul_Div_ctr_E;						//E级MD运算选择信号
	//wire [1:0] HiLo_E;								//E级HiLo寄存器回写选择信号
	wire CP0_sel_M;									//M级CP0回写选择信号
	
	wire flush;											//for DEMW级	
	wire D_flush;										//for eret后面
	wire Illegal_Instr;
	
	reg [31:0] times;//记录时钟次数
	
	initial
		begin
			times = 0;
		end
	
	always@(posedge clk_1)
		begin
			if(reset)
				times <= 0;
			else
				times <= times + 1;
		end

	

	//*****bridge变量*******//
	wire [31:0] PrAddr;
	wire [31:0] PrWD;
	wire [3:0] PrBE;
	wire PrWe;
	wire [31:0] PrRD;
	wire [7:2] HWInt;
	//*********************//
	
	//*******bridge timer变量*******//
	//wire Timer0IRQ;
	//wire [3:2] Timer_Addr;
	//wire [31:0] Dev_Addr, uart_Addr;
	//wire [31:0] Timer0_RD;
	//wire [31:0] Dev_WD;
	//wire Timer0We;
	//wire DGTWe;
	//wire [31:0] DGT_RD;
	//wire [31:0] S64_RD;
	//wire LEDWe;
	//wire [31:0] LED_RD;
	//wire uartWe;
	//wire [31:0] uart_RD;
	//wire uart_int;
	
	//wire [31:0] Userinput_RD;
	
	//**********device**********//
	wire Timer0We, uartWe, DGTWe, LEDWe;
	wire [31:0] Dev_WD;
	wire [31:0] Timer0_RD, DGT_RD, S64_RD, LED_RD, uart_RD, Userinput_RD;
	wire [3:2] Timer_Addr;
	wire [31:0] Dev_Addr, uart_Addr;
	
	wire Timer0IRQ, uart_int;
	wire [7:0] user_key_in;//?????????????????????
								  //?????????????????????
	assign user_key_in = ~user_key;
	
	
	
	CLK _CLK(clk_in, clk_1, clk_2);
	
	datapath mips_datapath (
		.clk(clk_1), 
		.clk_(clk_2),
		.reset(reset), 
		.times(times),
		.ExtOp(ExtOp), 
		.PC_sel(PC_sel), 
		.nPC_sel(nPC_sel),
		.ALU_A_sel(ALU_A_sel_E), 		
		.ALU_B_sel(ALU_B_sel_E), 
		.ALUctr(ALUctr_E), 
		.Mem_to_Reg_sel(Mem_to_Reg_sel_W), 
		.MemWrite(MemWrite_M), 
		.RegWrite(RegWrite_W),
		.S_Instr(S_Instr_M),
		.L_Instr(L_Instr_W),
		.A3_in(A3_M), 
		.Rd_CP0(Rd_CP0_M),
		.PC_En(PC_En), 
		.D_En(D_En), 
		.E_reset(E_reset), 
		.MF_CMP_V1_E_RD1_sel(MF_CMP_V1_E_RD1_sel), 
		.MF_CMP_V2_E_RD2_sel(MF_CMP_V2_E_RD2_sel), 
		.MF_ALU_A_sel(MF_ALU_A_sel), 
		.MF_ALU_B_V2_M_sel(MF_ALU_B_V2_M_sel), 
		.MF_WD_sel(MF_WD_sel), 
		//.Start(Busy_start_E),
		//.Mul_Div_ctr(Mul_Div_ctr_E),
		//.HiLo(HiLo_E),
		.CP0_sel(CP0_sel_M),
		.D_flush(D_flush),
		.Illegal_Instr(Illegal_Instr),
		
		.Zero(Zero),
		.LT0(LT0),
		.BG0(BG0),
		//.Busy(Busy),
		.IR_D(Instr),
		//****bridge****//
		.PrRD(PrRD),
		.HWInt(HWInt),
		.ALUOut_M(PrAddr),
		.V2_M_AMF(PrWD),
		.Byte_sel(PrBE),
		.PrWe(PrWe),			//datapath传来
		.dp_flush(flush)
	);
	
	controller mips_controller (
		.clk(clk_1), 
		.reset(reset), 
		.Instr(Instr), 
		.Zero(Zero), 
		.LT0(LT0),
		.BG0(BG0),
		//.Busy(Busy),
		.flush(flush),
		.ExtOp(ExtOp), 
		.PC_sel(PC_sel), 
		.nPC_sel(nPC_sel), 
		.ALU_A_sel_E(ALU_A_sel_E), 	
		.ALU_B_sel_E(ALU_B_sel_E), 
		.ALUctr_E(ALUctr_E), 
		.Mem_to_Reg_sel_W(Mem_to_Reg_sel_W), 
		.MemWrite_M(MemWrite_M), 
		.RegWrite_W(RegWrite_W), 
		.S_Instr_M(S_Instr_M),
		.L_Instr_W(L_Instr_W),
		.A3_M(A3_M), 
		.Rd_CP0_M(Rd_CP0_M),
		.PC_En(PC_En), 
		.D_En(D_En), 
		.E_reset(E_reset), 
		.MF_CMP_V1_E_RD1_sel(MF_CMP_V1_E_RD1_sel), 
		.MF_CMP_V2_E_RD2_sel(MF_CMP_V2_E_RD2_sel), 
		.MF_ALU_A_sel(MF_ALU_A_sel), 
		.MF_ALU_B_V2_M_sel(MF_ALU_B_V2_M_sel), 
		.MF_WD_sel(MF_WD_sel),
		//.Busy_start_E(Busy_start_E),
		//.Mul_Div_ctr_E(Mul_Div_ctr_E),
		//.HiLo_E(HiLo_E),
		.CP0_sel_M(CP0_sel_M),
		.D_flush(D_flush),
		.Illegal_Instr(Illegal_Instr)
	);
	

	Bridge mips_bridge(
		.PrAddr(PrAddr), 
		.PrWD(PrWD), 
		.PrBE(PrBE), 
		.PrWe(PrWe), 
		.PrRD(PrRD), 
		.HWInt(HWInt), 
		.Timer0IRQ(Timer0IRQ), 
		.uart_int(uart_int), 
		.Timer_Addr(Timer_Addr),
		.Dev_Addr(Dev_Addr),		
		.uart_Addr(uart_Addr),
		.Timer0_RD(Timer0_RD), 
		.uart_RD(uart_RD),
		.DGT_RD(DGT_RD),
		.Switch64_RD(S64_RD),
		.LED_RD(LED_RD),
		.Userinput_RD(Userinput_RD),
		
		.Dev_WD(Dev_WD), 
		.Timer0We(Timer0We), 
		.uartWe(uartWe),
		.DGTWe(DGTWe),
		.LEDWe(LEDWe)
	);
	
	
	MiniUART dev_MiniUART(
		.ADD_I(uart_Addr[4:2]), 
		.DAT_I(Dev_WD), 
		.DAT_O(uart_RD), 
		.STB_I(uartWe), //???????????????
		.WE_I(uartWe), 
		.CLK_I(clk_1), 
		.RST_I(reset), 
		//.ACK_O(ACK_O), 
		.RxD(uart_rxd), 
		.TxD(uart_txd),
		.uart_int(uart_int)
	);
	

	DGT_driver dev_DGT_driver(clk_1, reset, Dev_WD, Dev_Addr, DGTWe, DGT_RD, digital_tube0, digital_tube1, digital_tube2, digital_tube_sel0, digital_tube_sel1, digital_tube_sel2);
	
	
	Switch64_driver dev_Switch64_driver(Dev_Addr, dip_switch00, dip_switch01, dip_switch02, dip_switch03, dip_switch04, dip_switch05, dip_switch06, dip_switch07, S64_RD);
	
	
	LED_driver dev_LED_driver(clk_1, reset, Dev_WD, LEDWe, LED_RD, led_light);
	
	
	Userinput_driver dev_Userinput_driver(user_key_in, Userinput_RD);
	
	timer mips_timer0(
		.clk(clk_1), 
		.reset(reset), 
		.ADDR(Timer_Addr), 
		.We(Timer0We), 
		.DataIn(Dev_WD), 
		.DataOut(Timer0_RD), 
		.IRQ(Timer0IRQ)
	);
	
	
endmodule

