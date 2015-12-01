module spi_master(
	i_ck,
	i_rstn,
	o_sclk,
	o_csn,
	i_miso,
	o_mosi,
	i_address,
	i_data,
	o_data,
	i_wr,
	i_rd
);
input i_ck;
input i_rstn;
output reg o_csn;
output reg o_sclk;
input i_miso;
output reg o_mosi;
input [3:0] i_address;
input  [7:0] i_data; 
output [7:0] o_data;
reg [7:0] o_data;
input i_wr;
input i_rd;

parameter CLK_CYCLE = 8'd40;// i_ck 100M, spi clk = 2.5M

//reg [7:0] temp_out;

//address 1 slave_reg_data_o[0], address 2 slave_reg_data_o[1]
reg [7:0] slave_reg_data_o;//device's reg's address
//address 2 slave_reg_data_o[1]
reg [7:0] slave_reg_addr_o;//data to send
//address 3
reg [7:0] slave_reg_data_i;//data to recv
//address 0, bit 0:start/stop, bit 1 r/w, bit 2 r/w finished
//bit 3, msb/lsb
reg [7:0] spi_ctrl;

reg [7:0] clk_cnt;
//reg clk_en;
reg o_sclk_r;
reg [4:0] bit_cnt;
parameter S_IDLE = 3'b000;
parameter S_START = 3'b001;
parameter S_TX_DATA = 3'b010;
parameter S_TX_ADDR = 3'b011;
parameter S_WAIT_STOP = 3'b101;
parameter S_STOP = 3'b100;

reg [2:0] spi_state;

//parameter MSB = 1'b1;
//assign o_sclk = (clk_en)?o_sclk_r:1'b1;
reg [7:0] temp_addr;
reg [7:0] temp_data;
reg [7:0] temp_rx_data;
reg change_state;
//reg clr_spi_ctrl;
//reg clear_change_state;
reg spi_start;
wire spi_start_rise;
always @(negedge i_rstn or negedge i_ck) begin
	if (!i_rstn)
		spi_start <= 1'b0;
	else begin
		spi_start <= spi_ctrl[0];
	end
end

assign spi_start_rise = spi_ctrl[0] && ~spi_start;
//assign o_data = temp_out;

always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		slave_reg_data_o <= 8'h0;
		slave_reg_addr_o <= 8'h0;
		spi_ctrl <= 8'h0;
	end else begin
		if (i_wr) begin
			case (i_address)
			4'b0000:
			begin
				spi_ctrl <= i_data;
			end
			
			4'b0001:
			begin
				slave_reg_data_o <= i_data;
			end
			
			4'b0010:
			begin
				slave_reg_addr_o <= i_data;
			end
			endcase
		end else if (i_rd) begin
			case (i_address)
			4'b0011:
			begin
				o_data <= slave_reg_data_i;
			end
			4'b0000:
			begin
				if (spi_state == S_WAIT_STOP || spi_state == S_STOP)
					o_data <= {spi_ctrl[7:1], 1'b1};
				else
					o_data <= spi_ctrl;
			end			
			endcase
		end else if (spi_state == S_STOP)
			spi_ctrl <= {spi_ctrl[7:1], 1'b0};
	end
end

always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		clk_cnt <= 8'h0;
	end else if (spi_state == S_TX_ADDR || spi_state == S_TX_DATA || spi_state == S_WAIT_STOP)begin
		if (clk_cnt == CLK_CYCLE) begin
			clk_cnt <= 8'h0;
		end else
			clk_cnt <= clk_cnt + 1'b1;
	end else begin
		clk_cnt <= 8'h0;
	end
end


always @(negedge i_rstn or posedge i_ck) begin
	if (!i_rstn) begin
		o_csn <= 1'b1;
		o_sclk <= 1'b1;
		o_mosi <= 1'b0;
		bit_cnt <= 5'b00000;
		temp_addr <= 8'h0;
		temp_data <= 8'h0;
		temp_rx_data <= 8'h0;
		change_state <= 1'b0;
		//clr_spi_ctrl <= 1'b0;
		slave_reg_data_i <= 8'h0;
	end else begin
		if (spi_state == S_IDLE) begin
			o_csn <= 1'b1;
			o_sclk <= 1'b1;
			o_mosi <= 1'b0;
			bit_cnt <= 5'b00000;
			temp_addr <= 8'h0;
			temp_data <= 8'h0;
			temp_rx_data <= 8'h0;
			change_state <= 1'b0;
			//clr_spi_ctrl <= 1'b0;
		end else if (spi_state == S_START) begin
			o_csn <= 1'b0;
			if (!spi_ctrl[3]) begin
				temp_addr <= slave_reg_addr_o;
				temp_data <= slave_reg_data_o;
			end else begin
				temp_addr <= {slave_reg_addr_o[0],slave_reg_addr_o[1],slave_reg_addr_o[2],slave_reg_addr_o[3],
				              slave_reg_addr_o[4],slave_reg_addr_o[5],slave_reg_addr_o[6],slave_reg_addr_o[7]};
				temp_data <= {slave_reg_data_o[0],slave_reg_data_o[1],slave_reg_data_o[2],slave_reg_data_o[3],
				              slave_reg_data_o[4],slave_reg_data_o[5],slave_reg_data_o[6],slave_reg_data_o[7]};			
			end
			change_state <= 1'b1;
		end else if (spi_state == S_TX_ADDR) begin
			change_state <= 1'b0;
			if (clk_cnt == CLK_CYCLE/2) begin
				o_mosi <= temp_addr[5'h7 -  bit_cnt];
				o_sclk <= 1'b0;
				bit_cnt <= bit_cnt + 1'b1;

			end else if (clk_cnt == CLK_CYCLE) begin
				if (bit_cnt == 5'h8) begin
					bit_cnt <= 5'h0;
					change_state <= 1'b1;
				end			
				o_sclk <= 1'b1;
			end
		end else if (spi_state == S_TX_DATA) begin
			change_state <= 1'b0;
			if (clk_cnt == CLK_CYCLE/2) begin
				o_mosi <= temp_data[5'h7 -  bit_cnt];
				o_sclk <= 1'b0;
				bit_cnt <= bit_cnt + 1'b1;
			end else if (clk_cnt == CLK_CYCLE) begin
				temp_rx_data <= {temp_rx_data[6:0], i_miso};
				o_sclk <= 1'b1;
				if (bit_cnt == 5'h8) begin
					bit_cnt <= 5'h0;
					change_state <= 1'b1;
				end
			end
		end else if (spi_state == S_WAIT_STOP) begin
			change_state <= 1'b0;
			//if (clk_cnt == CLK_CYCLE) begin
			//	temp_rx_data <= {temp_rx_data[6:0], i_miso};//laster recv bit
			//	o_sclk <= 1'b1;
			//end else if (clk_cnt == (CLK_CYCLE/2)) begin
			if (clk_cnt == (CLK_CYCLE/2)) begin
				change_state <= 1'b1;
				//spi_ctrl[0] <= 1'b0;//spi tx finished
				//clr_spi_ctrl <= 1'b1;//clear spi start flag
				if (!spi_ctrl[3]) begin
					slave_reg_data_i <= temp_rx_data;
				end else begin
					slave_reg_data_i <= {temp_rx_data[0],temp_rx_data[1],temp_rx_data[2],temp_rx_data[3],
												temp_rx_data[4],temp_rx_data[5],temp_rx_data[6],temp_rx_data[7]};
				end				
			end
		end else begin
			o_csn <= 1'b1;
			change_state <= 1'b0;
		end
	end
end

/*
always @(i_rstn or spi_next_state) begin
	if (!i_rstn) begin
		spi_state <= S_IDLE;
	end else begin
		spi_state <= spi_next_state;
	end
end
*/

always @(negedge i_rstn or negedge i_ck) begin
	if (!i_rstn) begin
		spi_state <= S_IDLE;
	end else begin
		case (spi_state)
		S_IDLE:
		begin
			if (spi_start_rise)
				spi_state <= S_START;
			else
				spi_state <= S_IDLE;
		end
		
		S_START:
		begin
			if (change_state) begin
				spi_state <= S_TX_ADDR;
		   end else begin
				spi_state <= S_START;
			end
		end
		S_TX_ADDR:
		begin
			if (change_state) begin
				spi_state <= S_TX_DATA;
			end else begin
				spi_state <= S_TX_ADDR;
			end
		end
		S_TX_DATA:
		begin
			if (change_state) begin
				spi_state <= S_WAIT_STOP;
			end else begin
				spi_state <= S_TX_DATA;
			end	
		end			
		S_WAIT_STOP:
		begin
			if (change_state) begin
				spi_state <= S_STOP;
			end else begin			
				spi_state <= S_WAIT_STOP;
			end
		end
		S_STOP:
		begin
			//if (!spi_ctrl[0]) // wait spi start bit been clear
			spi_state <= S_IDLE;
			//else
			//	spi_state <= S_STOP;
		end
		endcase
	end
end

endmodule
