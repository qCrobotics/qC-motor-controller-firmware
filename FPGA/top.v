/* BLDC motor driver           */
/* Author: Renze Nicolai       */
/* Date: 25-11-2018            */

`timescale 1 ps / 1 ps
`default_nettype none

`include "tacho.v"
`include "spi.v"
`include "bldc.v"

module top (
	input  wire clk,           //Input from the system clock
	input  wire [2:0] hal,     //Input from HAL sensors
	output wire [1:0] coilA,   //Output to the MOSFETs of coil A
	output wire [1:0] coilB,   //Output to the MOSFETs of coil B
	output wire [1:0] coilC,   //Output to the MOSFETs of coil C
	output reg  [3:0] led,     //Output to the four LEDs
	input  wire spi_sclk,      //SPI clock input
	input  wire spi_ssel,      //SPI slave select input
	input  wire spi_mosi,      //SPI master-out-slave-in input
	output wire spi_miso       //SPI master-in-slave-out output
	);
	
	reg         reset                = 0;
	reg         motorEnableHigh      = 0;
	reg         motorEnableLow       = 0;
	reg         tachoRead            = 0;
	reg  [31:0] status               = 0;
	
	wire [31:0] tachoCnt;
	wire        spiDataReceived;
	wire [31:0] spiIncomingData;
	
	reg  [31:0] status               = 0;
	wire [31:0] spiOutgoingData      = tachoRead ? tachoCnt : status;
	
	bldc U_bldc (
		.clk             (clk),
		.reset           (reset),
		.enableHigh      (motorEnableHigh),
		.enableLow       (motorEnableLow),
		.hal             (hal),
		.coilA           (coilA),
		.coilB           (coilB),
		.coilC           (coilC)
	);
	
	tacho U_tacho (
		.clk             (clk),
		.reset           (reset),
		.hal             (hal),
		.cnt             (tachoCnt),
		.read            (tachoRead)
	);
	
	spi U_spi (
		.clk             (clk),
		.spi_sclk        (spi_sclk),
		.spi_ssel        (spi_ssel),
		.spi_mosi        (spi_mosi),
		.spi_miso        (spi_miso),
		.data_received   (spiDataReceived),
		.incoming_data   (spiIncomingData),
		.outgoing_data   (spiOutgoingData)
	);
		    
	always @(posedge clk) begin
		if (spiDataReceived) begin
			reset           <= ~spiIncomingData[0];
			if (spiIncomingData[1]) begin
			  led             <=  spiIncomingData[5:2];
			end
			if (spiIncomingData[6]) begin
				motorEnableHigh <=  spiIncomingData[7];
				motorEnableLow  <=  spiIncomingData[8];
			end
			tachoRead       <=  spiIncomingData[9];
		end
		
		status[0]   <= reset;
		status[4:1] <= led;
		status[5]   <= tachoRead;
		status[6]   <= motorEnableHigh;
		status[7]   <= motorEnableLow;
	end
			
endmodule

`resetall
