ECHO OFF

set i2c_rtl=..\..\rtl\spi_master

vlib work

vlog %i2c_rtl%\spi_master_model.v

vlog %i2c_rtl%\spi_master.v

vlog tst_bench_spi_top.v

vsim -t 1ns -lib work tst_bench_spi_top

ECHO ON
