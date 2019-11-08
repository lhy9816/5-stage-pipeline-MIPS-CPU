`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:37:34 12/27/2017 
// Design Name: 
// Module Name:    CP0 
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
module CP0(
    input clk,
    input reset,
    input [4:0] A1_R,							//sel
    input [4:0] A2_W,
	 input [31:0] DataIn,
    input [31:0] PC,
	 input [31:0] PC_forward,
    input [6:2] ExcCode_I,
    input [7:2] HWInt,
    input We,
    input ExlSet,
    input ExlClr,
	 input BD_I,
    output IntReq,
    output [31:0] EPC_O,
    output [31:0] DataOut
    );
	
	//reg [31:0] SR;									//
	//reg [31:0] Cause;								//记录出错的原因
	reg [31:0] EPC;								//保存出错的PC
	reg [31:0] PRId;								//个性寄存器
	
	reg [15:10] Im;								//6位中断屏蔽位
	reg Exl;											//异常级，1为已经进入中断
	reg Ie;											//全局中断使能	
	reg [6:2] ExcCode;							//中断或异常的原因记录存入Cause
	
	reg [15:10] Ip;											//记录哪些硬件中断有效
	reg BD;														//记录异常中断指令是否为延迟槽指令
	
	/*initial 
		begin
			Im <= 6'b000000;												//CPU控制
			Exl <= 0;											//ExlSet时写入
			Ie <= 1'b0;											//hw_pind										//CPU控制
			Ip <= 0;												//上升沿无条件写入
			ExcCode <= 0;										//ExlSet时写入
			BD <= 0;												//上升沿无条件写入
			
			PRId <= 32'h16231137;				//个性编号
			//SR <= 0;//{16'b0, Im, 8'b0, Exl, Ie};
			//Cause <= {16'b0, Ip, 10'b0};
			//Cause <= 0;//{BD, 15'b0, Ip, 3'b0, ExcCode, 2'b0};
			EPC <= 32'h00000000;
			
		end*/											//初始化
	
	assign EPC_O = (We && (A2_W == 5'd14))? PC_forward: EPC;							//将输出EPC的信号连到EPC上
	
	assign DataOut = (A1_R == 5'd12)? {16'b0, Im, 8'b0, Exl, Ie}://SR:
						  (A1_R == 5'd13)? {BD, 15'b0, Ip, 3'b0, ExcCode, 2'b0}://Cause:
						  (A1_R == 5'd14)? EPC:
						  (A1_R == 5'd15)? PRId:
												32'b0;
												
	assign IntReq = |(HWInt[7:2] & Im[15:10]) & Ie & !Exl;  //产生中断信号
	
	always@(posedge clk)
		begin
			if(reset)
				begin
					Im <= 6'b000000;
					Exl <= 1'b0;
					Ie <= 1'b0;
					Ip <= 6'b0;
					ExcCode <= 5'b0;
					BD <= 1'b0;	
					PRId <= 32'h16231137;				//个性编号
					EPC <= 32'b0;
				end
			else
				begin
					Ip <= HWInt[7:2]/* & Im*/;								//产生中断且中断屏蔽有效得出现在各位有没有中断
					//BD <= BD_I;
					if(ExlSet)//与IntReq同时产生
						begin
							BD <= BD_I;
							ExcCode <= ExcCode_I[6:2];
							Exl <= 1'b1;
							if(BD_I)
								EPC <= PC - 4;				//BD待置位时就存入延迟槽前的分支指令
							else if(BD_I == 0)
								EPC <= PC;					
						end
					else if(ExlClr)								//写错了！！和M级的RI_controller中的PC_ERET同时产生
						begin
							Exl <= 1'b0;
							BD <= 1'b0;
						end
					else 
						if(We)
							begin
								case(A2_W)
									5'd12: {Im, Exl, Ie} <= {DataIn[15:10], DataIn[1], DataIn[0]};
									//5'd13: Cause <= DataIn;
									5'd14: EPC <= DataIn;
								default: PRId <= 32'h16231137;
							
								endcase
							end
			
				end
		end
	
endmodule
