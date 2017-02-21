.phony: test dlatch rx_DS_SE

test:	receive_pipe transmit_pipe rx_top

receive_pipe: rx_DS_SE rx_DS_char queue_8x9
transmit_pipe: tx_DS_SE tx_DS_char

rx_DS_SE:
	iverilog rx_DS_SE_tb.v rx_DS_SE.v
	vvp -n a.out

rx_DS_char:
	iverilog rx_DS_char_tb.v rx_DS_char.v
	vvp -n a.out

queue_8x9:
	iverilog queue_8x9_tb.v queue_8x9.v
	vvp -n a.out

# Debug/development only
rx_top: rx_DS_SE rx_DS_char queue_8x9
	iverilog rx_top_tb.v rx_top.v rx_DS_char.v rx_DS_SE.v queue_8x9.v
	vvp -n a.out

tx_DS_SE:
	iverilog tx_DS_SE_tb.v tx_DS_SE.v
	vvp -n a.out

tx_DS_char:
	iverilog tx_DS_char_tb.v tx_DS_char.v
	vvp -n a.out
