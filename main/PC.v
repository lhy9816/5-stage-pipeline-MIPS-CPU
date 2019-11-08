`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:07:44 11/26/2017 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input clk,
    input reset,
	 input PC_En,
    input [31:0] N_PC,
    output reg [31:0] Current_PC
    );
	/*initial
		begin
			PC <= 32'h0x00003000;
		end*/
	always@(posedge clk)
		begin
			if(reset)
				Current_PC <= 32'h00003000;
			else
				if (PC_En)
					begin
						Current_PC <= N_PC[31:0];
					end
		end

endmodule
