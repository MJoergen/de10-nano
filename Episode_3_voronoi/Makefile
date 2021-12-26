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
	rm -rf voronoi.ghw
	rm -rf work-obj93.cf


SRC += hdmi_sync.vhd
SRC += voronoi/min_vector.vhd
SRC += voronoi/min_vector_staged.vhd
SRC += voronoi/dist.vhd
SRC += voronoi/minmax.vhd
SRC += voronoi/move.vhd
SRC += voronoi/rms.vhd
SRC += voronoi/voronoi.vhd
SRC += tb.vhd


sim:
	ghdl -i $(SRC)
	ghdl -m -frelaxed tb
	ghdl -r -frelaxed tb --wave=voronoi.ghw --stop-time=20us
	gtkwave voronoi.ghw voronoi.gtkw

