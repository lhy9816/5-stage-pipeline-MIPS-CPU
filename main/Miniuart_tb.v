`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:17:25 01/09/2018
// Design Name:   MiniUART
// Module Name:   F:/ISE/P8/Miniuart_tb.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MiniUART
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Miniuart_tb;

	// Inputs
	reg [4:2] ADD_I;
	reg [31:0] DAT_I;
	reg STB_I;
	reg WE_I;
	reg CLK_I;
	reg RST_I;
	reg RxD;

	// Outputs
	wire [31:0] DAT_O;
	wire ACK_O;
	wire TxD;

	// Instantiate the Unit Under Test (UUT)
	MiniUART uut (
		.ADD_I(ADD_I), 
		.DAT_I(DAT_I), 
		.DAT_O(DAT_O), 
		.STB_I(STB_I), 
		.WE_I(WE_I), 
		.CLK_I(CLK_I), 
		.RST_I(RST_I), 
		.ACK_O(ACK_O), 
		.RxD(RxD), 
		.TxD(TxD)
	);

	initial begin
		// Initialize Inputs
		ADD_I = 0;
		DAT_I = 0;
		STB_I = 0;
		WE_I = 0;
		CLK_I = 0;
		RST_I = 0;
		RxD = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

