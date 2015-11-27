onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tst_bench_i2c_top/clk
add wave -noupdate /tst_bench_i2c_top/scl
add wave -noupdate /tst_bench_i2c_top/sda
add wave -noupdate /tst_bench_i2c_top/rstn
add wave -noupdate /tst_bench_i2c_top/myslave/i2c_start
add wave -noupdate /tst_bench_i2c_top/myslave/i2c_stop
add wave -noupdate /tst_bench_i2c_top/myslave/sda_out_en
add wave -noupdate /tst_bench_i2c_top/myslave/i2c_state
add wave -noupdate /tst_bench_i2c_top/myslave/sda_state
add wave -noupdate /tst_bench_i2c_top/myslave/sda_out
add wave -noupdate /tst_bench_i2c_top/myslave/device_addr_match
add wave -noupdate /tst_bench_i2c_top/myslave/in_data
add wave -noupdate /tst_bench_i2c_top/myslave/indat_done
add wave -noupdate /tst_bench_i2c_top/myslave/send_done
add wave -noupdate /tst_bench_i2c_top/myslave/sram_cs
add wave -noupdate /tst_bench_i2c_top/myslave/sram_rw
add wave -noupdate /tst_bench_i2c_top/myslave/reg_address
add wave -noupdate /tst_bench_i2c_top/myRAM_0/DATA
add wave -noupdate /tst_bench_i2c_top/addr2
add wave -noupdate /tst_bench_i2c_top/RW2
add wave -noupdate /tst_bench_i2c_top/EN2
add wave -noupdate /tst_bench_i2c_top/in2
add wave -noupdate /tst_bench_i2c_top/out2
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
