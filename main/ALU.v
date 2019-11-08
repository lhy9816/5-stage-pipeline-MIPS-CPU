`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:40:38 11/26/2017 
// Design Name: 
// Module Name:    ALU 
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
module ALU(IR_E, SrcA, SrcB, ALUctr, ALUResult, Overflow);
    input [31:0] IR_E;
	 input [31:0] SrcA;
    input [31:0] SrcB;
    input [3:0] ALUctr;
    output [31:0] ALUResult;
	 output Overflow;
	 
	 wire [31:0] add_alu;
	 wire [31:0] sub_alu;
	 wire [31:0] or_alu;
	 wire [31:0] and_alu;
	 wire [31:0] xor_alu;
	 wire [31:0] nor_alu;
	 wire [31:0] sllv_alu;
	 wire [31:0] srav_alu;
	 wire [31:0] srlv_alu;
	 wire [31:0] mtc0_alu;
	 wire slt_alu;
	 wire sltu_alu;
	 
	 //溢出检测//
	 wire add;
	 wire addi;
	 wire sub;
	 wire add_overflow;
	 wire sub_overflow;
	 wire addi_overflow;
	 wire [32:0] temp_add;
	 wire [32:0] temp_addi;
	 wire [32:0] temp_sub;
	 
	 assign add = ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b100000));
	 assign addi = (IR_E[31:26] == 6'b001000);
	 assign sub = ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b100010));
	 
	 assign add_alu = SrcA+SrcB;
	 assign sub_alu = SrcA-SrcB;
	 assign or_alu = SrcA|SrcB;
	 assign and_alu = SrcA&SrcB;
	 assign xor_alu = SrcA^SrcB;
	 assign nor_alu = ~(SrcA|SrcB);
	 assign sllv_alu = SrcB << SrcA[4:0];
	 assign srav_alu = $signed($signed(SrcB) >>> SrcA[4:0]);
	 assign srlv_alu = SrcB >> SrcA[4:0];
	 assign slt_alu = ($signed(SrcA) < $signed(SrcB));
	 assign sltu_alu = (SrcA < SrcB);
	 assign mtc0_alu = SrcB;
	 
	 assign temp_add = ({SrcA[31], SrcA[31:0]} + {SrcB[31], SrcB[31:0]});
	 assign temp_addi = ({SrcA[31], SrcA[31:0]} + {SrcB[31], SrcB[31:0]});
	 assign temp_sub = ({SrcA[31], SrcA[31:0]} - {SrcB[31], SrcB[31:0]});
	 
	 assign add_overflow = (add && (temp_add[32] != temp_add[31]))? 1'b1: 1'b0;
	 assign addi_overflow = (addi && (temp_addi[32] != temp_addi[31]))? 1'b1: 1'b0;
	 assign sub_overflow = (sub && (temp_sub[32] != temp_sub[31]))? 1'b1: 1'b0;
	 
	 assign Overflow = add_overflow | sub_overflow | addi_overflow;
	 
	 Mux12to1 MUX_ALU(add_alu, sub_alu, or_alu, and_alu, xor_alu, nor_alu, sllv_alu, srav_alu, srlv_alu, {31'b0, slt_alu}, {31'b0, sltu_alu}, mtc0_alu, ALUctr[3:0]/*位宽合不合适？*/,ALUResult);
	 defparam MUX_ALU.WIDTH_DATA = 32;
	 //assign ALUResult = (ALUctr[1] == 1)? (ALUctr[0] == 1? 32'b0: (SrcA | SrcB)):
													  //LUctr[0] == 1? (SrcA - SrcB): (SrcA + SrcB));

endmodule
