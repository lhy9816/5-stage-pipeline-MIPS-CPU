`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
`define ADD4 2'b00
`define NPC 2'b01
`define RF_RD1 2'b10

`define Zero_Ext 2'b00
`define Sign_Ext 2'b01
`define Load_Up 2'b10

`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_OR 4'b0010
`define ALU_AND 4'b0011
`define ALU_XOR 4'b0100
`define ALU_NOR 4'b0101
`define ALU_SLLV 4'b0110
`define ALU_SRAV 4'b0111
`define ALU_SRLV 4'b1000
`define ALU_SLT 4'b1001
`define ALU_SLTU 4'b1010
`define ALU_MTC0 4'b1011

`define RD 2'b00
`define RT 2'b01
`define J31 2'b10

`define ALU_ctr 2'b00
`define DR 2'b01
`define PC8 2'b10

`define LW 3'b000
`define LBU 3'b001
`define LB 3'b010
`define LHU 3'b011
`define LH 3'b100

`define SW 3'b000
`define SH 3'b001
`define SB 3'b010

`define HI 2'b10
`define LO 2'b01

`define NE 3'b000
/*`define MTHI 3'b001
`define MTLO 3'b010
`define MULTU 3'b011
`define MULT 3'b100
`define DIVU 3'b101
`define DIV 3'b110*/							//for mul_div
 module main_control(//Instr, Op, Funct, Rt, Zero, LT0, BG0, ExtOp, PC_sel, nPC_sel, ALU_A_sel, ALU_B_sel, ALUctr, Mem_to_Reg_sel, A3_sel, MemWrite, RegWrite, S_Instr, L_Instr, M_D_Instr, Busy_start);
		input [31:0] Instr,//传入数据通路的IR_D,用以区分nop时不去写RF
		input [5:0] Op,
		input [5:0] Funct,
		input [4:0] Rt,
		input Zero,
		input LT0,
		input BG0,
		output [1:0] ExtOp,
		output [1:0] PC_sel,
		output [1:0] nPC_sel,
		output ALU_A_sel,						//for shamt[10:6]
		output ALU_B_sel,
		output [3:0] ALUctr,
		output [1:0] Mem_to_Reg_sel,
		output [1:0] A3_sel,
		output MemWrite,
		output RegWrite,
		output [2:0] S_Instr,				//s类指令sw,sh,sb
		output [2:0] L_Instr,				//l类指令lw, lh, lhu, lb, lbu
		//output M_D_Instr,						//D级为mul或div相关指令
		//output Busy_start,
		//output [2:0] Mul_Div_ctr,			//产生mul_div选择信号
		//output [1:0] HiLo,
		output CP0_sel,						//M级选择CP0的回写数据
		output D_flush,							//eret后面清零D级
		output Illegal_Instr					//非法指令
		);
		
		wire [4:0] Rs;
		assign Rs = Instr[25:21];
		
		//与门阵列
		
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
	
	
		//或门阵列
		assign PC_sel = 								(jr+jalr)? `RF_RD1:
									((bgez&!LT0)+(bltz&LT0)+(beq&Zero)+(bne&!Zero)+(bgtz&BG0)+(blez&!BG0)+j+jal+eret)? `NPC:		
			(and_+or_+xor_+nor_+lw+lh+lhu+lb+lbu+sw+sh+sb+addu+add+addi+subu+sub+ori+andi+xori+lui+(beq&!Zero)+(bne&Zero)+(bgez&LT0)+(bgtz&!BG0)+(bltz&!LT0)+(blez&BG0)+slt+sltu+slti+sltiu+sll+sra+srl+sllv+srav+srlv)? `ADD4:
																			2'b00;
													 
																				
		assign nPC_sel =  eret ? 2'b10:
								(j+jal)? 2'b01: 
											2'b00;
		assign ExtOp =     	lui? `Load_Up:
							(lw+sw+sh+sb+lh+lhu+lb+lbu+addi+addiu+slti+sltiu)? `Sign_Ext:
								 (andi+xori+ori)? `Zero_Ext:
										2'b00;
		
		assign ALU_A_sel = sll + sra + srl;
		assign ALU_B_sel = ori + lw + lh + lhu + lb + lbu + sw + sh + sb + lui + addi + addiu + andi + xori + +slti + sltiu;
		
		assign ALUctr = 		   (mtc0)? `ALU_MTC0:
									   (sltu + sltiu) ? `ALU_SLTU:
										(slt + slti) ? `ALU_SLT:
										(srl + srlv) ? `ALU_SRLV:
										(sra + srav) ? `ALU_SRAV:
										(sll + sllv) ? `ALU_SLLV:
												  nor_ ? `ALU_NOR:
									  (xor_  + xori)? `ALU_XOR:
										(andi + and_)? `ALU_AND:
								(or_ + ori)? `ALU_OR:
							  (sub+subu) ? `ALU_SUB:
										  	   `ALU_ADD;
											  
		assign Mem_to_Reg_sel = 	(jalr+jal)? `PC8:
											(lw+lh+lhu+lb+lbu+mfc0)?  `DR:
														`ALU_ctr;
											  
		assign A3_sel = 				 (jal)? `J31:
						(lh+lw+lhu+lb+lbu+ori+lui+addi+addiu+andi+xori+slti+sltiu+mfc0)? `RT:
												`RD;
		assign MemWrite = sw + sh + sb;
		assign RegWrite = add + addu + sub + subu + ori + addi + lw + lh + lhu + lb + lbu + lui + jal + addiu +and_ + andi + or_ + xor_ + xori + nor_ + jalr + slt + sltu + slti + sltiu + (sll&(Instr != 0)) + sra + srl + sllv + srav + srlv + mfc0;
		assign S_Instr = sb ? `SB:
							  sh ? `SH:
							  sw ? `SW:
									3'b000;
		assign L_Instr = lh ? `LH:
							  lhu ? `LHU:
							  lb ? `LB:
							  lbu ? `LBU:
							  lw ? `LW:
									3'b000;
										
	
						
		assign CP0_sel = mfc0;
		
		assign D_flush = eret;
		
		assign Illegal_Instr = !(add | addi | addiu| addu|and_|andi | beq|bgez|bgtz|blez|bltz|bne
										|eret|j|jal|jalr|jr|lb|lbu|lh|lhu|lui|lw|mfc0|mtc0
										|nor_|or_|ori|sb|sh|sll|sllv|slt|slti|sltiu|sltu|sra|srav|srl|srlv|sub|subu|sw|xor_|xori);
										


endmodule
