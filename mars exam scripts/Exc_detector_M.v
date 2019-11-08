`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
`define sw (IR_M[31:26] == 6'b101011)
`define sh (IR_M[31:26] == 6'b101001)
`define sb (IR_M[31:26] == 6'b101000)
`define lb (IR_M[31:26] == 6'b100000)
`define lbu (IR_M[31:26] == 6'b100100)
`define lh (IR_M[31:26] == 6'b100001)
`define lhu (IR_M[31:26] == 6'b100101)
`define lw (IR_M[31:26] == 6'b100011)
module Exc_detector_M(
    input [31:0] IR_M,
    input [31:0] ADDR,
    input HitDM,
    input HitDev,
	 input CP0We,
	 input [4:0] Rd_CP0,
    output S_DataAddrExc,
    output L_DataAddrExc
    );
	 
	 wire S_Exc_1, S_Exc_2, S_Exc_3, S_Exc_4;			// 
	 wire L_Exc_1, L_Exc_2;
	 
	 assign S_Exc_1 = (`sw && (ADDR[1:0] != 2'b00)) || (`sh && ADDR[0]); 		//��ַĩ��λ��ָ�ƥ��
	 assign S_Exc_2 = (`sw | `sh | `sb) && ~HitDM && ~HitDev;						//д����DM��Dev��Χ
	 assign S_Exc_3 = (`sw | `sh | `sb) && ((ADDR >= 32'h00007f08 && ADDR <= 32'h00007f0b)/* || (ADDR >= 32'h00007f18 && ADDR <= 32'h00007f1b)*/);	//дtimer��count
	 assign S_Exc_4 = (`sh | `sb) && HitDev;//CP0We && (Rd_CP0 != 5'd12 && Rd_CP0 != 5'd14);
	 
	 assign L_Exc_1 = (`lw && (ADDR[1:0] != 2'b00)) || (`lh && ADDR[0]) || (`lhu && ADDR[0]); 		//��ַĩ��λ��ָ�ƥ��
	 assign L_Exc_2 = (`lw | `lh | `lhu | `lb | `lbu) && ~HitDM && ~HitDev;		//������DM��Dev��Χ
	 assign L_Exc_3 = (`lh | `lhu | `lb | `lbu) && HitDev;							//ʹ�� lh �� lhu �� lb �� lbu ���ض�ʱ���е�ֵ
	 
	 assign S_DataAddrExc = S_Exc_1 | S_Exc_2 | S_Exc_3 | S_Exc_4;
	 assign L_DataAddrExc = L_Exc_1 | L_Exc_2 | L_Exc_3;
	 //����һ��sbtimer��û����
	 
endmodule
