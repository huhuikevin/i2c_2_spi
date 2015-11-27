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

module tst_bench_i2c_top();

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

	reg [7:0] q, qq;

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

	//
	// Module body
	//

	// generate clock
	always #5 clk = ~clk;
	always #500 clk2 = ~clk2;

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
	// hookup i2c slave module
	i2c_slave #(SADR) myslave(
		.i_ck(clk),
		.i_rstn(rstn),
		.SDA(sda),
		.SCL(scl),
		.sram_odata(out),
		.sram_idata(in),
		.sram_addr(addr),
		.sram_rw(RW),
		.sram_cs(EN)		
	);

	// hookup register file (sram) module
	dram myRAM_0(
		.i_rstn(rstn),
		.i_ck(clk),		
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
	
    dram_bus2 dbus2(
		.i_rstn(rstn),
		.i_ck(clk),		
		.o_data(in2),
		.o_address(addr2),
		.o_rw(RW2),
		.o_csn(EN2),
		.i_data(out2)
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

	      // reset system
	      rstn = 1'b1; // negate reset
	      #2;
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

	      // drive slave address
	      u0.wb_write(1, TXR, {SADR,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write)", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(0, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h01); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address 01", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(0, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory contents
	      u0.wb_write(1, TXR,     8'ha5); // present data
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write data a5", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory contents for next memory address (auto_inc)
	      u0.wb_write(1, TXR,     8'h5a); // present data
	      u0.wb_write(0, CR,      8'h50); // set command (stop, write)
	      $display("status: %t write next data 5a, generate 'stop'", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      //
	      // delay
	      //
	      #100000; // wait for 100us.
	      $display("status: %t wait 100us", $time);

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
	      u0.wb_write(1, TXR,     8'h01); // present slave's memory address
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
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      if(qq !== 8'ha5)
	        $display("\nERROR: Expected a5, received %x at time %t", qq, $time);
	      else
	        $display("status: %t received %x meet the expected.", $time, qq);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      if(qq !== 8'h5a)
	        $display("\nERROR: Expected 5a, received %x at time %t", qq, $time);
	      else
	        $display("status: %t received %x meet the expected", $time, qq);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h20); // set command (read, ack_read)
	      $display("status: %t read + ack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      $display("status: %t received %x from 3rd read address", $time, qq);

	      // read data from slave
	      u0.wb_write(1, CR,      8'h28); // set command (read, nack_read)
	      $display("status: %t read + nack", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // check data just received
	      u0.wb_read(1, RXR, qq);
	      $display("status: %t received %x from 4th read address", $time, qq);

	      /////////////////////////////////////////////
	      // check invalid slave memory address
	      /////////////////////////////////////////////

	      // drive slave address
	      u0.wb_write(1, TXR, {SADR2,WR} ); // present slave address, set write-bit
	      u0.wb_write(0, CR,      8'h90 ); // set command (start, write)
	      $display("status: %t generate 'start', write cmd %0h (slave address+write). Check invalid address", $time, {SADR,WR} );

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // send memory address
	      u0.wb_write(1, TXR,     8'h10); // present slave's memory address
	      u0.wb_write(0, CR,      8'h10); // set command (write)
	      $display("status: %t write slave memory address 10", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	           u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

	      // slave should have send NACK
	      $display("status: %t Check for nack", $time);
	      if(!q[7])
	        $display("\nERROR: Expected NACK, received ACK\n");

	      // read data from slave
	      u0.wb_write(1, CR,      8'h40); // set command (stop)
	      $display("status: %t generate 'stop'", $time);

	      // check tip bit
	      u0.wb_read(1, SR, q);
	      while(q[1])
	      u0.wb_read(1, SR, q); // poll it until it is zero
	      $display("status: %t tip==0", $time);

		  
		  dbus2.dram_read(1, 4'h1, qq);
		  $display("read dram addr 1: %t data=%x", $time, qq);
		  dbus2.dram_write(1, 4'h3, 8'h9a);
		  $display("write dram addr 3: %t data=9a", $time);	
		  dbus2.dram_read(1, 4'h3, qq);
		  $display("read dram addr 3: %t data=%x", $time, qq);		  
	      #250000; // wait 250us
	      $display("\n\nstatus: %t Testbench done", $time);
	      $stop;
	  end


	  
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
