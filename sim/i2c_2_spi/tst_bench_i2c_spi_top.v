/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE rev.B2 compliant I2C Master controller Testbench  ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: tst_bench_top.v,v 1.8 2006/09/04 09:08:51 rherveille Exp $
//
//  $Date: 2006/09/04 09:08:51 $
//  $Revision: 1.8 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: tst_bench_top.v,v $
//               Revision 1.8  2006/09/04 09:08:51  rherveille
//               fixed (n)ack generation
//
//               Revision 1.7  2005/02/27 09:24:18  rherveille
//               Fixed scl, sda delay.
//
//               Revision 1.6  2004/02/28 15:40:42  rherveille
//               *** empty log message ***
//
//               Revision 1.4  2003/12/05 11:04:38  rherveille
//               Added slave address configurability
//
//               Revision 1.3  2002/10/30 18:11:06  rherveille
//               Added timing tests to i2c_model.
//               Updated testbench.
//
//               Revision 1.2  2002/03/17 10:26:38  rherveille
//               Fixed some race conditions in the i2c-slave model.
//               Added debug information.
//               Added headers.
//

`include "timescale.v"

module tst_bench_i2c_spi_top();

	//
	// wires && regs
	//
	reg  clk;
	reg  clk2;
	reg  rstn;

	wire [31:0] adr;
	wire [ 7:0] dat_i, dat_o;
	wire we;
	wire stb;
	wire cyc;
	wire ack;
	wire inta;

	reg [7:0] q, qq, qqq, temp;

	wire scl, scl_o, scl_oen;
	wire sda, sda_o, sda_oen;
	
	//////////////////////////////
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
	
	wire miso;
	wire sclk, mosi, scs;
		
	//////////////////////////////

	parameter PRER_LO = 3'b000;
	parameter PRER_HI = 3'b001;
	parameter CTR     = 3'b010;
	parameter RXR     = 3'b011;
	parameter TXR     = 3'b011;
	parameter CR      = 3'b100;
	parameter SR      = 3'b100;

	parameter TXR_R   = 3'b101; // undocumented / reserved output
	parameter CR_R    = 3'b110; // undocumented / reserved output

	parameter RD      = 1'b1;
	parameter WR      = 1'b0;
	parameter SADR    = 7'b0010_000;
	parameter SADR2    = 7'b0100_000;

	
	parameter SRAM_SPI_ADDR = 4'b0000;
	parameter SRAM_SPI_TXD  = 4'b0001;
	parameter SRAM_SPI_RXD  = 4'b0011;
	parameter SRAM_SPI_CTRL = 4'b0010;
	
	parameter SPI_ADDR_REG = 4'b0010;
	parameter SPI_TX_REG   = 4'b0001;
	parameter SPI_CTRL_REG = 4'b0000;
	parameter SPI_RX_REG   = 4'b0011;
	
	parameter SPI_REG_ADDR = 8'h81;
	parameter SPI_REG_DATA = 8'h77;
	parameter SPI_REG_DUMMY= 8'h11;
	//
	// Module body
	//

	// generate clock
	always #5 clk = ~clk;
	always #500 clk2 = ~clk2;
	
	assign miso = mosi;

	// hookup wishbone master model
	wb_master_model #(8, 32) u0 (
		.clk(clk),
		.rst(rstn),
		.adr(adr),
		.din(dat_i),
		.dout(dat_o),
		.cyc(cyc),
		.stb(stb),
		.we(we),
		.sel(),
		.ack(ack),
		.err(1'b0),
		.rty(1'b0)
	);

	// hookup wishbone_i2c_master core
	i2c_master_top i2c_top (

		// wishbone interface
		.wb_clk_i(clk),
		.wb_rst_i(1'b0),
		.arst_i(rstn),
		.wb_adr_i(adr[2:0]),
		.wb_dat_i(dat_o),
		.wb_dat_o(dat_i),
		.wb_we_i(we),
		.wb_stb_i(stb),
		.wb_cyc_i(cyc),
		.wb_ack_o(ack),
		.wb_inta_o(inta),

		// i2c signals
		.scl_pad_i(scl),
		.scl_pad_o(scl_o),
		.scl_padoen_o(scl_oen),
		.sda_pad_i(sda),
		.sda_pad_o(sda_o),
		.sda_padoen_o(sda_oen)
	);

////////////////////////////////////////////////////////////////////
 i2c_2_spi i2cspi(
	.i_ck(clk),
	.i_rstn(rstn),
	.i_i2c_clk(scl),
	.io_i2c_dat(sda),
	
	.o_spi_clk(sclk),
	.o_spi_csn(scs),
	.o_spi_mosi(mosi),
	.i_spi_miso(miso)
);
////////////////////////////////////////////////////////////////////

	// create i2c tri-state line
	assign scl = scl_oen ? 1'bz : scl_o;
	assign sda = sda_oen ? 1'bz : sda_o;

	pullup p1(scl); // pullup scl line
	pullup p2(sda); // pullup sda line

	initial
	  begin
	      $display("\nstatus: %t Testbench started\n\n", $time);

	      // initially values
	      clk = 0;
	      clk2 = 0;
		  //miso = 0;
	      // reset system
	      rstn = 1'b1; // negate reset
	      #100;
	      rstn = 1'b0; // assert reset
	      repeat(1) @(posedge clk);
	      rstn = 1'b1; // negate reset

	      $display("status: %t done reset", $time);

	      @(posedge clk);

	      /////////////////////////////////////////////
	      // program core
	      /////////////////////////////////////////////

	      // program internal registers
	      //u0.wb_write(1, PRER_LO, 8'hfa); // load prescaler lo-byte
	      u0.wb_write(1, PRER_LO, 8'hc8); // load prescaler lo-byte
	      u0.wb_write(1, PRER_HI, 8'h00); // load prescaler hi-byte
	      $display("status: %t programmed registers", $time);

	      u0.wb_cmp(0, PRER_LO, 8'hc8); // verify prescaler lo-byte
	      u0.wb_cmp(0, PRER_HI, 8'h00); // verify prescaler hi-byte
	      $display("status: %t verified registers", $time);

	      u0.wb_write(1, CTR,     8'h80); // enable core
	      $display("status: %t core enabled", $time);

	      /////////////////////////////////////////////
	      // access slave (write)
	      /////////////////////////////////////////////

		  
		  wirte_i2c(2, SADR, SRAM_SPI_ADDR, SPI_REG_ADDR, SPI_REG_DATA);//send spi slave address and data
		  wirte_i2c(1, SADR, SRAM_SPI_CTRL, 8'h01, SPI_REG_DUMMY);   // send spi ctrl to start spi send
		  
		  
	      //$display("status: %t tip==0", $time);
		    #10000
			$display("\nstatus: %t spi model start\n\n", $time);
			read_i2c(1, SADR, SRAM_SPI_CTRL, qqq);
			$display("\nstatus: %t read spi ctrl %x\n\n", $time, qqq);
			while(qqq[0])
				read_i2c(1, SADR, SRAM_SPI_CTRL, qqq);
			
			read_i2c(1, SADR, SRAM_SPI_RXD, qqq);
			$display("\nstatus: %t read spi rx data %x\n\n", $time, qqq);	
			
			
			
			
		  wirte_i2c(2, SADR, SRAM_SPI_ADDR, SPI_REG_ADDR, 8'h99);//send spi slave address and data
		  wirte_i2c(1, SADR, SRAM_SPI_CTRL, 8'h01, SPI_REG_DUMMY);   // send spi ctrl to start spi send
		  
		  
	      //$display("status: %t tip==0", $time);
		    #10000
			$display("\nstatus: %t spi model start\n\n", $time);
			read_i2c(1, SADR, SRAM_SPI_CTRL, qqq);
			$display("\nstatus: %t read spi ctrl %x\n\n", $time, qqq);
			while(qqq[0])
				read_i2c(1, SADR, SRAM_SPI_CTRL, qqq);
			
			read_i2c(1, SADR, SRAM_SPI_RXD, qqq);
			$display("\nstatus: %t read spi rx data %x\n\n", $time, qqq);				
			#250000; // wait 250us
			$display("\n\nstatus: %t Testbench done", $time);
			$stop;		 
	      //$stop;
	  end

task wirte_i2c;
input   dnum;
integer dnum;
input [6:0] device_id;
input [7:0] addr;
input [7:0] data;
input [7:0] data2;
	begin
	      /////////////////////////////////////////////
	      // access slave (write)
	      /////////////////////////////////////////////

	      // drive slave address
	      u0.wb_write(1, TXR, {device_id,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write)", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(0, SR, q); // poll it until it is zero
	      //$display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     addr); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address %x", $time, addr);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(0, SR, q); // poll it until it is zero
	      //$display("status: %t tip==0", $time);

	      // send memory contents
	      u0.wb_write(1, TXR,     data); // present data
		  if (dnum == 2)
			u0.wb_write(0, CR,      8'h10); // set command (write)
		  else
		    u0.wb_write(0, CR,      8'h50); // set command (stop, write)
	      $display("status: %t write data %x", $time, data);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      //$display("status: %t tip==0", $time);
		if (dnum == 2) begin
	      // send memory contents for next memory address (auto_inc)
	      u0.wb_write(1, TXR,     data2); // present data
	      u0.wb_write(0, CR,      8'h50); // set command (stop, write)
	      $display("status: %t write next data %x, generate 'stop'", $time, data2);
		
	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t send i2c data ok", $time);
		end
	end
endtask	


task read_i2c;
input   dnum;
integer dnum;
input [6:0] device_id;
input [7:0] addr;
output [7:0] data;

	begin
	      /////////////////////////////////////////////
	      // access slave (read)
	      /////////////////////////////////////////////

	      // drive slave address
	      u0.wb_write(1, TXR,{SADR,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,     8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write)", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     addr); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave address 01", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // drive slave address
	      u0.wb_write(1, TXR, {SADR,RD} ); // present slave's address, set read-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'repeated start', write cmd %0h (slave address+read)", $time, {SADR,RD} );

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h28); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, temp);
	      $display("status: %t received %x .", $time, temp);
		data = temp;
	end
endtask
////////////////////////////////////////////////////////////////////
	specify
	  specparam normal_scl_low  = 4700,
	            normal_scl_high = 4000,
	            normal_tsu_sta  = 4700,
	            normal_thd_sta  = 4000,
	            normal_tsu_sto  = 4000,

	            fast_scl_low  = 1300,
	            fast_scl_high =  600,
	            fast_tsu_sta  = 1300,
	            fast_thd_sta  =  600,
	            fast_tsu_sto  =  600,
	            fast_tbuf     = 1300;

	  $width(negedge scl, normal_scl_low);  // scl low time
	  $width(posedge scl, normal_scl_high); // scl high time

	  $setup(posedge scl, negedge sda &&& scl, normal_tsu_sta); // setup start
	  $setup(negedge sda &&& scl, negedge scl, normal_thd_sta); // hold start
	  $setup(posedge scl, posedge sda &&& scl, normal_tsu_sto); // setup stop

	endspecify
////////////////////////////////////////////////////////////////////
  
endmodule
