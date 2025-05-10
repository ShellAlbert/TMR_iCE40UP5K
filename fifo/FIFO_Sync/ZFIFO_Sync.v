`timescale 1ns/1ps
module ZFIFO_Sync 
#(
	parameter DATA_WIDTH=8,
	parameter FIFO_DEPTH=16
)
(
	input iClk,
	input iRstN,

	//Write Interface.
	input iWrEn,
	input [DATA_WIDTH-1:0] iWrData,
	output oFull,

	//Read Interface.
	input iRdEn,
	output reg [DATA_WIDTH-1:0] oRdData,
	output oEmpty,
	
	output reg [$clog2(FIFO_DEPTH):0] fifo_cnt //2^4=16.
);

//two dimension array.
reg [DATA_WIDTH-1:0] memory[FIFO_DEPTH-1:0];
reg [$clog2(FIFO_DEPTH)-1:0] wr_ptr; //2^x=y.
reg [$clog2(FIFO_DEPTH)-1:0] rd_ptr; //2^x=y.


//read logic and update read pointer.
always @(posedge iClk or negedge iRstN) 
if(!iRstN) begin
	oRdData<=0;
	rd_ptr<=0;
end
else begin
	if(iRdEn && !oEmpty) begin 
		oRdData<=memory[rd_ptr]; 
		rd_ptr<=rd_ptr+1;
	end 
end

//write logic and update write pointer.
always @(posedge iClk or negedge iRstN) 
if(!iRstN) begin
	wr_ptr<=0;
end
else begin 
	if(iWrEn && !oFull) begin 
		memory[wr_ptr]<=iWrData;	
		wr_ptr<=wr_ptr+1;
	end
end

//update counter.
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	fifo_cnt<=0;
end
else begin 
	case({iWrEn,iRdEn})
		2'b00: //no operation.
			fifo_cnt<=fifo_cnt;
		2'b01: //read only.
			if(fifo_cnt!=0) begin fifo_cnt<=fifo_cnt-1; end
		2'b10: //write only.
			if(fifo_cnt!=FIFO_DEPTH) begin fifo_cnt<=fifo_cnt+1; end
		2'b11: //read & write.
			fifo_cnt<=fifo_cnt;
	endcase
end 
assign oFull=(fifo_cnt==FIFO_DEPTH)?1:0;
assign oEmpty=(fifo_cnt==0)?1:0;
endmodule
