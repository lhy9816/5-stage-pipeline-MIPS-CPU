`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
`define DEBUG_Timer_Data 32'h16231138
module Bridge(
    input [31:0] PrAddr,							//ALUOut_M选择设备的地址
    input [31:0] PrWD,								//from (V2_M_AMF)
    input [3:0] PrBE,								//from Byte_sel
    input PrWe,										//流水线M级产生
    output [31:0] PrRD,								//回到DMOut处
    output [7:2] HWInt,								//设备中断信号请求汇总
    
	 input Timer0IRQ,
	 input uart_int,
	 
    output [3:2] Timer_Addr,
	 output [31:0] Dev_Addr, uart_Addr,
    input [31:0] Timer0_RD, uart_RD, DGT_RD, Switch64_RD, LED_RD, Userinput_RD,
	 
    output [31:0] Dev_WD,//Timer_WD
    output Timer0We, uartWe, DGTWe, LEDWe
    );
	
	wire HitTimer0;	
	wire HitDGT;
	wire Hituart;
	wire HitSwitch64;
	wire HitLED;
	wire HitUserinput;
	
	assign HitTimer0 = (PrAddr[31:4] == 'h00007f0);
	assign HitDGT = (PrAddr == 32'h00007f38) || (PrAddr == 32'h00007f3c);
	assign Hituart = (PrAddr >= 32'h00007f10) && (PrAddr <= 32'h00007f2b);
	assign HitSwitch64 = (PrAddr == 32'h00007f2c) || (PrAddr == 32'h00007f30);
	assign HitLED = (PrAddr == 32'h00007f34);
	assign HitUserinput = (PrAddr == 32'h00007f40);
	
	assign Timer_Addr = PrAddr[3:2];										//选择timer内部的寄存器
	assign uart_Addr = PrAddr - 32'h00007f10;
	assign Dev_Addr = PrAddr;
	assign HWInt = {4'b0, /*Timer1IRQ*/uart_int, Timer0IRQ};						//设备中断
	assign PrRD = (Hituart)? uart_RD:
					  (HitDGT)? DGT_RD:
					  (HitSwitch64)? Switch64_RD:
					  (HitLED)? LED_RD:
					  (HitUserinput)? Userinput_RD:
					  (HitTimer0)? Timer0_RD:
					  `DEBUG_Timer_Data;										//选择从timer写入的数据
	
	assign Timer0We = (PrWe & HitTimer0/* & ~Exc*/);
	assign DGTWe = (PrWe & HitDGT);
	assign uartWe = (PrWe & Hituart);
	assign LEDWe = (PrWe & HitLED);
	
	
	assign Dev_WD = (PrBE == 4'b1111) ? PrWD:
							(PrBE == 4'b1100) ? {PrWD[15:0], PrRD[15:0]}:
							(PrBE == 4'b0011) ? {PrRD[31:16], PrWD[15:0]}:
							(PrBE == 4'b1000) ? {PrWD[7:0], PrRD[23:0]}:
							(PrBE == 4'b0100) ? {PrRD[31:24], PrWD[7:0], PrRD[15:0]}:
							(PrBE == 4'b0010) ? {PrRD[31:16], PrWD[7:0], PrRD[7:0]}:
							(PrBE == 4'b0001) ? {PrRD[31:8], PrWD[7:0]}:
																					PrRD;

endmodule
