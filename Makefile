VERILOG_FILES = rtl/top2.v  rtl/VGA/VgaSyncGen.v  rtl/UART/rx_uart.v rtl/7seg/7seg.v rtl/7seg/BCDto7Seg.v rtl/7seg/BinToBCD.v

PCF_FILE = FPGA/blackice-mx.pcf

include blackicemx.mk
