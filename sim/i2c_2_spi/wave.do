onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tst_bench_i2c_spi_top/clk
add wave -noupdate /tst_bench_i2c_spi_top/rstn
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/top_state
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/spi_rw_state
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/sram_rw_state
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/sram_w_data
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/sram_r_data
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/spi_master_addr
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/spi_master_w_data
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/spi_master_r_data
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/i_i2c_clk
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/io_i2c_dat
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/ins_i2c_slave/sda_out_en
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/ins_i2c_slave/sda_state
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/ins_i2c_slave/i2c_state
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/ins_i2c_slave/sda_out
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/ins_i2c_slave/indat_done
add wave -noupdate /tst_bench_i2c_spi_top/i2cspi/ins_i2c_slave/send_done
add wave -noupdate /tst_bench_i2c_spi_top/miso
add wave -noupdate /tst_bench_i2c_spi_top/sclk
add wave -noupdate /tst_bench_i2c_spi_top/mosi
add wave -noupdate /tst_bench_i2c_spi_top/scs
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
