/* BLDC tachometer             */
/* Author: Renze Nicolai       */
/* Date: 03-12-2018            */

`timescale 1 ps / 1 ps
`default_nettype none

module tacho (
		input wire         clk,
		input  wire [2:0]  hal,
		input  wire        reset,
		output signed reg  [31:0] cnt,
		input  wire        read
	);
	
	function isForward;
	input [5:0] hal;
	begin
		case (hal)
			6'b011001:  isForward = 1;
			6'b001101:  isForward = 1;
			6'b101100:  isForward = 1;
			6'b100110:  isForward = 1;
			6'b110010:  isForward = 1;
			6'b010011:  isForward = 1;
			default:    isForward = 0;
		endcase
	end
	endfunction
	
	function isBackward;
	input [5:0] hal;
	begin
		case (hal)
			6'b101001:  isBackward = 1;
			6'b100101:  isBackward = 1;
			6'b110100:  isBackward = 1;
			6'b010110:  isBackward = 1;
			6'b011010:  isBackward = 1;
			6'b001011:  isBackward = 1;
			default:    isBackward = 0;
		endcase
	end
	endfunction
	
	reg [2:0]  halReg     = 0;
	reg [2:0]  prevHalReg = 0;	
	reg [31:0] intCnt     = 0;
	reg        prevRead   = 0;
	
	reg [2:0] read_reg;
	always @(posedge clk) read_reg <= {read_reg[1:0], read};
	wire read_risingedge   = (read_reg[2:1]==2'b01);
	wire read_fallingedge  = (read_reg[2:1]==2'b10);
	
	always @ (posedge clk) begin
		if (reset) begin
			cnt        <= 0;
			intCnt     <= 0;
			prevHalReg <= hal;
			halReg     <= hal;
			prevRead   <= 0;
		end else begin
			halReg <= hal;
			if (prevHalReg != halReg) begin
				if (isForward(halReg + (prevHalReg << 3))) begin
					intCnt <= intCnt+1;
				end else if (isBackward(halReg + (prevHalReg << 3))) begin
					intCnt <= intCnt-1;
				end
				prevHalReg <= halReg;
			end else if (read_risingedge) begin
				cnt    <= intCnt;
				intCnt <= 0;
			end
		end
	end
endmodule

`resetall
