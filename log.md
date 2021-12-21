# Log of activities with the DE10 Nano board

## 3. November 2020
I bought my DE10 Nano board directly from Terasic.  This was not without its problems:

* Delivery time took 2 weeks.
* There was an additional import tax of about $60!
* I needed a power supply (5V 2A DC with a 5.5 mm jack) with a Danish plug,
  rather than the American plug that came with the board. Price approx $15.
* I also needed a HDMI to DVI adaptor cable. Price approx $10.

After all that, everything is finally good, and I'm ready to power up the board!

### Documentation
Before I proceed, it's worth mentioning that I've downloaded a huge bunch of documentation:
* [DE10 Nano CD
  ROM](http://download.terasic.com/downloads/cd-rom/de10-nano/DE10-Nano_v.1.3.8_HWrevC_SystemCD.zip)
  from Terasic's home page. This is a great resource and includes manuals,
  schematics, and datasheets as well as several Verilog examples.

  For instance, the document `Manual/Learning_Roadmap.pdf` is a "Read Me First" document, and gives
  a suggested reading order:
  1. Quick Start Guide
  2. Getting Started Guide
  3. My First FPGA & User Manual (Chapter 5)
  4. My First HPS & User Manual (Chapter 6)
  5. QT Control Panel & User Manual (Chapter 7)
* [Cyclone V FPGA](https://www.intel.com/content/www/us/en/programmable/products/fpga/cyclone-series/cyclone-v/support.html)
  This is Intel's documentation of the Cyclone V FPGA that is at the heart of the DE10 Nano board.
  This site contains over 100 documents.
* [Quartus IDE](https://www.intel.com/content/www/us/en/programmable/products/design-software/fpga-design/quartus-prime/user-guides.html)
  This is Intel's documentation of the Quartus tool.


### First tests
So, I follow the Quick Start Guide:
* I connect the HDMI cable and power. And Hooray! A Linux kernel boots and then
  a GUI appears with a desktop where I'm presented with a dialog box: "Welcome
  to the first start of the panel". I'm not sure what that means right now.
* Then I connect the USB cable to my (Linux) host machine, and suddenly a new
  network drive appears (as well as a network connectin). Not much interesting
  on the drive; just a Windows driver and a single web page instructing to go
  to the address 192.168.7.1.
* The webpage hosted by the DE10 nano board is where all the fun is.

### What does the board contain
In the [schematic](https://www.intel.com/content/dam/develop/external/us/en/documents/de10-nano-schematic-711128.pdf) page 2 there is a nice block diagram of the DE10 Nano board.
It contains the following main I/O connectors:
* Micro SD Card
* Giga Ethernet
* USB Host (e.g. keyboard, etc),
* HDMI (via [ADV7513](https://www.analog.com/media/en/technical-documentation/data-sheets/ADV7513.pdf))
* LEDs, switches, and buttons
* UART to USB
Additionally, the board contains
* Cyclone V SoC FPGA including ARM HPS
* 1 GB DDR3 RAM
* Accelerometer
* Expansion ports for e.g. Arduino or SDRAM.

