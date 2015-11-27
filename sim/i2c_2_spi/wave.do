onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tst_bench_i2c_spi_top/clk
add wave -noupdate /tst_bench_i2c_spi_top/rstn
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/spi_ctrl
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/o_csn
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/o_sclk
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/o_mosi
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/i_miso
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/spi_state
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/change_state
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/slave_reg_data_i
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/slave_reg_data_o
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/slave_reg_addr_o
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/temp_data
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/temp_addr
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/temp_rx_data
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/i_address
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/i_data
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/i_wr
add wave -noupdate -format Logic /tst_bench_i2c_spi_top/u1/i_rd

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {789735 ns} 1} {{Cursor 2} {1332931 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 244
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1332844 ns} {1333136 ns}
