`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:10:54 12/07/2017 
// Design Name: 
// Module Name:    stall_controller 
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
module stall_controller(//Stall, PC_En, D_En, E_reset);
	input Stall,
	output PC_En,
	output D_En,
	output E_reset
	);
	
	assign PC_En = (Stall == 1)? 1'b0: 1'b1;
	assign D_En = (Stall == 1)? 1'b0: 1'b1;
	assign E_reset = (Stall == 1)? 1'b1: 1'b0;
	
endmodule
