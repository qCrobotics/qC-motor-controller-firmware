/* SPI slave peripheral        */
/* Author: Renze Nicolai       */
/* Date: 03-12-2018            */

`timescale 1 ps / 1 ps
`default_nettype none

module spi (
	input  wire        clk,
	
	input  wire        spi_sclk,
	input  wire        spi_ssel,
	input  wire        spi_mosi,
	output reg         spi_miso,
	
	output reg         data_received,
	output reg  [31:0] incoming_data,
	input  wire [31:0] outgoing_data
	);
		
	reg [2:0] sclk_reg;
	always @(posedge clk) sclk_reg <= {sclk_reg[1:0], spi_sclk};
	wire sclk_risingedge   = (sclk_reg[2:1]==2'b01);
	wire sclk_fallingedge  = (sclk_reg[2:1]==2'b10);
	
	reg [2:0] ssel_reg;
	always @(posedge clk) ssel_reg <= {ssel_reg[1:0], spi_ssel};
	wire ssel_active       = ~ssel_reg[1];
	wire ssel_startmessage = (ssel_reg[2:1]==2'b10);
	wire ssel_endmessage   = (ssel_reg[2:1]==2'b01);
	
	reg [1:0] mosi_reg;
	always @(posedge clk) mosi_reg <= {mosi_reg[0], spi_mosi};
	wire mosi              = mosi_reg[1];
	
	reg [4:0]  counter;
	reg [31:0] tx_buffer;
	
	assign spi_miso = tx_buffer[31];
	
	always @(posedge clk)
	begin		
		if (~ssel_active) begin
			counter <= 0;
		end if (sclk_risingedge) begin
			counter <= counter + 1;
			incoming_data    <= {incoming_data[30:0], mosi};
		end
		
		data_received  <= ssel_active && sclk_risingedge && (counter == 5'b11111);
		
		if (ssel_startmessage) begin
			tx_buffer <= outgoing_data;
		end else if (sclk_fallingedge) begin
			if (counter == 5'b00000) begin
				tx_buffer <= 32'h0;
			end else begin
				tx_buffer <= {tx_buffer[30:0], 1'b0};
			end
		end
	end
endmodule

`resetall
