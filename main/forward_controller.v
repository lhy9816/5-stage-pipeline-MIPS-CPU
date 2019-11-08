`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:20:49 12/07/2017 
// Design Name: 
// Module Name:    forward_controller 
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
`define M_to_D_PC 3'd5
`define W_to_D_PC 3'd4
`define M_to_D_ALU  3'd3
`define W_to_D_ALU  3'd2
`define W_to_D_DM  3'd1

`define M_to_E_ALU  2'd3
`define W_to_E_ALU  2'd2
`define W_to_E_DM  2'd1
`define W_to_M_ALU  2'd2
`define W_to_M_DM  1'd1

`define ALU 2'b01
`define DM 2'b10
`define NW 2'b00
`define PC 2'b11
module forward_controller(A1_D, A2_D, A1_E, A2_E, A2_M, A3_M, A3_W, Res_M, Res_W, MF_CMP_V1_E_RD1_sel, MF_CMP_V2_E_RD2_sel, MF_ALU_A_sel, MF_ALU_B_V2_M_sel, MF_WD_sel);
	input [4:0] A1_D;
	input [4:0] A2_D;
	input [4:0] A1_E;
	input [4:0] A2_E;
	input [4:0] A2_M;
	input [4:0] A3_M;
	input [4:0] A3_W;
	input [1:0] Res_M;//M¼¶Tnew
	input [1:0] Res_W;//W¼¶Tnew
	output [2:0] MF_CMP_V1_E_RD1_sel;
	output [2:0] MF_CMP_V2_E_RD2_sel;
	output [1:0] MF_ALU_A_sel;
	output [1:0] MF_ALU_B_V2_M_sel;
	output MF_WD_sel;
	
	//input Res_E;
	//(A1_D == A3_E)&(Res_E == `PC)&(A3_E != 0)? `E_to_D_PC
	
	//assign MF_EPC_sel
	
	assign MF_CMP_V1_E_RD1_sel = (A1_D == A3_M) & (Res_M == `PC) &(A3_M != 0)? `M_to_D_PC:
										  
									   (A1_D == A3_M) & (Res_M == `ALU)&(A3_M != 0) ? `M_to_D_ALU:
										   (A1_D == A3_W) & (Res_W == `PC)&(A3_W != 0)? `W_to_D_PC:
									   (A1_D == A3_W) & (Res_W == `ALU)&(A3_W != 0) ? `W_to_D_ALU:
										  (A1_D == A3_W) & (Res_W == `DM)&(A3_W != 0) ? `W_to_D_DM:
																								  3'b000;

	assign MF_CMP_V2_E_RD2_sel = (A2_D == A3_M) & (Res_M == `PC)&(A3_M != 0)? `M_to_D_PC:
										  
									  (A2_D == A3_M) & (Res_M == `ALU)&(A3_M != 0) ? `M_to_D_ALU:
									     (A2_D == A3_W) & (Res_W == `PC)&(A3_W != 0)? `W_to_D_PC:
									  (A2_D == A3_W) & (Res_W == `ALU)&(A3_W != 0) ? `W_to_D_ALU:
										 (A2_D == A3_W) & (Res_W == `DM)&(A3_W != 0) ? `W_to_D_DM:
																						        3'b000;
																								  
	assign MF_ALU_A_sel = (A1_E == A3_M)&(Res_M == `ALU)&(A3_M != 0) ? `M_to_E_ALU:
								 (A1_E == A3_W)&(Res_W == `ALU)&(A3_W != 0) ? `W_to_E_ALU:
									 (A1_E == A3_W)&(Res_W ==`DM)&(A3_W != 0) ? `W_to_E_DM:
													                           2'b00;
																						
	assign MF_ALU_B_V2_M_sel = (A2_E == A3_M)&(Res_M == `ALU)&(A3_M != 0) ? `M_to_E_ALU:
										(A2_E == A3_W)&(Res_W == `ALU)&(A3_W != 0) ? `W_to_E_ALU:
											(A2_E == A3_W)&(Res_W ==`DM)&(A3_W != 0) ? `W_to_E_DM:
													                           2'b00;
																						
	assign MF_WD_sel = (A2_M == A3_W)&(Res_W == `DM)&(A3_W != 0) ? `W_to_M_DM: 1'b0;


endmodule
