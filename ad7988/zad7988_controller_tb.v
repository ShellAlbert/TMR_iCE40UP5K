/*
* filename: zad7988_controller_tb.v
* function: testbench for ad7988-1 works in 3 wires mode, acquire data and output.
* date: April 4,2024.
* author: Shell Albert 
* 
*/
module zad7988_controller_tb();


initial begin
	$fsdbDumpfile("zad7988_controller_tb.fsdb");
	$fsdbDumpvars(0);
end

reg clk;
reg rst_n;
reg en;

wire sdi;
wire cnv;
wire sck;
reg sdo;
wire [15:0] data_buffer;
wire data_valid;

zad7988_controller u1(
    .iClk(clk), //input clock,24MHz.
    .iRstN(rst_n),
    .iEn(en),

    .oSDI(sdi),
    .oCNV(cnv),
    .oSCK(sck),
    .iSDO(sdo),

    .oData(data_buffer),
    .oDataValid(data_valid)
);

//do initialization.
initial begin
	clk=0;
	rst_n=0;

	#50;
	rst_n=1;

	repeat (50) begin
		#20 sdo=$random%2;
	end
	
end

//generate clock.
always #10 clk=~clk;


//end until data_valid=1
reg [7:0] step_i;
reg [7:0] CNT1;
always @(posedge clk or negedge rst_n)
if(!rst_n) begin
	step_i<=0;
	CNT1<=0;
	en<=0;
end
else begin
	case(step_i)
	0:
		if(CNT1==10) begin CNT1<=0; step_i<=step_i+1; end 
		else begin CNT1<=CNT1+1; end
	1:
		begin en<=1; step_i<=step_i+1; end	
	2:
		if(data_valid==1) begin step_i<=step_i+1; end
	3:
		begin en<=0; step_i<=0; $finish; end
	endcase
end

endmodule

