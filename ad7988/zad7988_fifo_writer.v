/* filename: zad7988_fifo_writer.v
 * date: April 8, 2025
 * author: Shell Albert
 * function description: 
 * a wrapper module used to write ad7988 data info fifo.
 */
module zad7988_fifo_writer(
	//common signals.
	input iClk,
	input iRstN,
	input iEn,

	//Raw data from AD7988.
	input iDataValid,
	input [15:0] iData,

	//Write FIFO logic.	
	//make sure FIFO is not full before writing. 
	output reg oWrEn,
	output reg [15:0] oData,
	input iFull,
	
	//record how much data were lost.
	output reg [7:0] oDataLost
);

always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	oWrEn<=0;
	oData<=0;
	oDataLost<=0;
end
else begin
	if(iEn) begin
		if(iDataValid) begin
			if(!iFull) begin oWrEn<=1; oData<=iData; end
			else begin 
					if(oDataLost<8'hFF) begin oDataLost<=oDataLost+1; end
			end
		end
		else begin
			oWrEn<=0; oData<=0;
		end
	end
	else begin
		oWrEn<=0;
		oData<=0;
	end
end

endmodule
