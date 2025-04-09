`timescale 1ns/1ps
module zfifo_tb();

//dump files for Verdi.
initial begin
	$fsdbDumpfile("Zsy.fsdb");
	$fsdbDumpvars(0);
end

//generate reset.
reg rst_n_i;
initial begin
	rst_n_i=0;
	#20;
	rst_n_i=1;
end

//generate clock.
reg clk_i;
initial begin
	clk_i=0;
	forever #10 clk_i=~clk_i;
end

//for instance. 
reg wr_en_i;
reg [7:0] data_in;
wire full;

reg rd_en_i;
wire [7:0] data_out;
wire empty;
zfifo #(.depth(64),.log2_depth(6),.width(8)) u1
(
	//common signals.
	.iClk(clk_i),
	.iRstN(rst_n_i),

	//Write Port.
	//Check full flag before writing.
	.iWrEn(wr_en_i), 
	.iData(data_in),
	.oFull(full),

	//Read Port.
	//Check empty flag before reading. 
	.iRdEn(rd_en_i),
	.oData(data_out),
	.oEmpty(empty)
);

reg [7:0] step_i;
reg [7:0] CNT1;
always @(posedge clk_i or negedge rst_n_i)
if(!rst_n_i) begin
	step_i<=0;
	wr_en_i<=0;
	data_in<=0;
	rd_en_i<=0;
	CNT1<=0;
end
else begin 
	case(step_i)
		0:	//write to fifo until it's full.
			begin
				//if(CNT1==70) begin wr_en_i<=0; CNT1<=0; step_i<=step_i+1; end
				//else begin wr_en_i<=1; data_in<=CNT1; CNT1<=CNT1+1; end

				if(full) begin $display("fifo is full, CNT1=%d",CNT1); step_i<=step_i+1; end
				else begin wr_en_i<=1; data_in<=CNT1; CNT1<=CNT1+1; end
			end
		1: 
			if(CNT1==8'hFF) begin $finish; end
			else begin CNT1<=CNT1+1; end
	endcase
end
endmodule


