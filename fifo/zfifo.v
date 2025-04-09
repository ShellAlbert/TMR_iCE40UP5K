`timescale 1ns/1ps
module zfifo #(
	parameter depth=64,
	log2_depth=6, //2^6=64.
	width=8)
(
	//common signals.
	input iClk,
	input iRstN,

	//Write Port.
	//Check full flag before writing.
	input iWrEn, 
	input [(width-1):0] iData,
	output reg oFull,

	//Read Port.
	//Check empty flag before reading. 
	input iRdEn,
	output [(width-1):0] oData,
	output reg oEmpty
);

//if read enable signal is valid and fifo is not empty,
//then can read.
//if write enable signal is valid and fifo is not full,
//then can write.
wire can_rd, can_wr;

assign can_rd=(iRdEn)&&(!oEmpty);
assign can_wr=(iWrEn)&&(!oFull);

reg [(log2_depth-1):0] rd_addr;
reg [(log2_depth-1):0] wr_addr;
reg [(log2_depth):0] words_in_ram;
reg [(log2_depth):0] next_words_in_ram;

//for instance.
zfifo_dualport#(.depth(depth),.log2_depth(log2_depth),.width(width)) dp_ins
(
	.iClk(iClk),
    .iRstN(iRstN),

    //Write Port.
    .iWrEn(can_wr),
    .iWrAddr(wr_addr),
    .iWrData(iData),

    //Read Port.
    .iRdEn(can_rd),
    .iRdAddr(rd_addr),
    .oRdData(oData)
);


always @(*)
begin
	if(can_wr && (!can_rd)) begin
		next_words_in_ram<=words_in_ram+1;
	end	
	else if(!can_wr && can_rd) begin
		next_words_in_ram<=words_in_ram-1;
	end
	else begin
		next_words_in_ram<=words_in_ram;
	end
end

always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	oFull<=1;
	oEmpty<=1;
	words_in_ram<=0;
	rd_addr<=0;
	wr_addr<=0;
end
else begin
	words_in_ram<=next_words_in_ram;
	oFull<=(next_words_in_ram==depth);
	oEmpty<=(next_words_in_ram==0);

	if(can_rd) begin
		//rd_addr will overflow, so it's a loop fifo.
		rd_addr<=rd_addr+1;	
	end

	if(can_wr) begin
		//wr_addr will overflow, so it's a loop fifo.
		wr_addr<=wr_addr+1;
	end
end
endmodule
