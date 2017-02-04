.phony: test dlatch rx_DS_SE

test:	rx_DS_SE

rx_DS_SE:
	iverilog rx_DS_SE_tb.v rx_DS_SE.v
	vvp -n a.out
