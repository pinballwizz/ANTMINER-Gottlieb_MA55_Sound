Gottlieb MA55 Soundboard for the ANTMINER S9 FPGA Board.

Notes:
Controls are PS2 keyboard Keys=QWERTYUIOPASDFG (for testing)
To modify for adding to pinball machine, edit Vivado Constraints file to remove keyboard and associate header pins with sound inputs.
Ensure vhdl top level code is also modified accordingly for adding ANTMINER to your pinball.
Ensure that any inputs to ANTMINER Board are either ground or 3.3v dc max (low or high logic levels for zynq7010 fpga).
Preferred Sound Input code should set inputs with internal pullups in Constraints file and active signals should be ground (logic low).
Consult the Schematics Folder for Information regarding peripheral connections.

Build:
* Obtain Gottlieb Sound roms, see make sound proms script in tools folder for rom filenames.
* Unzip rom files to tools folder.
* Run the make sound proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the Gottlieb_MA55 project file using Vivado and compile.
* Program ANTMINER S9 Board.
