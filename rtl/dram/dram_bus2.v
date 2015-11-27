module dram_bus2(
	i_rstn,
	i_ck,

	o_rw,
	o_csn,
	o_address,
	i_data,
	o_data	
);

input i_rstn;
input i_ck;
output reg o_rw; //0:write, 1:read
output reg o_csn; //0:chip select, 1:chip deselect
output reg [3:0] o_address;
input [7:0] i_data;
output [7:0] o_data;
reg [7:0] o_data;

parameter dwidth = 8;
parameter awidth = 4;

always @(negedge i_rstn) begin
	o_rw <= 1'b1;
	o_csn <= 1'b1;
	o_address <= {awidth{1'bz}};
	o_data <= {dwidth{1'bz}};
end

task dram_write;
	input   delay;
	//integer delay;

	input	[awidth -1:0]	a;
	input	[dwidth -1:0]	d;
	
	begin
		// wait initial delay
		repeat(delay) @(posedge i_ck);
		
		@(posedge i_ck);
		o_address = a;
		o_data = d;
		o_rw = 1'b0;
		o_csn = 1'b0;
		
		@(posedge i_ck);
		o_csn = 1'b1;	
		o_address = {awidth{1'bz}};
		o_data = {dwidth{1'bz}};
		o_rw = 1'b1;
	end
endtask

task dram_read;
	input   delay;
	//integer delay;

	input	[awidth -1:0]	a;
	output [dwidth -1:0]	d;
	
	begin
		// wait initial delay
		repeat(delay) @(posedge i_ck);
		
		@(posedge i_ck);
		o_address = a;
		o_rw = 1'b1;
		o_csn = 1'b0;
		
		@(posedge i_ck);
		d = i_data;
		o_csn = 1'b1;	
		o_address = {awidth{1'bz}};
		o_rw = 1'b1;
	end
endtask


endmodule
