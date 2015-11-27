ECHO OFF

set i2c_rtl_m=..\..\rtl\i2c_master
set i2c_rtl_s=..\..\rtl\i2c_slave
set i2c_rtl_d=..\..\rtl\dram

vlib work

vlog +incdir+%i2c_rtl_m% %i2c_rtl_m%\i2c_master_bit_ctrl.v 
vlog +incdir+%i2c_rtl_m% %i2c_rtl_m%\i2c_master_byte_ctrl.v
vlog +incdir+%i2c_rtl_m% %i2c_rtl_m%\i2c_master_top.v
vlog +incdir+%i2c_rtl_m% %i2c_rtl_m%\i2c_master_model.v

vlog %i2c_rtl_s%\i2c_slave.v
vlog %i2c_rtl_d%\dram.v
vlog %i2c_rtl_d%\dram_bus2.v

vlog tst_bench_i2c_top.v

vsim -t 1ns -lib work tst_bench_i2c_top

ECHO ON
