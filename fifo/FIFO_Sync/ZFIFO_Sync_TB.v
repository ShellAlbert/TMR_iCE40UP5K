`timescale 1ns/1ps

/* filename: zuart_controller_tb.v
 * date: April 8, 2025
 * author: Shell Albert
 * function description
 * Testbench for UART Controller 
 */

module ZFIFO_Sync_TB();


//dump files for Verdi.
initial begin
        $fsdbDumpfile("ZFIFO_Sync_TB.fsdb");
        $fsdbDumpvars(0);
end


//clock and reset.
reg clk_i;
reg rst_n_i;

initial begin
	clk_i=0;
	rst_n_i=0;
	#100;
	rst_n_i=1;
	forever #10 clk_i=~clk_i;
end

//Instance.
reg wr_en_i;
reg [7:0] wr_data_i;
wire full_i;
reg rd_en_i;
wire [7:0] rd_data_i;
wire empty_i;
wire [4:0] fifo_cnt_i;
ZFIFO_Sync 
#(.DATA_WIDTH(8), .FIFO_DEPTH(16)) u1_ZFIFO_Sync
(
	.iClk(clk_i),
	.iRstN(rst_n_i),

	//Write Interface.
	.iWrEn(wr_en_i),
	.iWrData(wr_data_i),
	.oFull(full_i),

	//Read Interface.
	.iRdEn(rd_en_i),
	.oRdData(rd_data_i),
	.oEmpty(empty_i),
	
	.fifo_cnt(fifo_cnt_i)
);

//driven by step_i.
reg [7:0] step_i;
reg [7:0] CNT1;
always @(posedge clk_i or negedge rst_n_i)
if(!rst_n_i) begin
	step_i<=0;
	wr_en_i<=0;
	rd_en_i<=0;
	CNT1<=0;
end
else begin 
	case(step_i)
		0:
			if(CNT1==20) begin CNT1<=0; wr_en_i<=0; step_i<=step_i+1; end
			else begin 
					CNT1<=CNT1+1; wr_en_i<=1; wr_data_i<=CNT1; 
					$display("write fifo: %d",CNT1);
			end
		1:
			begin rd_en_i<=1; step_i<=step_i+1; end
		2:
			begin rd_en_i<=0; $display("read fifo: %x",rd_data_i); step_i<=step_i+1; end
		3:
			if(CNT1==20) begin CNT1<=0; step_i<=step_i+1; end
			else begin CNT1<=CNT1+1; step_i<=step_i-2; end
		4:
			begin $finish; end
			
	endcase
end
endmodule
