module zuart_tx_with_fifo #(parameter Baudrate=9600)
(
	input iClk,
	input iRstN,
	input iEn,

	//FIFO write I/F.
	input iWrEn,
	input [7:0] iWrData;
	output oFull,

	//Physical Pin.
	output oTxPin
);

//Instance ZFIFO.
//Add a Tx FIFO to UART Tx Module.
reg rd_en_i;
wire [7:0] rd_data_i;
wire empty_i;
zfifo u0(
	.iClk(iClk),
	.iRstN(iRstN),
	
	//Write Interface.
	.iWrEn(iWrEn),
	.iWrData(iWrData),
	.oFull(oFull),

	//Read Interface.	
	.iRdEn(rd_en_i),
	.iRdData(rd_data_i),
	.oEmpty(empty_i)
);

//Instance UART Module.
reg tx_en_i;
wire tx_done_i;
zuart_tx #(.Baudrate(115200)) u1
(
    .iClk(iClk),
    .iRstN(iRstN),
    .iEn(tx_en_i),

    .iTxData(rd_data_i),
    .oTxDone(tx_done_i),
    .oTxPin(oTxPin)
);

//Glue logic
//read data from fifo and write to tx module.
reg [7:0] step_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	step_i<=0;
end
else begin
	if(iEn) begin
		case(step_i)
			0: //read request starts.
				if(!empty_i) begin rd_en_i<=1; step_i<=step_i+1; end
			1: //read request stops
				begin rd_en_i<=0; step_i<=step_i+1; end
			2: //tx out.
				if(tx_done_i) begin tx_en_i<=0; step_i<=step_i+1; end
				else begin tx_en_i<=1; end	
			3:
				begin step_i<=0; end
		endcase
	end
	else begin
	end	
end


endmodule
