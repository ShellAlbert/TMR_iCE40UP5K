module zuart_tx #(parameter Baudrate=115200)
(
	input iClk,
	input iRstN,
	input iEn,

	input [7:0] iTxData,
	output reg oTxDone,
	output reg oTxPin
);

//////////generate bps clock////////
//generate baudrate.(bps: bits per second)
localparam BAUDRATE_DIV=(48_000_000/Baudrate-1);
//send data at middle point.
localparam BAUDRATE_DIV2=BAUDRATE_DIV/2; 

reg [15:0] CNT_Baudrate;
wire clk_bps_i;
always @(posedge iClk or negedge iRstN)
if(!iRst_N) begin
	CNT_Baudrate<=0;	
end
else begin
	if(iEn) begin
		if(CNT_Baudrate==BAUDRATE_DIV) begin CNT_Baudrate<=0; end
		else begin CNT_Baudrate<=CNT_Baudrate+1; end
	end
	else begin
		CNT_Baudrate<=0;
	end 
end
assign clk_bps_i=(CNT_Baudrate==BAUDRATE_DIV2)?1:0;



////////////shift data out at rising edge of bps clock//////////
//driven by step_i.
reg [7:0] step_i;
reg [7:0] tx_data_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	step_i<=0;
	oTxDone<=0;
	oTxPin<=1; //Idle is High.
end
else begin
	if(iEn) begin
		case(step_i)
			0: //start bit(1), latch data in.
				if(clk_bps_i) begin oTxPin<=0; tx_data_i<=iTxData; step_i<=step_i+1; end
			1,2,3,4,5,6,7,8: //data bits(8).
				if(clk_bps_i) begin 
								oTxPin<=tx_data_i[8-step_i]; step_i<=step_i+1; 
								$display("MSB first, bit[%d]=%b",(8-step_i),tx_data_i[8-step_i]);		
				end
			9: //stop bit(1).
				if(clk_bps_i) begin oTxPin<=1; step_i<=step_i+1; end
			10: //single pulse done sginal.
				if(clk_bps_i) begin oTxDone<=1; step_i<=step_i+1; end
			11: //single pulse done signal.
				begin oTxDont<=0; step_i<=0; end
		endcase
	end
	else begin
		step_i<=0;
		oTxDone<=0;
		oTxPin=0;
	end
end
endmodule
