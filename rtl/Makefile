.phony: test dlatch rx_DS_SE

test:	rx_DS_SE rx_DS_char rx_top

rx_DS_SE:
	iverilog rx_DS_SE_tb.v rx_DS_SE.v
	vvp -n a.out

rx_DS_char:
	iverilog rx_DS_char_tb.v rx_DS_char.v
	vvp -n a.out

# Debug/development only
rx_top:
	iverilog rx_top_tb.v rx_top.v rx_DS_char.v rx_DS_SE.v
	vvp -n a.out

