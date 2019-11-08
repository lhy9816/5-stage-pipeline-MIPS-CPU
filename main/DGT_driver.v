`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:18:38 01/09/2018 
// Design Name: 
// Module Name:    DGT_driver 
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
`define A_s 0
`define B_s 1
`define C_s 2
`define D_s 3
`define PRESET 18'd100000//到时候再调

module DGT_driver(
   input clk,
	input reset,
	
	input [31:0] datain, addr,
	input We,
	output [31:0] dataout,
	output [7:0] DGT_tube0, DGT_tube1, DGT_tube2,
	output [3:0] tube_sel0, tube_sel1,
	output tube_sel2
	);

	reg [31:0] sign, data;
	reg [1:0] state;
	reg [17:0] count;
	
	wire [7:0] D0, D1, D2, D3, D4, D5, D6, D7;
	wire [7:0] D0_p, D1_p, D2_p, D3_p, D4_p, D5_p, D6_p, D7_p;
	wire [7:0] D0_n, D1_n, D2_n, D3_n, D4_n, D5_n, D6_n, D7_n;
	wire [31:0] n_data;
	
	always@(posedge clk)
		begin
			if(reset)
				begin
					sign <= 0;
					data <= 0;
					count <= `PRESET;
				end
			else if(We)
				begin
					if(addr == 32'h00007f38)
						sign <= datain;
					if(addr == 32'h00007f3c)
						data <= datain;
				end
			
			case(state)
				`A_s:begin
							if(count == 0)
								begin
									state <= `B_s;
									count <= `PRESET;
								end
							else
								count <= count - 1;
						end
				`B_s:begin
							if(count == 0)
								begin
									state <= `C_s;
									count <= `PRESET;
								end
							else
								count <= count - 1;
						end
				`C_s:begin
							if(count == 0)
								begin
									state <= `D_s;
									count <= `PRESET;
								end
							else
								count <= count - 1;
						end
				`D_s:begin
							if(count == 0)
								begin
									state <= `A_s;
									count <= `PRESET;
								end
							else
								count <= count - 1;
						end
				
				default:begin state <= `A_s; 
								  count <= `PRESET; 
								end
				endcase
		end
		
		assign n_data = 1 + (~data);
		
		DGT_translate Di0(data[3:0], D0_p);
		DGT_translate Di1(data[7:4], D1_p);
		DGT_translate Di2(data[11:8], D2_p);
		DGT_translate Di3(data[15:12], D3_p);
		DGT_translate Di4(data[19:16], D4_p);
		DGT_translate Di5(data[23:20], D5_p);
		DGT_translate Di6(data[27:24], D6_p);
		DGT_translate Di7(data[31:28], D7_p);
		
		DGT_translate Di0_n(n_data[3:0], D0_n);
		DGT_translate Di1_n(n_data[7:4], D1_n);
		DGT_translate Di2_n(n_data[11:8], D2_n);
		DGT_translate Di3_n(n_data[15:12], D3_n);
		DGT_translate Di4_n(n_data[19:16], D4_n);
		DGT_translate Di5_n(n_data[23:20], D5_n);
		DGT_translate Di6_n(n_data[27:24], D6_n);
		DGT_translate Di7_n(n_data[31:28], D7_n);
		
		assign dataout = (addr == 32'h00007f38)? sign:
							  (addr == 32'h00007f3c)? data:
																32'b0;
		
		assign {D7, D6, D5, D4, D3, D2, D1, D0} = (data[31] == 1'b0)? {D7_p, D6_p, D5_p, D4_p, D3_p, D2_p, D1_p, D0_p}:
																						  {D7_n, D6_n, D5_n, D4_n, D3_n, D2_n, D1_n, D0_n};
		
		//assign neg_sig = //悬而未决；
		
		assign tube_sel0 = (state == `A_s)? 4'b0001:
								 (state == `B_s)? 4'b0010:
								 (state == `C_s)? 4'b0100:
															4'b1000;
															
		assign tube_sel1 = tube_sel0;
		assign tube_sel2 = 1'b1;//sign
		
		assign DGT_tube0 = (state == `A_s)? D0:
								 (state == `B_s)? D1:
								 (state == `C_s)? D2:
								 (state == `D_s)? D3:
										8'b1000_0001;
										
		assign DGT_tube1 = (state == `A_s)? D4:
								 (state == `B_s)? D5:
								 (state == `C_s)? D6:
								 (state == `D_s)? D7:
										8'b1000_0001;
		assign DGT_tube2 = reset? 8'b1000_0001:
								 data[31]? 8'b1111_1110:
											  8'b1111_1111;
endmodule

module DGT_translate(
	input [3:0] number,
	output [7:0] DGT_show
);

	assign DGT_show = (number == 4'hf)? 8'b1011_1000:
							(number == 4'h1)? 8'b1100_1111:
							(number == 4'h2)? 8'b1001_0010:
							(number == 4'h3)? 8'b1000_0110:
							(number == 4'h4)? 8'b1100_1100:
							(number == 4'h5)? 8'b1010_0100:
							(number == 4'h6)? 8'b1010_0000:
							(number == 4'h7)? 8'b1000_1111:
							(number == 4'h8)? 8'b1000_0000:
							(number == 4'h9)? 8'b1000_0100:
							(number == 4'ha)? 8'b1000_1000:
							(number == 4'hb)? 8'b1110_0000:
							(number == 4'hc)? 8'b1011_0001:
							(number == 4'hd)? 8'b1100_0010:
							(number == 4'he)? 8'b1011_0000:
														8'b1000_0001;
							
							
							
endmodule
