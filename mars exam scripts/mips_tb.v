`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:07:51 01/10/2018
// Design Name:   mips
// Module Name:   F:/ISE/P8/mips_tb.v
// Project Name:  P8
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mips_tb;

	// Inputs
	reg clk_in;
	reg sys_rstn;
	reg uart_rxd;
	reg [7:0] dip_switch0;
	reg [7:0] dip_switch1;
	reg [7:0] dip_switch2;
	reg [7:0] dip_switch3;
	reg [7:0] dip_switch4;
	reg [7:0] dip_switch5;
	reg [7:0] dip_switch6;
	reg [7:0] dip_switch7;
	reg [7:0] user_key;

	// Outputs
	wire uart_txd;
	wire [31:0] led_light;
	wire [7:0] digital_tube0;
	wire [7:0] digital_tube1;
	wire [7:0] digital_tube2;
	wire [3:0] digital_tube_sel0;
	wire [3:0] digital_tube_sel1;
	wire digital_tube_sel2;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk_in(clk_in), 
		.sys_rstn(sys_rstn), 
		.uart_rxd(uart_rxd), 
		.dip_switch0(dip_switch0), 
		.dip_switch1(dip_switch1), 
		.dip_switch2(dip_switch2), 
		.dip_switch3(dip_switch3), 
		.dip_switch4(dip_switch4), 
		.dip_switch5(dip_switch5), 
		.dip_switch6(dip_switch6), 
		.dip_switch7(dip_switch7), 
		.uart_txd(uart_txd), 
		.user_key(user_key), 
		.led_light(led_light), 
		.digital_tube0(digital_tube0), 
		.digital_tube1(digital_tube1), 
		.digital_tube2(digital_tube2), 
		.digital_tube_sel0(digital_tube_sel0), 
		.digital_tube_sel1(digital_tube_sel1), 
		.digital_tube_sel2(digital_tube_sel2)
	);

	initial begin
		// Initialize Inputs
		clk_in = 0;
		sys_rstn = 0;
		uart_rxd = 0;
		dip_switch0 = 7;
		dip_switch1 = 3;
		dip_switch2 = 1;
		dip_switch3 = 1;
		dip_switch4 = 3;
		dip_switch5 = 2;
		dip_switch6 = 6;
		dip_switch7 = 1;
		user_key = 8'b11111110;
		
		#1120
		sys_rstn = 1;
		/*dip_switch0 = 3;
		dip_switch1 = 0;
		dip_switch2 = 0;
		dip_switch3 = 0;
		dip_switch4 = 4;
		dip_switch5 = 0;
		dip_switch6 = 0;
		dip_switch7 = 0;*/
		/*#145400
		uart_rxd = 1'b1;*/
		
	end
   always #20 clk_in = ~clk_in;

	
      
endmodule

