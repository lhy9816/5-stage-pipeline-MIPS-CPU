`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:58:14 12/19/2017 
// Design Name: 
// Module Name:    DM_EXT 
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
`define LW 3'b000
`define LBU 3'b001
`define LB 3'b010
`define LHU 3'b011
`define LH 3'b100
module DM_EXT(DM_EXT_in, Byte_in, DM_EXT_sel, DM_EXT_out);
	input [31:0] DM_EXT_in;//��ǰDM�ֵ�ַ������32λ���ݣ��Ҿ���W���Ĵ���
	input [1:0] Byte_in;//��ǰDM�ֵ�ַ��ĩ2λ�ֽ�ƫ�ƣ��Ҿ���W���Ĵ���
	input [2:0] DM_EXT_sel;//ѡ�����д��Ĵ����������ֶεĿ����źţ���control��W������
	output [31:0] DM_EXT_out;
	
	/*assign DM_EXT_out = (DM_EXT_sel == `LH) ? {16{DM_EXT_in[15]}, DM_EXT_in[15:0]}:
							  (DM_EXT_sel == `LHU) ? {16'b0, DM_EXT_in[15:0]}:
							  (DM_EXT_sel == `LB) ? {24{DM_EXT_in[7]}, DM_EXT_in[7:0]}:
							  (DM_EXT_sel == `LBU) ? {24'b0, DM_EXT_in[7:0]}:
							  (DM_EXT_sel == `LW) ? DM_EXT_in:
															DM_EXT_in;//����0�أ�*/
	
	assign DM_EXT_out = (DM_EXT_sel == `LH) ? ((Byte_in[1]) ? {{16{DM_EXT_in[31]}}, DM_EXT_in[31:16]}:
																				 {{16{DM_EXT_in[15]}}, DM_EXT_in[15:0]}):
							  (DM_EXT_sel == `LHU) ? ((Byte_in[1]) ? {16'b0, DM_EXT_in[31:16]}: 
																				  {16'b0, DM_EXT_in[15:0]}):		
							  (DM_EXT_sel == `LB) ? ((Byte_in == 3)? {{24{DM_EXT_in[31]}}, DM_EXT_in[31:24]}:
															 (Byte_in == 2)? {{24{DM_EXT_in[23]}}, DM_EXT_in[23:16]}:
															 (Byte_in == 1)? {{24{DM_EXT_in[15]}}, DM_EXT_in[15:8]}:
																				  {{24{DM_EXT_in[7]}}, DM_EXT_in[7:0]}):
							  (DM_EXT_sel == `LBU) ? ((Byte_in == 3)? {24'b0, DM_EXT_in[31:24]}:
															 (Byte_in == 2)? {24'b0, DM_EXT_in[23:16]}:
															 (Byte_in == 1)? {24'b0, DM_EXT_in[15:8]}:
																				  {24'b0, DM_EXT_in[7:0]}):
							  (DM_EXT_sel == `LW) ? DM_EXT_in:
															DM_EXT_in;//����0�أ�
endmodule
