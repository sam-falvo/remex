`define NTB(name,suffix)\
	`"name``_``suffix`"

`define DEFASSERT(name,msb,suffix)\
	task assert_``name``;\
	input [``msb``:0] expected;\
	begin\
		if(expected !== ``name``_``suffix``) begin\
			$display("@E %03X %s Expected %X, got %X", story_tb, `NTB(name,suffix), expected, ``name``_``suffix``);\
			$stop;\
		end\
	end\
	endtask

`define DEFASSERT0(name,suffix)\
	task assert_``name``;\
	input expected;\
	begin\
		if(expected !== ``name``_``suffix``) begin\
			$display("@E %03X %s Expected %X, got %X", story_tb, `NTB(name,suffix), expected, ``name``_``suffix``);\
			$stop;\
		end\
	end\
	endtask

