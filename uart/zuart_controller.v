/* filename: zuart_controller.v
 * date: April 8, 2025
 * author: Shell Albert
 * function description
 * UART Controller 
 */

module zuart_controller(
	//Common Signals.
	input iClk,
	input iRstN,
	input iEn,

	//Transmit Ports.
	input iTxEn,
	input [7:0] iTxData,
	output reg oTxDone,
	output reg oTxPin, //Physical Pin.

	//Receive Ports.
	input iRxEn,
	output [7:0] oRxData,
	output oRxDataValid,
	input iRxPin //Physical Pin.
	
);

//Baudaterate generate.
//24MHz/4MHz=6.
parameter CNT_BPS_MAX=6;
reg [7:0] CNT_bps;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	CNT_bps<=0;
end
else begin
	if(iEn) begin
		if(CNT_bps==CNT_BPS_MAX) begin CNT_bps<=0; end
		else begin CNT_bps<=CNT_bps+1; end
	end
	else begin
		CNT_bps<=0;
	end
end

//Transmit Logic.
//driven by step_i.
reg [7:0] tx_step_i;
reg [7:0] tx_buffer;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	tx_step_i<=0;	
	tx_buffer<=0;
	oTxDone<=0;
	oTxPin<=1; //Idle is High.
end
else begin
	if(iEn) begin
		if(iTxEn) begin
			case(tx_step_i)
				0: //start bit(1).
					if(CNT_bps==CNT_BPS_MAX) begin
						oTxPin<=0; tx_buffer<=iTxData; tx_step_i<=tx_step_i+1;
					end
				1,2,3,4,5,6,7,8: //data bits(8).
					if(CNT_bps==CNT_BPS_MAX) begin
						//LSB first.
						//oTxPin<=tx_buffer[tx_step_i-1]; tx_step_i<=tx_step_i+1; 
						//MSB first.
						oTxPin<=tx_buffer[8-tx_step_i]; tx_step_i<=tx_step_i+1; 
						$display("MSB first, bit[%d]=%b",8-tx_step_i,tx_buffer[8-tx_step_i]);
					end
				9: //stop bit(1).
					if(CNT_bps==CNT_BPS_MAX) begin
						oTxPin<=1; tx_step_i<=tx_step_i+1;
					end
				10: //single pulse done signal.
					if(CNT_bps==CNT_BPS_MAX) begin
						oTxDone<=1; tx_step_i<=tx_step_i+1; 
					end 
				11: //single pulse done signal.
					begin oTxDone<=0; tx_step_i<=0; end 
			endcase
		end
		else begin
			tx_step_i<=0;
			oTxPin<=1;
			oTxDone<=0;
		end
	end
	else begin
		tx_step_i<=0;
		oTxPin<=1;
		oTxDone<=0;
	end
end
endmodule

