module i2c_2_spi(
	i_ck,
	i_rstn,
	i_i2c_clk,
	io_i2c_dat,
	
	o_spi_clk,
	o_spi_csn,
	o_spi_mosi,
	i_spi_miso
);
input i_ck;
input i_rstn;
input i_i2c_clk;
inout io_i2c_dat;
output o_spi_clk;
output o_spi_csn;
output o_spi_mosi;
input  i_spi_miso;

parameter SADR= 7'b0001000;

parameter dwidth = 8;
parameter awidth = 4;

wire[7:0] in, out;
wire[3:0] addr;
wire RW;
wire EN;
	
wire[7:0] in2, out2;
wire[3:0] addr2;
wire RW2;
wire EN2;	
	
wire [3:0] spi_adr;
wire [ 7:0] spi_dat_i, spi_dat_o;
wire spi_wr;
wire spi_rd;


reg o_rw; //0:spi_write, 1:spi_read
reg o_csn; //0:chip select, 1:chip deselect
reg [3:0] o_address;
reg [7:0] i_data;
reg [7:0] o_data;


reg [3:0]	adr;
reg  [dwidth   -1:0]	din;
//reg [7:0]	dout;
reg       wr,rd;

assign in2 = i_data;
//assign out2 = o_data;
assign addr2 = o_address;
assign RW2 = o_rw;
assign EN2 = o_csn;

assign spi_adr = adr;
assign spi_dat_i = din;
assign spi_wr = wr;
assign spi_rd = rd;
////////////////////////////////////////////////////////////////////
// hi2c slave module
i2c_slave #(SADR) ins_i2c_slave(
		.i_ck(i_ck),
		.i_rstn(i_rstn),
		.SDA(io_i2c_dat),
		.SCL(i_i2c_clk),
		.sram_odata(out),
		.sram_idata(in),
		.sram_addr(addr),
		.sram_rw(RW),
		.sram_cs(EN)		
	);

// hookup register file (sram) module
dram ins_dram(
		.i_rstn(i_rstn),
		.i_ck(i_ck),		
		.o_data(out),
		.i_address(addr),
		.i_rw(RW),
		.i_csn(EN),
		.i_data(in),
		
		.o_data2(out2),
		.i_address2(addr2),
		.i_rw2(RW2),
		.i_csn2(EN2),
		.i_data2(in2)		
	);
/*	
 dram_bus2 ins_dram_bus2(
		.i_rstn(i_rstn),
		.i_ck(i_ck),		
		.o_data(in2),
		.o_address(addr2),
		.o_rw(RW2),
		.o_csn(EN2),
		.i_data(out2)
	);
*/
/*
spi_master_model #(8, 4) ins_spi_access (
		.clk(i_ck),
		.rst(i_rstn),
		.adr(spi_adr),
		.din(spi_dat_i),
		.dout(spi_dat_o),
		.wr(spi_wr),
		.rd(spi_rd)
	);
*/
spi_master ins_spi_master (
		.i_ck(i_ck),
		.i_rstn(i_rstn),
		.o_sclk(o_spi_clk),
		.o_csn(o_spi_csn),
		.i_miso(i_spi_miso),
		.o_mosi(o_spi_mosi),
		.i_address(spi_adr),
		.i_data(spi_dat_i),
		.o_data(spi_dat_o),
		.i_wr(spi_wr),
		.i_rd(spi_rd)
	);	
parameter SRAM_SPI_ADDR = 4'b0000;
parameter SRAM_SPI_TXD  = 4'b0001;
parameter SRAM_SPI_RXD  = 4'b0011;
parameter SRAM_SPI_CTRL = 4'b0010;

parameter SPI_ADDR_REG = 4'b0010;
parameter SPI_TX_REG   = 4'b0001;
parameter SPI_CTRL_REG = 4'b0000;
parameter SPI_RX_REG   = 4'b0011;
reg [7:0] spi_data, spi_addr, spi_ctrl,temp;
reg spi_pending;


reg [3:0] top_state;
parameter spi_idle = 4'b0000;
parameter spi_get_addr = 4'b0001;
parameter spi_get_data =  4'b0010;
parameter spi_put_addr = 4'b0011;
parameter spi_put_data = 4'b0100;
parameter spi_put_ctrl = 4'b0101;
parameter spi_read_data = 4'b0110;

reg [2:0] clk_count;
always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		top_state <= spi_idle;
		temp <= 8'H0;
		clk_count <= 3'h0;
	end else begin
		case (top_state)
		spi_idle:
		begin
			sram_addr <= SRAM_SPI_CTRL;
			if (!clk_count) begin
				spi_read <= 1'b1;
			end else
				spi_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == 3'h3) begin
				if (sram_data[0]) begin
					top_state <= spi_get_addr;
					spi_ctrl <= sram_data;
				end
				clk_count <= 3'h0;
			end
			
		end
		
		spi_get_addr:
		begin
			sram_addr <= SRAM_SPI_ADDR;
			if (!clk_count) begin
				spi_read <= 1'b1;
			end else
				spi_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == 3'h3) begin
				//if (sram_data[0]) begin
					top_state <= spi_get_data;
					spi_addr <= sram_data;
				//end
				clk_count <= 3'h0;
			end
		end
		
		spi_get_data:
		begin
			sram_addr <= SRAM_SPI_TXD;
			if (!clk_count) begin
				spi_read <= 1'b1;
			end else
				spi_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == 3'h3) begin
				//if (sram_data[0]) begin
					top_state <= spi_put_addr;
					spi_data <= sram_data;
				//end
				clk_count <= 3'h0;
			end
		end
		
		spi_put_addr:
		begin
			sram_addr <= SRAM_SPI_TXD;
			if (!clk_count) begin
				spi_write <= 1'b1;
			end else
				spi_write <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == 3'h3) begin
				//if (sram_data[0])
				top_state <= spi_put_data;
				clk_count <= 3'h0;
			end		
		end
		endcase;
	end
end 


reg [2:0] sram_state;
parameter sram_idle = 3'b000;
parameter sram_reading =  3'b001;
parameter sram_rd_done =  3'b010;
parameter sram_writing = 3'b011;
parameter sram_wr_done =  3'b100;

always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		o_address <= 8'h0;
		sram_state <= 3'h0;
	end else begin
		case (sram_state)
		sram_idle:
		begin
			if (spi_read)
				sram_state <= sram_reading;
			else if (spi_write)
				sram_state <= sram_writing;
			else
				sram_state <= sram_idle;
		end
		
		case sram_reading:
		begin
			o_address <= sram_addr;
			o_rw <= 1'b1;
			o_csn <= 1'b0;
			sram_state <= sram_rd_done;		
		end
		
		case sram_rd_done:
		begin
			o_rw <= 1'b1;
			o_csn <= 1'b1;
			sram_data <= out2;
			sram_state <= sram_idle;		
		end
		
		case sram_writing:
		begin
			o_address <= sram_addr;
			in2 <= sram_data;
			o_rw <= 1'b0;
			o_csn <= 1'b0;
			sram_state <= sram_wr_done;		
		end

		case sram_wr_done:
		begin
			o_rw <= 1'b1;
			o_csn <= 1'b1;
			sram_state <= sram_idle;		
		end
		endcase;
	end
end


always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		data = 8'h0;
		data1 = 8'h0;
		temp = 8'hff;
		//spi_pending = 1'b0;
	end else begin
		//o_address = 4'h4;
	
		data = sram_read(SRAM_SPI_CTRL);
		if (data[0]) begin
			//dram_read(SRAM_SPI_ADDR, data1);
			spi_write(SPI_ADDR_REG, data1);
			
			//dram_read(SRAM_SPI_TXD, data1);
			spi_write(SPI_TX_REG, data1);
			
			spi_write(SPI_CTRL_REG, data);
			
			//spi_pending = 1'b1;
		end
/*		
		if (spi_pending) begin
			spi_read(SPI_CTRL_REG, temp);
			if (!temp[0]) begin
				spi_read(SPI_RX_REG, temp);
				dram_write(SRAM_SPI_RXD, temp);
				dram_write(SRAM_SPI_CTRL, 8'h0);
				spi_pending = 1'b0;
			end
		end
		*/
	end
end

task dram_write;
	input	[awidth -1:0]	a;
	input	[dwidth -1:0]	d;
	
	begin
		@(posedge i_ck);
		o_address = a;
		i_data = d;
		o_rw = 1'b1;
		o_csn = 1'b0;
		
		@(posedge i_ck);
		//d = i_data;
		o_csn = 1'b1;	
		o_address = {awidth{1'bz}};
		o_rw = 1'b1;
	end
endtask

function [7:0] sram_read;
	input	[awidth -1:0]	a;
	begin
		//@(posedge i_ck);
		o_address = a;
		o_rw = 1'b1;
		o_csn = 1'b0;
		
		//@(posedge i_ck);
		sram_read = out2;
		o_csn = 1'b1;	
		o_address = {awidth{1'bz}};
		o_rw = 1'b1;
	end	
endfunction

task dram_read;
	input	[awidth -1:0]	a;
	output [dwidth -1:0]	d;
	
	begin
		//@(posedge i_ck);
		o_address = a;
		o_rw = 1'b1;
		o_csn = 1'b0;
		
		//@(posedge i_ck);
		d = out2;
		o_csn = 1'b1;	
		o_address = {awidth{1'bz}};
		o_rw = 1'b1;
	end
endtask


task spi_write;
	input	[awidth -1:0]	a;
	input	[dwidth -1:0]	d;

	begin
	//	@(posedge i_ck);
		adr  = a;
		din = d;
		wr  = 1'b1;
		rd  = 1'b0;
		//@(posedge i_ck);

		wr  = 1'b0;
		rd  = 1'b0;
	end
endtask

task spi_read;
	input	 [awidth -1:0]	a;
	output	[dwidth -1:0]	d;

	begin
		//@(posedge i_ck);
		adr  = a;
		//dout = {dwidth{1'bx}};
		wr  = 1'b0;
		rd  = 1'b1;
	
		//@(posedge i_ck);
		d    = spi_dat_o;
		wr  = 1'b0;
		rd  = 1'b0;
		adr  = {awidth{1'bx}};
		//dout = {dwidth{1'bx}};
		
	end
endtask

endmodule
