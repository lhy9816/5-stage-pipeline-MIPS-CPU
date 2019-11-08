`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:44:56 12/30/2017 
// Design Name: 
// Module Name:    timer 
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
`define ctrl 2'b00
`define preset 2'b01
`define count 2'b10
`define IDLE 2'b00
`define LOAD 2'b01
`define CNTING 2'b10
`define INT 2'b11
`define IDLE_1 2'b00
`define LOAD_1 2'b01
`define CNTING_1 2'b10
`define INT_1 2'b11
module timer(
    input clk,
    input reset,
    input [3:2] ADDR,
    input We,
    input [31:0] DataIn,
    output [31:0] DataOut,
    output IRQ
    );
	 
	 reg [31:0] CTRL;
	 reg [31:0] PRESET;
	 reg [31:0] COUNT;
	 
	 reg [1:0] state;						//״̬�Ĵ���
	 
	 reg IM;									//�ж�����λ
	 reg [2:1] Mode;						//ģʽѡ��λ
	 reg En;									//������ʹ��
	 
	 reg irq;								//�������ж���Ч�Ĵ���
	/*initial
		begin
			IM <= 0;
			Mode <= 0;
			En <= 0;
			CTRL <= 0;//{28'b0, IM, Mode, En};
			PRESET <= 0;					//��д��Ϊ�Ĵ���
			COUNT <= 0;
			irq <= 0;
			state <= `IDLE;
		end*/
	
	
	assign IRQ = ((IM == 1'b1) && (irq == 1'b1))? 1'b1: 1'b0;
	assign DataOut = (ADDR == `count)? COUNT:
						  (ADDR == `preset)? PRESET:
						  (ADDR == `ctrl)? CTRL:
											32'haaaaaaaa;			//DEBUGֵ
	 always@(posedge clk)
		begin
			if(reset)
				begin
					IM <= 1'b0;
					Mode <= 2'b00;
					En <= 1'b0;
					CTRL <= 32'b0;
					PRESET <= 32'b0;
					COUNT <= 32'b0;
					irq <= 1'b0;
					state <= `IDLE;
				end
			else if(We)
				begin
					if((DataIn[0] == 1'b1) && (ADDR == `ctrl))				//��дʹ��Ҫ����Ϊ��Ч��Ҫд��ctrl
						irq <= 1'b0;
					case(ADDR)
						`preset: PRESET <= DataIn;
						`ctrl: begin
									{IM, Mode, En} <= {DataIn[3], DataIn[2:1], DataIn[0]};   //����дcount��������쳣,����sw��ƫ�Ʒ�4 �ı���ʱWeһ��Ϊ0��
									CTRL[3:0] <= DataIn[3:0];
									if(DataIn[0] == 0)
										state <= `IDLE;   //���дctrl�͸���state��idle
								end
						default: PRESET <= PRESET;
					endcase
				end
			else
				begin
					if(CTRL[2:1]/*Mode*/ == 2'b00)
						begin
							case(state)
									`IDLE:begin 
											 if(En)
												begin
													COUNT <= PRESET;
													state <= `LOAD;
												end
											 end
									`LOAD: if(En)
												begin
													COUNT <= COUNT - 1'b1;
													state <= `CNTING;
												end
											 
									`CNTING: if(En)
													begin
														if(COUNT == 1'b1)
															begin
																irq <= 1'b1;
																En <= 1'b0;
																CTRL[0] <= 1'b0;
																state <= `INT;
															end
														else
																begin
																	COUNT <= COUNT - 1'b1;
																	state <= `CNTING;
																end
													end
												
									`INT: 
												begin
													state <= `IDLE;
												end
									default: state <= `IDLE;
							endcase
						end
					else if(CTRL[2:1]/*Mode*/ == 2'b01)
						begin
							case(state)
								`IDLE:begin 
											 if(En)
												begin
													COUNT <= PRESET;
													state <= `LOAD;
												end
											 end
								`LOAD: if(En)
												begin
													COUNT <= COUNT - 1'b1;
													state <= `CNTING;
												end
								`CNTING: if(En)
													begin
														if(COUNT == 1'b1)
															begin
																irq <= 1'b1;
																state <= `INT;
															end
														else
																begin
																	COUNT <= COUNT - 1'b1;
																	state <= `CNTING;
																end
													end
								`INT: //if(En)
										begin
											COUNT <= PRESET;
											irq <= 1'b0;
											state <= `LOAD;
										end
								default: state <= `IDLE;
							endcase
						end
					end
				
				end

endmodule
