`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:27:19 12/30/2017 
// Design Name: 
// Module Name:    EI_controller 
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
`define j (IR_W[31:26] == 6'b000010)
`define jal (IR_W[31:26] == 6'b000011)
`define jalr ((IR_W[31:26] == 6'b000000) && (IR_W[5:0] == 6'b001001))
`define jr ((IR_W[31:26] == 6'b000000) && (IR_W[5:0] == 6'b001000))
`define beq (IR_W[31:26] == 6'b000100)
`define bne (IR_W[31:26] == 6'b000101)
`define bgez ((IR_W[31:26] == 6'b000001) && (IR_W[20:16] == 5'b00001))
`define bgtz (IR_W[31:26] == 6'b000111)
`define blez (IR_W[31:26] == 6'b000110)
//define multu_E ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b011001))
//`define mult_E ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b011000))
//`define divu_E ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b011011))
//`define div ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b011010))
//`define mthi ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b010001))
//`define mtlo ((IR_E[31:26] == 6'b000000) && (IR_E[5:0] == 6'b010011))

//`define multu_M ((IR_M[31:26] == 6'b000000) && (IR_M[5:0] == 6'b011001))
//`define mult_M ((IR_M[31:26] == 6'b000000) && (IR_M[5:0] == 6'b011000))
//`define divu_M ((IR_M[31:26] == 6'b000000) && (IR_M[5:0] == 6'b011011))
//`define div_M ((IR_M[31:26] == 6'b000000) && (IR_M[5:0] == 6'b011010))
//`define mthi_M ((IR_M[31:26] == 6'b000000) && (IR_M[5:0] == 6'b010001))
//`define mtlo_M ((IR_M[31:26] == 6'b000000) && (IR_M[5:0] == 6'b010011))
`define bltz ((IR_W[31:26] == 6'b000001) && (IR_W[20:16] == 5'b00000))
`define eret ((IR_M[31:26] == 6'b010000) && (IR_M[5:0] == 6'b011000))
`define eret_W ((IR_W[31:26] == 6'b010000) && (IR_W[5:0] == 6'b011000))
//`define eret ((IR_W[31:26] == 6'b010000) && (IR_W[5:0] == 6'b011000))
module EI_controller(
    input IntReq,						
    input ExcReq,
	 input [31:0] IR_E,					//清乘除法指令的寄存器
	 input [31:0] IR_M,
    input [31:0] IR_W,
	 input [31:0] PC8_D,
	 input [31:0] PC8_E,
	 input [31:0] PC8_M,
    output dp_flush,
    output ExlSet,
    output ExlClr,
	 output BD,								//当前指令为延迟槽指令
    output PC_EI,
    //output PC_ERET,
	 //output EI_HILO_ctr,
	 output [31:0] PCWrong				//中断异常传入CP0的PC
    );
	
	 wire DelaySlot;
	 //wire MDClr;
	 
	 //assign MDClr = `mult | `multu | `div | `divu | `mthi | `mtlo;
	 
	 //assign MDClr_M = `mult_M | `multu_M | `div_M | `divu_M | `mthi_M | `mtlo_M;
	 
	 assign DelaySlot = `j | `jal | `jalr | `jr | `beq | `bne | `bgez | `bgtz | `blez | `bltz;
	 
	 assign BD = /*(DelaySlot == 1) && ExcReq && ~IntReq;*/(DelaySlot == 1) && ExlSet;
	 
	 assign dp_flush = IntReq | ExcReq;
	 
	 assign ExlSet = IntReq | ExcReq;
	 
	 assign ExlClr = (`eret == 1);
	 
	 assign PC_EI = IntReq | ExcReq;
	 
	 //assign PC_ERET = (`eret == 1);
	 
	 assign PCWrong = (IntReq && `eret_W)? (PC8_E - 8): (PC8_M - 8); //这个看到底有没有eret延迟槽中的中断
							
	 //assign EI_HILO_ctr = MDClr && ExlSet;
endmodule
