`timescale 1ns/1ps
//without read and write conflict control.
module zfifo_dualport #(
	parameter depth=64, 
	log2_depth=6, //2^6=64.
	width=8)
(
	input iClk,
	input iRstN,

	//Write Port.
	input iWrEn,
	input [(log2_depth-1):0] iWrAddr,
	input [(width-1):0] iWrData,

	//Read Port.	
	input iRdEn,
	input [(log2_depth-1):0] iRdAddr,
	output reg [(width-1):0] oRdData
);

reg [(width-1):0] internal_ram[0:(depth-1)];

always @(posedge iClk)
begin
	if(iWrEn) begin internal_ram[iWrAddr]<=iWrData; end
	if(iRdEn) begin oRdData<=internal_ram[iRdAddr]; end
end
endmodule

