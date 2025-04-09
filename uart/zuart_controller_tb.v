/* filename: zuart_controller_tb.v
 * date: April 8, 2025
 * author: Shell Albert
 * function description
 * Testbench for UART Controller 
 */

module zuart_controller_tb();


//dump files for Verdi.
initial begin
	$fsdbDumpfile("zuart_controller_tb.fsdb");
	$fsdbDumpvars(0);
end


//clock and reset signals.
reg clk_i;
reg rst_n_i;

initial begin 
	clk_i=0;
	rst_n_i=0;
	#100;
	rst_n_i=1;

end

always #10 clk_i=~clk_i;



//for instance.
reg en_i;
reg tx_en_i;
reg [7:0] tx_data_i;
wire tx_done_i;
wire tx_pin_i;

reg rx_en_i;
wire [7:0] rx_data_i;
wire rx_datavalid_i;
reg rx_pin_i;
zuart_controller u1(
	//Common Signals.
	.iClk(clk_i),
	.iRstN(rst_n_i),
	.iEn(en_i),

	//Transmit Ports.
	.iTxEn(tx_en_i),
	.iTxData(tx_data_i),
	.oTxDone(tx_done_i),
	.oTxPin(tx_pin_i), //Physical Pin.

	//Receive Ports.
	.iRxEn(rx_en_i),
	.oRxData(rx_data_i),
	.oRxDataValid(rx_datavalid_i),
	.iRxPin(rx_pin_i) //Physical Pin.
);


//transmit logic.
//driven by step_i;
reg [7:0] step_i;
always @(posedge clk_i or negedge rst_n_i)
if(!rst_n_i) begin
	step_i<=0;
	tx_data_i<=0;
	en_i<=0;
	tx_en_i<=0;
end
else begin 
	case(step_i)
		0:
			if(tx_done_i) begin en_i<=0; tx_en_i<=0; step_i<=step_i+1; end
			else begin en_i<=1; tx_en_i<=1; tx_data_i<=8'h55; end	
		1:
			begin step_i<=step_i+1; end
		2:
			begin step_i<=step_i+1; end
		3:
			begin step_i<=0; $finish; end
	endcase
end

endmodule
