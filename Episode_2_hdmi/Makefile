PROJECT = top

all:
	quartus_sh --flow compile $(PROJECT)

program:
	quartus_pgm -m jtag -o p\;build/top.sof@2

clean:
	rm -rf build/
	rm -rf db/
	rm -rf incremental_db/
	rm -rf $(PROJECT).qpf
	rm -rf c5_pin_model_dump.txt
