# Episode 3: Voronoi pattern

In this episode we expand the HDMI video output to generate a [Voronoi
pattern](https://en.wikipedia.org/wiki/Voronoi_diagram).

## Clocking
First of all, we need to use a PLL to generate exact timing. Furthermore, since
I'm using a monitor with a 16x9 aspect ratio, I want a video resolution with
the same aspect ratio. So I choose a resolution of 1280x720 @ 60 Hz (see page
19 of CEA-861-D) This requires a pixel clock of exactly 74.25 MHz. So a PLL is
used to generate this clock.

This PLL (here name `pll_hdmi_video`) is generated using the Quartus GUI and
the GUI generates a bunch of files, only some of which are needed. The useful
files are `pll_hdmi_video.vhd`, `pll_hdmi_video.qip`, and the folder
`pll_hdmi_video/`

Furthermore, when using PLLs the constraint file `top.sdc` needs to be updated
with the command `derive_pll_clocks`. This is required by the Statis Timing
Analyzer that runs while the FPGA bitfile is generated.

The PLL is instantiated in the top level file `top.vhd` and replaces the simple
clock divider.

## Refactoring HDMI output
I've decided to completely refactor the HDMI output generation, because in the
previous episode the synchronization signals, pixel coordinates, and pixel color
generation were all mixed up. So instead, I now use a single file `hdmi_sync.vhd`
to generate all the synchronization signals and pixel counters.



I've made use of two push-buttons (KEY0 and KEY1). The first is used as
a overall reset, while the latter is used to pause the moving Voronoi pattern.



## Testing
To start the build simply type the command:

```
make
```

Once the build is finished, you can program the FPGA with the generated bitstream.
This is mosty easily done with the command:
```
make program
```

Then you should be able to connect the DE10 Nano board to a HDMI monitor and see
a beautiful (?) pattern on the screen!

