`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:53:48 12/07/2017 
// Design Name: 
// Module Name:    hazard_detector 
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
`define ALU 2'b01
`define DM 2'b10
`define NW 2'b00
`define PC 2'b11
module hazard_detector(//A1_D, A2_D, A3_D, A3_E, A3_M, Res_E, Res_M, Tuse_RS0, Tuse_RS1, Tuse_RT0, Tuse_RT1, Tuse_RT2, Res, Stall);
	input [4:0] A1_D,
	input [4:0] A2_D,
	input [4:0] A3_D,
	input [4:0] A3_E,
	input [4:0] A3_M,
	input [1:0] Res_E,
	input [1:0] Res_M,
	input Tuse_RS0,
	input Tuse_RS1,
	input Tuse_RT0,
	input Tuse_RT1,
	//input Tuse_RT2,
	input Tuse_CP0_0,
	input Tuse_CP0_2,
	input [1:0] Res,
	input [1:0] Res_CP0,
	input [1:0] Res_CP0_E,
	input [1:0] Res_CP0_M,
	//input Start_E,
	//input Busy,
	//input M_D_Instr,
	output Stall
	);
	
	wire Stall_RS0_E1;//rs在D级使用但新值在M级产生(Tnew在E处检测)
	wire Stall_RS0_E2;//rs在D级使用但新值在W级产生(Tnew在E处检测)
	wire Stall_RS0_M1;//rs在D级使用但新值在W级产生(Tnew在M处检测)
	wire Stall_RS1_E2;//rs在E级使用但新值在W级产生(Tnew在E处检测)
	wire Stall_RT0_E1;
	wire Stall_RT0_E2;
	wire Stall_RT0_M1;
	wire Stall_RT1_E2;
	wire Stall_RS;
	wire Stall_RT;
	//wire Stall_MD;
	wire Stall_CP0;
	
	assign Stall_RS0_E1 = Tuse_RS0 & (Res_E == `ALU) & (A1_D == A3_E)/* & (A3_E != 0)*/;
	assign Stall_RS0_E2 = Tuse_RS0 & (Res_E == `DM) & (A1_D == A3_E)/* & (A3_E != 0)*/;
	assign Stall_RS0_M1 = Tuse_RS0 & (Res_M == `DM) & (A1_D == A3_M)/* & (A3_M != 0)*/;
	assign Stall_RS1_E2 = Tuse_RS1 & (Res_E == `DM) & (A1_D == A3_E)/* & (A3_E != 0)*/;
	
	assign Stall_RS = Stall_RS0_E1 |
							Stall_RS0_E2 |
							Stall_RS0_M1 | 
							Stall_RS1_E2;

	assign Stall_RT0_E1 = Tuse_RT0 & (Res_E == `ALU) & (A2_D == A3_E)/* & (A3_E != 0)*/;
	assign Stall_RT0_E2 = Tuse_RT0 & (Res_E == `DM) & (A2_D == A3_E)/* & (A3_E != 0)*/;
	assign Stall_RT0_M1 = Tuse_RT0 & (Res_M == `DM) & (A2_D == A3_M)/* & (A3_M != 0)*/;
	assign Stall_RT1_E2 = Tuse_RT1 & (Res_E == `DM) & (A2_D == A3_E)/* & (A3_E != 0)*/;
	
	assign Stall_RT = Stall_RT0_E1 |
							Stall_RT0_E2 |
							Stall_RT0_M1 | 
							Stall_RT1_E2;
	
	//assign Stall_MD = M_D_Instr & (Start_E | Busy);							//MD有效时，D级为乘除类指令时暂停
	
	assign Stall_CP0 = Tuse_CP0_0 & (Res_CP0_E == `ALU) & (A3_E == 5'd14);	//mtc0后面接eret
	
	assign Stall = Stall_RS | Stall_RT | Stall_CP0;

endmodule
