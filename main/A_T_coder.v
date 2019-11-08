`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:43:53 12/06/2017 
// Design Name: 
// Module Name:    A_T_coder 
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
`define ALU_ 2'b01
`define DM 2'b10
`define NW 2'b00
`define PC 2'b11
`define R_Instr 6'b000000
`define CP0_Instr 6'b010000
`define Ir_ADD 6'b100000
`define Ir_ADDU 6'b100001
`define Ir_ADDI 6'b001000
`define Ir_SUB 6'b100010
`define Ir_SUBU 6'b100011
`define Ir_JR 6'b001000
`define Ir_ORI 6'b001101
`define Ir_LW 6'b100011
`define Ir_LH 6'b100001
`define Ir_LHU 6'b100101
`define Ir_LB 6'b100000
`define Ir_LBU 6'b100100
`define Ir_SW 6'b101011
`define Ir_BEQ 6'b000100
`define Ir_BNE 6'b000101
`define Ir_LUI 6'b001111
`define Ir_J 6'b000010
`define Ir_JAL 6'b000011
`define Ir_JALR 6'b001001
`define Ir_ADDIU 6'b001001
`define Ir_OR 6'b100101
`define Ir_XOR 6'b100110
`define Ir_XORI 6'b001110
`define Ir_NOR 6'b100111
`define Ir_AND 6'b100100
`define Ir_ANDI 6'b001100
`define Ir_SLT 6'b101010
`define Ir_SLTU 6'b101011
`define Ir_SLTI 6'b001010
`define Ir_SLTIU 6'b001011
`define Ir_SLL 6'b000000
`define Ir_SRA 6'b000011
`define Ir_SRL 6'b000010
`define Ir_SLLV 6'b000100
`define Ir_SRAV 6'b000111
`define Ir_SRLV 6'b000110
//`define Ir_MFHI 6'b010000
//`define Ir_MFLO 6'b010010
`define Ir_MFC0 5'b00000
//`define Ir_BGEZAL 5'b10001
module A_T_coder(//Instr, A3_sel, BG0, A1_D, A2_D, A3_D, Tuse_RS0, Tuse_RS1, Tuse_RT0, Tuse_RT1, Tuse_RT2, Res);
	input [31:0] Instr,
	input [1:0] A3_sel,
	input BG0,
	output [4:0] A1_D,
	output [4:0] A2_D,
	output [4:0] A3_D,
	output [4:0] Rd_CP0,
	output Tuse_RS0,
	output Tuse_RS1,
	output Tuse_RT0,
	output Tuse_RT1,
	output Tuse_RT2,
	output Tuse_CP0_0,
	output Tuse_CP0_2,
	output [1:0] Res_CP0,
	output reg [1:0] Res
	);
	
	wire [5:0] Op;
	wire [5:0] Funct;
	wire [4:0] Rt;
	wire [4:0] Rs;

	assign Op = Instr[31:26];
	assign Funct = Instr[5:0];
	assign Rs = Instr[25:21];
	assign Rt = Instr[20:16];
	assign Rd_CP0 = Instr[15:11];
	
	assign A1_D = Instr[25:21];//rs位置的值
	assign A2_D = Instr[20:16];//rt位置的值
	Mux3to1 MUX_A3_D(Instr[15:11], Instr[20:16], 5'd31, A3_sel, A3_D);
	defparam MUX_A3_D.WIDTH_DATA = 5;//rd位置的值
	
	//生成信号名
	assign add = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && ~Funct[1] && ~Funct[0];
	assign addu = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && ~Funct[1] && Funct[0];
	assign addi = ~Op[5] && ~Op[4] && Op[3] && ~Op[2] && ~Op[1] && ~Op[0];
	assign sub = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && Funct[1] && ~Funct[0];
	assign subu = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && Funct[1] && Funct[0];
	assign ori = ~Op[5] && ~Op[4] && Op[3] && Op[2] && ~Op[1] && Op[0];
	assign lw = Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && Op[1] && Op[0];
	assign lh = Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && Op[0];
	assign lhu = Op[5] && ~Op[4] && ~Op[3] && Op[2] && ~Op[1] && Op[0];
	assign lb = Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && ~Op[0];
	assign lbu = Op[5] && ~Op[4] && ~Op[3] && Op[2] && ~Op[1] && ~Op[0];
	assign sw = Op[5] && ~Op[4] && Op[3] && ~Op[2] && Op[1] && Op[0];
	assign sh = Op[5] && ~Op[4] && Op[3] && ~Op[2] && ~Op[1] && Op[0];
	assign sb = Op[5] && ~Op[4] && Op[3] && ~Op[2] && ~Op[1] && ~Op[0];
	assign beq = ~Op[5] && ~Op[4] && ~Op[3] && Op[2] && ~Op[1] && ~Op[0];
	assign bne = ~Op[5] && ~Op[4] && ~Op[3] && Op[2] && ~Op[1] && Op[0];
	assign lui = ~Op[5] && ~Op[4] && Op[3] && Op[2] && Op[1] && Op[0];
	assign j = ~Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && Op[1] && ~Op[0];
	assign jal = ~Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && Op[1] && Op[0];
	assign jr = !Op && ~Funct[5] && ~Funct[4] && Funct[3] && ~Funct[2] && ~Funct[1] && ~Funct[0];
	assign jalr = !Op && ~Funct[5] && ~Funct[4] && Funct[3] && ~Funct[2] && ~Funct[1] && Funct[0];
	assign addiu = ~Op[5] && ~Op[4] && Op[3] && ~Op[2] && ~Op[1] && Op[0];
	assign bgez = ~Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && Op[0] && ~Rt[4] && ~Rt[3] && ~Rt[2] && ~Rt[1] && Rt[0];//
	assign bgtz = ~Op[5] && ~Op[4] && ~Op[3] && Op[2] && Op[1] && Op[0];
	assign blez = ~Op[5] && ~Op[4] && ~Op[3] && Op[2] && Op[1] && ~Op[0];
	assign bltz = ~Op[5] && ~Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && Op[0] && !Rt;//
	assign and_ = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && ~Funct[1] && ~Funct[0];
	assign andi = ~Op[5] && ~Op[4] && Op[3] && Op[2] && ~Op[1] && ~Op[0];
	assign or_ = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && ~Funct[1] && Funct[0];
	assign xor_ = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && Funct[1] && ~Funct[0];
	assign xori = ~Op[5] && ~Op[4] && Op[3] && Op[2] && Op[1] && ~Op[0];
	assign nor_ = !Op && Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && Funct[1] && Funct[0];
	
	assign slt = !Op && Funct[5] && ~Funct[4] && Funct[3] && ~Funct[2] && Funct[1] && ~Funct[0];
	assign sltu = !Op && Funct[5] && ~Funct[4] && Funct[3] && ~Funct[2] && Funct[1] && Funct[0];
	assign slti = ~Op[5] && ~Op[4] && Op[3] && ~Op[2] && Op[1] && ~Op[0];
	assign sltiu = ~Op[5] && ~Op[4] && Op[3] && ~Op[2] && Op[1] && Op[0];
		
	assign sll = !Op && ~Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && ~Funct[1] && ~Funct[0];
	assign sra = !Op && ~Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && Funct[1] && Funct[0];
	assign srl = !Op && ~Funct[5] && ~Funct[4] && ~Funct[3] && ~Funct[2] && Funct[1] && ~Funct[0];
	assign sllv = !Op && ~Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && ~Funct[1] && ~Funct[0];
	assign srav = !Op && ~Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && Funct[1] && Funct[0];
	assign srlv = !Op && ~Funct[5] && ~Funct[4] && ~Funct[3] && Funct[2] && Funct[1] && ~Funct[0];

	
	assign eret = ~Op[5] && Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && ~Op[0] && ~Funct[5] && Funct[4] && Funct[3] && ~Funct[2] && ~Funct[1] && ~Funct[0];
	assign mfc0 = ~Op[5] && Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && ~Op[0] && !Rs;
	assign mtc0 = ~Op[5] && Op[4] && ~Op[3] && ~Op[2] && ~Op[1] && ~Op[0] && ~Rs[4] && ~Rs[3] && Rs[2] && ~Rs[1] && ~Rs[0];
	
	
	assign Tuse_RS0 = beq | bne | jr | bgez | bgtz | blez | bltz | jalr;
	assign Tuse_RS1 = add | addu | addi | sub | subu | and_ | andi | or_ | xor_ | xori | nor_ | ori | lw | lh | lhu | lb | lbu | sw | sh | sb | addiu | slt | sltu | slti | sltiu | sllv | srav | srlv;
	assign Tuse_RT0 = beq | bne;
	assign Tuse_RT1 = add | addu | sub | subu | and_ | or_ | xor_ | nor_ | slt | sltu | sll | sra | srl | sllv | srav | srlv;
	assign Tuse_RT2 = sw | sh | sb | mtc0;
	
	assign Tuse_CP0_0 = eret;
	assign Tuse_CP0_2 = mfc0;
	assign Res_CP0 = mtc0? `ALU_: `NW;
	
	//生成Res
	always@(*)
		begin
			case(Op)
				`R_Instr: case(Funct)
								`Ir_ADD: Res <= `ALU_;
								`Ir_ADDU: Res <= `ALU_;
								`Ir_SUB: Res <= `ALU_;
								`Ir_SUBU: Res <= `ALU_;
								`Ir_AND: Res <= `ALU_;
								`Ir_OR: Res <= `ALU_;
								`Ir_XOR: Res <= `ALU_;
								`Ir_NOR: Res <= `ALU_;
								`Ir_JALR: Res <= `PC;
								`Ir_SLT: Res <= `ALU_;
								`Ir_SLTU: Res <= `ALU_;
								`Ir_SLL: Res <= `ALU_;
								`Ir_SRA: Res <= `ALU_;
								`Ir_SRL: Res <= `ALU_;
								`Ir_SLLV: Res <= `ALU_;
								`Ir_SRAV: Res <= `ALU_;
								`Ir_SRLV: Res <= `ALU_;
								//`Ir_MFHI: Res <= `ALU;
								//`Ir_MFLO: Res <= `ALU;
				
								default: Res <= `NW;
							 endcase
							 
				`CP0_Instr: case(Rs)
									`Ir_MFC0: Res <= `DM;
									default: Res <= `NW;
								endcase
								
				`Ir_ADDI: Res <= `ALU_;
				`Ir_ANDI: Res <= `ALU_;
				`Ir_ADDIU: Res <= `ALU_;
				`Ir_ORI: Res <= `ALU_;
				`Ir_XORI: Res <= `ALU_;
				`Ir_LUI: Res <= `ALU_;
				`Ir_SLTI: Res <= `ALU_;
				`Ir_SLTIU: Res <= `ALU_;
				`Ir_LW: Res <= `DM;
				`Ir_LH: Res <= `DM;
				`Ir_LHU: Res <= `DM;
				`Ir_LB: Res <= `DM;
				`Ir_LBU: Res <= `DM;
				`Ir_JAL: Res <= `PC;
				
				default: Res <= `NW;
			endcase
		end
endmodule
