# PICOTALK
An alternative talk application for CP/M
This app works with the SC126, SC130, SC131 Z180 computers running CP/M.

This app does not convert the HEX data to ASCII which can cause the terminal to ignore and just print values for terminal ESCAPE control codes, so it is ideal for connecting microcontrollers such as the Raspberry Pi PICO running MicroPython with its REPL command line interface.

This app allows full duplex communication between UART0 to UART1 and UART1 to UART0 so the READ and WRITE data registers are accessed directly.

To run:

Type PICO at the command line.

To exit the app:

Type CTRL-Z
