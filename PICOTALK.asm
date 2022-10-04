; PICOTALK - Written by Nicholas Tate 29/09/2022

stksiz		EQU 		40h           	; Working stack size
restart 	EQU      	0000h           ; CP/M restart vector
bdos            EQU         	0005h           ; BDOS invocation vector
iobyte  	EQU           	0003h           ; IOBYTE address
stack           EQU           	01DCh          	; Stack top
statA           EQU           	0C4h            ; UART A status
statB           EQU           	0C5h            ; UART B status
rxA             EQU             0C8h            ; UART A read data
txA             EQU             0C6h            ; UART B write data
rxB             EQU             0C9h            ; Uart B read data
txB             EQU             0C7h            ; Uart B write data

             	ORG          	0100h
main:
                ld          	(stksav),sp  	; Save stack

            	ld             	sp,(stack)   	; Set new stack
            	call            init            ; Initialization
                jr           	nz,exit 	; Abort if init fails
            	ld          	de,msghello     ; Display startup message
              	call            prtstr  	; Print it
                ld              a,0Ah           ; Carriage return
                call            prtchar 	; Print it
                ld              a,0Ah           ; Carriage return
             	call            prtchar 	; Print it
                push            af
                push            de
             	di                              ; Disable interrupts
              	call            talk            ; Do serial comms on UC1
             	ei                              ; Enable interrupts
                pop    		de
                pop             af

exit:   	; Clean up and return to command processor
              	ld          	sp,(stksav)  	; Restore stack
                ret                             ; Return to CP/M

init:           
		ld             	hl,(restart+1)  ; Load addr of CP/M
						; restart vector
             	ld            	de,-3           ; Adjustment for start of table
               	add           	hl,de           ; HL now has start of table
            	ld              (cbftbl),hl    	; save it
                                		; Return success
              	xor        	a
              	ret

prtchar:   	; Print a character in register 'A'
        	push            bc
              	push            de
             	push            hl
           	ld            	e,a
             	ld             	c,02h		; BDOS function to output a
            	call            bdos		; character
           	pop       	hl
            	pop        	de
           	pop        	bc
               	ret

prtstr: 	; Print a string terminated with dollar
           	push            bc
          	push            de
          	push            hl
           	ld          	c,09h        	; BDOS function to output a
              	call            bdos            ; string
          	pop         	hl
     		pop         	de
          	pop        	bc
             	ret

talk:           ; Do serial comms on UC1
             	call            asciRXA
            	cp       	1Ah         	; Check for CTRL-Z
          	ret          	z              	; Exit talk routine if true
           	call            asciRXB
           	jr       	talk            ;

asciRXA:
        	in0       	a,(statA) 	; Read UART status
        	bit        	7,a         	; Received data?
              	jr        	z,skip1 	; Skip if no data
          	in0        	a,(rxA) 	; Read in data if ready
       		ld        	d,a      	; Save to 'D' register
        	call            asciTXB 	;
skip1:
               	ret

asciTXB:
              	in0       	a,(statB) 	; Read UART status
            	bit         	1,a            	;
        	jr         	z,asciTXB    	; Ready to send?
           	ld        	a,d         	; byte to send in 'D'
           	out0            (txB),a 	; Send data
               	ret

asciRXB:
           	in0           	a,(statB)      	; Read UART status
       		bit         	7,a            	; Received data?
              	jr           	z,skip2 	; Skip if no data
             	in0          	a,(rxB) 	; Read in data if ready
        	ld           	d,a           	; Save to 'D' register
               	call            asciTXA 	;
skip2:         	
		ret

asciTXA:
              	in0     	a,(statA)     	; Read UART status
           	bit        	1,a         	;
          	jr           	z,asciTXA    	; Ready to send?
         	ld           	a,d        	; Byte to send in 'D'
         	out0            (txA),a 	; Send data                                                                                      
             	ret

; Storage section

cbftbl: 	defw   		0h           	; Addr of CBIOS function table
stksav:         defw          	0              	; Stack pointer saved at start
msghello:      	defm          	'PICOTALK v1.0 connected to UC1$'

           	END
