module ZFIFO_Sync(
	input iClk,
	input iRstN,

	//Write Interface.
	input iWrEn,
	input [7:0] iWrData,
	output oFull,

	//Read Interface.
	input iRdEn,
	output [7:0] oRdData,
	output oEmpty
);


endmodule
