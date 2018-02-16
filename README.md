# Logic analyzer
Design of a logic analyzer for the course "Digital integrated systems" held by Prof. Massimo Ruo Roch in the year 2017/2018 at [Politecnico di Torino](www.polito.it).

The project consists of an 8-channel logic analyzer, which samples data from the inputs (detecting glitches) at a user-settable frequency, stores them in memory, and sends them to the PC (via UART interface) when the user inputs a read command.

The entire design was implemented in behavioral VHDL and tested on a Terasic DE2 board, equipped with an Altera Cyclone II FPGA.
