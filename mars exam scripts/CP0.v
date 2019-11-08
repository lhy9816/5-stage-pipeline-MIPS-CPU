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
	//reg [31:0] Cause;								//��¼�����ԭ��
	reg [31:0] EPC;								//��������PC
	reg [31:0] PRId;								//���ԼĴ���
	
	reg [15:10] Im;								//6λ�ж�����λ
	reg Exl;											//�쳣����1Ϊ�Ѿ������ж�
	reg Ie;											//ȫ���ж�ʹ��	
	reg [6:2] ExcCode;							//�жϻ��쳣��ԭ���¼����Cause
	
	reg [15:10] Ip;											//��¼��ЩӲ���ж���Ч
	reg BD;														//��¼�쳣�ж�ָ���Ƿ�Ϊ�ӳٲ�ָ��
	
	/*initial 
		begin
			Im <= 6'b000000;												//CPU����
			Exl <= 0;											//ExlSetʱд��
			Ie <= 1'b0;											//hw_pind										//CPU����
			Ip <= 0;												//������������д��
			ExcCode <= 0;										//ExlSetʱд��
			BD <= 0;												//������������д��
			
			PRId <= 32'h16231137;				//���Ա��
			//SR <= 0;//{16'b0, Im, 8'b0, Exl, Ie};
			//Cause <= {16'b0, Ip, 10'b0};
			//Cause <= 0;//{BD, 15'b0, Ip, 3'b0, ExcCode, 2'b0};
			EPC <= 32'h00000000;
			
		end*/											//��ʼ��
	
	assign EPC_O = (We && (A2_W == 5'd14))? PC_forward: EPC;							//�����EPC���ź�����EPC��
	
	assign DataOut = (A1_R == 5'd12)? {16'b0, Im, 8'b0, Exl, Ie}://SR:
						  (A1_R == 5'd13)? {BD, 15'b0, Ip, 3'b0, ExcCode, 2'b0}://Cause:
						  (A1_R == 5'd14)? EPC:
						  (A1_R == 5'd15)? PRId:
												32'b0;
												
	assign IntReq = |(HWInt[7:2] & Im[15:10]) & Ie & !Exl;  //�����ж��ź�
	
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
					PRId <= 32'h16231137;				//���Ա��
					EPC <= 32'b0;
				end
			else
				begin
					Ip <= HWInt[7:2]/* & Im*/;								//�����ж����ж�������Ч�ó����ڸ�λ��û���ж�
					//BD <= BD_I;
					if(ExlSet)//��IntReqͬʱ����
						begin
							BD <= BD_I;
							ExcCode <= ExcCode_I[6:2];
							Exl <= 1'b1;
							if(BD_I)
								EPC <= PC - 4;				//BD����λʱ�ʹ����ӳٲ�ǰ�ķ�ָ֧��
							else if(BD_I == 0)
								EPC <= PC;					
						end
					else if(ExlClr)								//д���ˣ�����M����RI_controller�е�PC_ERETͬʱ����
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
