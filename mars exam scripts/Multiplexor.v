`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
module Mux2to1(in0, in1, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 1'b1) ? in1: in0;
	
endmodule

module Mux3to1(in0, in1, in2, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [1:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 2'b10) ? in2:
					 (sel == 2'b01) ? in1:
											in0;

endmodule

module Mux4to1(in0, in1, in2, in3, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [WIDTH_DATA:1] in3;
	input [1:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 2'b11) ? in3:
					 (sel == 2'b10) ? in2:
					 (sel == 2'b01) ? in1:
											in0;

endmodule

module Mux6to1(in0, in1, in2, in3, in4, in5, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [WIDTH_DATA:1] in3;
	input [WIDTH_DATA:1] in4;
	input [WIDTH_DATA:1] in5;
	input [2:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 3'b101) ? in5:
					 (sel == 3'b100) ? in4:
					 (sel == 3'b011) ? in3:
					 (sel == 3'b010) ? in2:
					 (sel == 3'b001) ? in1:
											 in0;

endmodule

module Mux9to1(in0, in1, in2, in3, in4, in5, in6, in7, in8, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [WIDTH_DATA:1] in3;
	input [WIDTH_DATA:1] in4;
	input [WIDTH_DATA:1] in5;
	input [WIDTH_DATA:1] in6;
	input [WIDTH_DATA:1] in7;
	input [WIDTH_DATA:1] in8;
	input [3:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 4'b1000) ? in8:
					 (sel == 4'b0111) ? in7:
					 (sel == 4'b0110) ? in6:
					 (sel == 4'b0101) ? in5:
					 (sel == 4'b0100) ? in4:
					 (sel == 4'b0011) ? in3:
					 (sel == 4'b0010) ? in2:
					 (sel == 4'b0001) ? in1:
											  in0;

endmodule

module Mux10to1(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [WIDTH_DATA:1] in3;
	input [WIDTH_DATA:1] in4;
	input [WIDTH_DATA:1] in5;
	input [WIDTH_DATA:1] in6;
	input [WIDTH_DATA:1] in7;
	input [WIDTH_DATA:1] in8;
	input [WIDTH_DATA:1] in9;
	input [3:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 4'b1001) ? in9:
					 (sel == 4'b1000) ? in8:
					 (sel == 4'b0111) ? in7:
					 (sel == 4'b0110) ? in6:
					 (sel == 4'b0101) ? in5:
					 (sel == 4'b0100) ? in4:
					 (sel == 4'b0011) ? in3:
					 (sel == 4'b0010) ? in2:
					 (sel == 4'b0001) ? in1:
											  in0;

endmodule

module Mux11to1(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [WIDTH_DATA:1] in3;
	input [WIDTH_DATA:1] in4;
	input [WIDTH_DATA:1] in5;
	input [WIDTH_DATA:1] in6;
	input [WIDTH_DATA:1] in7;
	input [WIDTH_DATA:1] in8;
	input [WIDTH_DATA:1] in9;
	input [WIDTH_DATA:1] in10;
	input [3:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 4'b1010) ? in10:
					 (sel == 4'b1001) ? in9:
					 (sel == 4'b1000) ? in8:
					 (sel == 4'b0111) ? in7:
					 (sel == 4'b0110) ? in6:
					 (sel == 4'b0101) ? in5:
					 (sel == 4'b0100) ? in4:
					 (sel == 4'b0011) ? in3:
					 (sel == 4'b0010) ? in2:
					 (sel == 4'b0001) ? in1:
											  in0;

endmodule

module Mux12to1(in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, sel, out);
	parameter WIDTH_DATA = 32;
	input [WIDTH_DATA:1] in0;
	input [WIDTH_DATA:1] in1;
	input [WIDTH_DATA:1] in2;
	input [WIDTH_DATA:1] in3;
	input [WIDTH_DATA:1] in4;
	input [WIDTH_DATA:1] in5;
	input [WIDTH_DATA:1] in6;
	input [WIDTH_DATA:1] in7;
	input [WIDTH_DATA:1] in8;
	input [WIDTH_DATA:1] in9;
	input [WIDTH_DATA:1] in10;
	input [WIDTH_DATA:1] in11;
	input [3:0] sel;
	output [WIDTH_DATA:1] out;

	assign out = (sel == 4'b1011) ? in11:
					 (sel == 4'b1010) ? in10:
					 (sel == 4'b1001) ? in9:
					 (sel == 4'b1000) ? in8:
					 (sel == 4'b0111) ? in7:
					 (sel == 4'b0110) ? in6:
					 (sel == 4'b0101) ? in5:
					 (sel == 4'b0100) ? in4:
					 (sel == 4'b0011) ? in3:
					 (sel == 4'b0010) ? in2:
					 (sel == 4'b0001) ? in1:
											  in0;

endmodule

