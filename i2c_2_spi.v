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
	
 dram_bus2 ins_dram_bus2(
		.i_rstn(i_rstn),
		.i_ck(i_ck),		
		.o_data(in2),
		.o_address(addr2),
		.o_rw(RW2),
		.o_csn(EN2),
		.i_data(out2)
	);

spi_master_model #(8, 4) ins_spi_access (
		.clk(i_ck),
		.rst(i_rstn),
		.adr(spi_adr),
		.din(spi_dat_i),
		.dout(spi_dat_o),
		.wr(spi_wr),
		.rd(spi_rd)
	);

spi_master #(40) ins_spi_master (
		.i_ck(i_ck),
		.i_rstn(i_rstn),
		.o_sclk(o_spi_clk),
		.o_csn(o_spi_csn),
		.i_miso(i_spi_miso),
		.o_mosi(o_spi_mosi),
		.i_address(spi_adr),
		.i_data(spi_dat_o),
		.o_data(spi_dat_i),
		.i_wr(spi_wr),
		.i_rd(spi_rd)
	);	

always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
	
	end else begin
	
	end
end	
	
endmodule
