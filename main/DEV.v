`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:35:12 01/09/2018 
// Design Name: 
// Module Name:    DEV 
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

module Switch64_driver(
	input [31:0] addr,
	input [7:0] s0, s1, s2, s3, s4, s5, s6, s7,
	output [31:0] dataout
	);
	
	assign dataout = (addr == 32'h00007f2c)? {s3,s2,s1,s0}:
						  (addr == 32'h00007f30)? {s7,s6,s5,s4}:
																			0;

endmodule

module LED_driver(
	input clk,
	input reset,
	
	input [31:0] datain,

	input We,
	output [31:0] dataout, LED_light
    );
	
	reg [31:0] LED;
	
	always@(posedge clk)
		begin
			if(reset)
				LED <= 0;
			else if(We)
				LED <= datain;
		end
		
	assign dataout = LED;
	assign LED_light = ~LED;

endmodule
//轮询？？若是中断的话放在哪位？
module Userinput_driver(
	input [7:0] user_key,
	output [31:0] dataout
    );

	assign dataout = {24'b0, user_key};
endmodule
