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

parameter SADR= 7'b0010_000;

parameter dwidth = 8;
parameter awidth = 4;

//sram port 1
wire[7:0] in, out;
wire[3:0] addr;
wire RW;
wire EN;

//sram port 2
wire[7:0] in2, out2;
wire[3:0] addr2;
wire RW2;
wire EN2;	

//spi master r/w port
wire [3:0] addr3;
wire [ 7:0] in3, out3;
wire wr;
wire rd;


reg o_sram_rw; 
reg o_sram_csn; 
reg [3:0] o_sram_address;
reg [7:0] i_sram_data;
reg [7:0] o_sram_data;


reg [3:0]	o_spi_address;
reg  [7:0]	i_spi_data;
//reg [7:0]	dout;
reg       o_spi_wr,o_spi_rd;

assign in2 = i_sram_data;
//assign out2 = o_data;
assign addr2 = o_sram_address;
assign RW2 = o_sram_rw;
assign EN2 = o_sram_csn;

assign addr3 = o_spi_address;
assign in3 = i_spi_data;
assign wr = o_spi_wr;
assign rd = o_spi_rd;
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

spi_master ins_spi_master (
		.i_ck(i_ck),
		.i_rstn(i_rstn),
		.o_sclk(o_spi_clk),
		.o_csn(o_spi_csn),
		.i_miso(i_spi_miso),
		.o_mosi(o_spi_mosi),
		.i_address(addr3),
		.i_data(in3),
		.o_data(out3),
		.i_wr(wr),
		.i_rd(rd)
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

reg [3:0] sram_addr;
reg [7:0] sram_r_data, sram_w_data;

reg [3:0] spi_master_addr;
reg [7:0] spi_master_r_data,spi_master_w_data;

reg sram_read, sram_write, spi_read, spi_write;

reg [2:0] spi_rw_state;
parameter spi_rw_idle = 3'b000;
parameter spi_reading =  3'b001;
parameter spi_rd_done =  3'b010;
parameter spi_writing = 3'b011;
parameter spi_wr_done =  3'b100;

reg [2:0] sram_rw_state;
parameter sram_idle = 3'b000;
parameter sram_reading =  3'b001;
parameter sram_rd_done =  3'b010;
parameter sram_writing = 3'b011;
parameter sram_wr_done =  3'b100;

reg [3:0] top_state;
parameter spi_idle = 4'b0000;
parameter spi_get_addr = 4'b0001;
parameter spi_get_data =  4'b0010;
parameter spi_put_addr = 4'b0011;
parameter spi_put_data = 4'b0100;
parameter spi_put_ctrl = 4'b0101;
parameter spi_read_ctrl = 4'b0110;
parameter spi_read_data = 4'b0111;
parameter spi_write_sram_spi_data = 4'b1000;
parameter spi_clear_sram_spi_ctrl = 4'b1001;
reg [2:0] clk_count;
parameter CLK_THR = 3'h5;
always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		top_state <= spi_idle;
		spi_master_w_data <= 8'h0;
		sram_w_data <= 8'h0;
		clk_count <= 3'h0;
		sram_read <= 1'b0;
		sram_write <= 1'b0;
		spi_read <= 1'b0;
		spi_write <= 1'b0;
	end else begin
		case (top_state)
		spi_idle:
		begin
			sram_addr <= SRAM_SPI_CTRL;
			if (!clk_count) begin
				sram_read <= 1'b1;
			end else
				sram_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				if (sram_r_data[0]) begin
					top_state <= spi_get_addr;
					spi_ctrl <= sram_r_data;
				end
				clk_count <= 3'h0;
			end
			
		end
		
		spi_get_addr:
		begin
			sram_addr <= SRAM_SPI_ADDR;
			if (!clk_count) begin
				sram_read <= 1'b1;
			end else
				sram_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0]) begin
					top_state <= spi_get_data;
					spi_addr <= sram_r_data;
				//end
				clk_count <= 3'h0;
			end
		end
		
		spi_get_data:
		begin
			sram_addr <= SRAM_SPI_TXD;
			if (!clk_count) begin
				sram_read <= 1'b1;
			end else
				sram_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0]) begin
					top_state <= spi_put_addr;
					spi_data <= sram_r_data;
				//end
				clk_count <= 3'h0;
			end
		end
		
		spi_put_addr:
		begin
			spi_master_addr <= SPI_ADDR_REG;
			spi_master_w_data <= spi_addr;
			if (!clk_count) begin
				spi_write <= 1'b1;
			end else
				spi_write <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0])
				top_state <= spi_put_data;
				clk_count <= 3'h0;
			end		
		end
		
		spi_put_data:
		begin
			spi_master_addr <= SPI_TX_REG;
			spi_master_w_data <= spi_data;
			if (!clk_count) begin
				spi_write <= 1'b1;
			end else
				spi_write <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0])
				top_state <= spi_put_ctrl;
				clk_count <= 3'h0;
			end		
		end
		
		spi_put_ctrl:
		begin
			spi_master_addr <= SPI_CTRL_REG;
			spi_master_w_data <= spi_ctrl;
			if (!clk_count) begin
				spi_write <= 1'b1;
			end else
				spi_write <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0])
				top_state <= spi_read_ctrl;
				clk_count <= 3'h0;
			end		
		end
		
		spi_read_ctrl:
		begin
			spi_master_addr <= SPI_CTRL_REG;
			//spi_master_data <= spi_ctrl;
			if (!clk_count) begin
				spi_read <= 1'b1;
			end else
				spi_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0])
				if(spi_master_r_data[0])
					top_state <= spi_read_ctrl;
				else
					top_state <= spi_read_data;
				clk_count <= 3'h0;
			end		
		end
		
		spi_read_data:
		begin
			spi_master_addr <= SPI_RX_REG;
			//spi_master_data <= spi_ctrl;
			if (!clk_count) begin
				spi_read <= 1'b1;
			end else
				spi_read <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				//if (sram_data[0])
				spi_data <= spi_master_r_data;
				top_state <= spi_write_sram_spi_data;
				clk_count <= 3'h0;
			end		
		end
		
		spi_write_sram_spi_data:
		begin
			sram_addr <= SRAM_SPI_RXD;
			sram_w_data <= spi_data;
			//spi_master_data <= spi_ctrl;
			if (!clk_count) begin
				sram_write <= 1'b1;
			end else
				sram_write <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				top_state <= spi_clear_sram_spi_ctrl;
				clk_count <= 3'h0;
			end		
		end
		
		spi_clear_sram_spi_ctrl:
		begin
			sram_addr <= SRAM_SPI_CTRL;
			sram_w_data <= {spi_ctrl[7:1], 1'b0};
			//spi_master_data <= spi_ctrl;
			if (!clk_count) begin
				sram_write <= 1'b1;
			end else
				sram_write <= 1'b0;
			clk_count <= clk_count + 1'b1;
			if (clk_count == CLK_THR) begin
				top_state <= spi_idle;
				clk_count <= 3'h0;
			end		
		end
		endcase
	end
end 


always @(negedge i_rstn or negedge i_ck) begin
	if (!i_rstn) begin
		o_spi_address <= 4'h0;
		o_spi_wr <= 1'b0;
		o_spi_rd <= 1'b0;		
		spi_rw_state <= spi_rw_idle;
		spi_master_r_data <= 8'h0;
	end else begin
		case (spi_rw_state)
		spi_rw_idle:
		begin
			if (spi_read)
				spi_rw_state <= spi_reading;
			else if (spi_write)
				spi_rw_state <= spi_writing;
			else
				spi_rw_state <= spi_rw_idle;
		end
		
		spi_reading:
		begin
			o_spi_address <= spi_master_addr;
			o_spi_wr <= 1'b0;
			o_spi_rd <= 1'b1;
			spi_rw_state <= spi_rd_done;
		end
		
		spi_rd_done:
		begin
			o_spi_wr <= 1'b0;
			o_spi_rd <= 1'b0;
			spi_master_r_data <= out3;	
			spi_rw_state <= spi_rw_idle;
		end
		
		spi_writing:
		begin
			o_spi_address <= spi_master_addr;
			i_spi_data <= spi_master_w_data;
			o_spi_wr <= 1'b1;
			o_spi_rd <= 1'b0;
			spi_rw_state <= spi_wr_done;
		end
		
		spi_wr_done:
		begin
			o_spi_wr <= 1'b0;
			o_spi_rd <= 1'b0;
			spi_rw_state <= spi_rw_idle;		
		end
		endcase
	end
end


always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		o_sram_address <= 4'h0;
		o_sram_rw <= 1'b1;
		o_sram_csn <= 1'b1;		
		sram_rw_state <= sram_idle;
	end else begin
		case (sram_rw_state)
		sram_idle:
		begin
			if (sram_read)
				sram_rw_state <= sram_reading;
			else if (sram_write)
				sram_rw_state <= sram_writing;
			else
				sram_rw_state <= sram_idle;
		end
		
		sram_reading:
		begin
			o_sram_address <= sram_addr;
			o_sram_rw <= 1'b1;
			o_sram_csn <= 1'b0;
			sram_rw_state <= sram_rd_done;		
		end
		
		sram_rd_done:
		begin
			o_sram_rw <= 1'b1;
			o_sram_csn <= 1'b1;
			sram_r_data <= out2;
			sram_rw_state <= sram_idle;		
		end
		
		sram_writing:
		begin
			o_sram_address <= sram_addr;
			i_sram_data <= sram_w_data;
			o_sram_rw <= 1'b0;
			o_sram_csn <= 1'b0;
			sram_rw_state <= sram_wr_done;		
		end

		sram_wr_done:
		begin
			o_sram_rw <= 1'b1;
			o_sram_csn <= 1'b1;
			sram_rw_state <= sram_idle;		
		end
		endcase
	end
end

endmodule
