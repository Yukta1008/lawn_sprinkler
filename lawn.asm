#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#



#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#


; add your code here
         jmp     st1 
         nop
         dw      0000
         dw      0000
         dw      ad_isr
         dw      0000
		 db     1012 dup(0)
         sens1 dw 0
         sens2 dw 0
         sens3 dw 0
         sens4 dw 0
         sens5 dw 0
         sens6 dw 0
         sens7 dw 0
         sens8 dw 0
         sens9 dw 0
         sens10 dw 0
         sens11 dw 0
         sens12 dw 0
         avg db 0
         req db 0
         run db 0
         run2 db 0
         run3 db 0
         run4 db 0
         run5 db 0
         run6 db 0
         currhr db 0
         var1 db 0
         avgrow1 db 0
         avgrow2 db 0
         avgrow3 db 0
         avgrow4 db 0
         avgrow5 db 0
         avgrow6 db 0
         valc db 0
         wlvl dw 0


          
st1:      cli 
; intialize ds, es,ss to start of RAM
          mov       ax,0200h
          mov       ds,ax
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFFEH 
;______________________________

;INITIALIZING MODES

;8255 #1 creg initialize
mov		al, 10010000b ;(a as input, b as output, c as output)
out 	06h, al

;8255 #2 creg initialize
mov		al, 10010010b ;(a as input, b as input, c as output)
out 	0eh, al

check50: ;Master Switch Check
in al, 10h
and al, 01h
cmp al, 00000001b
jnz check50

;take input from user to decide req value
            mov al, 00000100b ;Select Lines
            out 0ch, al    
        
            ;Set ale 1  
            mov       al,00100100b
	        out       0ch,al      
	
            ;set soc 1  
            mov		al,00110100b
	        out		0ch,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010100b
	        out       0ch,al   
	
             ;make soc  0
	        mov       al,00000100b
	        out       0ch,al     
    

            ;Reading PB2 of Port B
            ;Checking EOC
        
            pr17:  
            in al, 0ah
            mov bl, al
            and bl, 00000100b 
            cmp bl, 00000100b 
            jne pr17
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001100b ;Making OE 1
            out 0ch, al  

            in al, 08h 
            mov ah, 00h
            mov req,al;MOVE AL VALUE TO DATA LOCATION (Storing Data)
    ;========================================================================================




;timer - mode 2 -
mov       al,00110100b
out       1eh,al
mov       al,01110100b
out       1eh,al

;1st Counter Count Load
mov al, 0e8h ; 1000 in decimal
out 18h, al
mov al, 03h
out 18h, al

;2nd Counter Count Load
mov al, 09h ; 9 in decimal
out 1ah, al
mov al,00h
out 1ah, al


mov run, 00h 
mov run2, 00h;for checking existing and remain ON function
mov run3, 00h 
mov run4, 00h 
mov run5, 00h 
mov run6, 00h 

mov currhr, 00h
mov var1, 00h
mov avgrow1, 00h
mov avgrow2, 00h
mov avgrow3, 00h
mov avgrow4, 00h
mov avgrow5, 00h
mov avgrow6, 00h

mov wlvl, 00h


mov al, 00h
out 14h, al

mov valc, 00h
		 
x2:       jmp       x2  

ad_isr:  
    
    ;Water Procedure Starts
      
    ;Increment Current Hour Count
    inc currhr

    ;Compare with 11*(60/time interval) | 18*(60/time interval)
    cmp currhr, 1d
    je checkhr ; branch to procedure that sets variable
    cmp currhr, 10d
    je checkhr ; branch to procedure that sets variable
    jne abc
    checkhr:    mov var1, 1d ;update var value
    abc: 

    ;Compare CurrHr with 96
    cmp currhr, 96d
    jne abcd
    mov currhr, 00d

    abcd: 

    ;Compare Variable with 1 to trigger Watering Procedure

    cmp var1, 1d
    jne endisr


        ;Taking Water Sensor Input from ADC
            mov al, 00000101b
            out 0ch, al    
        
            ;Set ale 1  
            mov       al,00100101b
	        out       0ch,al      
	
            ;set soc 1  
            mov		al,00110101b
	        out		0ch,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010101b
	        out       0ch,al   
	
             ;make soc  0
	        mov       al,00000101b
	        out       0ch,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr0:  
            in al, 0ah
            mov bl, al
            and bl, 00000100b 
            cmp bl, 00000100b 
            jne pr0
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001101b ;Making OE 1
            out 0ch, al  

            in al, 08h 
            mov ah, 00h
            mov wlvl, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)


        ;break
            ;
        ;Taking 1st Input from ADC
            mov al, 00000000b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100000b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110000b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010000b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000000b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr1:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr1
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001000b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens1, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

        ;Taking 2nd Input from ADC
            ;
            mov al, 00000001b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100001b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110001b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010001b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000001b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr2:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr2 
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001001b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens2, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

            
            
        ;Taking 3rd Input from ADC
            ;
            mov al, 00000010b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100010b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110010b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010010b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000010b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr3:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr3 
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001010b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens3, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)
            

        ;Taking 4th Input from ADC
            ;
            mov al, 00000011b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100011b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110011b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010011b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000011b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr4:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr4 
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001011b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens4, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

        ;Taking 5th Input from ADC
            ;
            mov al, 00000100b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100100b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110100b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010100b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000100b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr5:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr5 
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001100b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens5, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

        ;Taking 6th Input from ADC
            ;
            mov al, 00000101b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100101b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110101b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010101b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000101b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr6:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr6 
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001101b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens6, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

        ;Taking 7th Input from ADC
            ;
            mov al, 00000110b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100110b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110110b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010110b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000110b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr7:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr7
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001110b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens7, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

        ;Taking 8th Input from ADC
            ;
            mov al, 00000111b
            out 04h, al    
        
            ;Set ale 1  
            mov       al,00100111b
	        out       04h,al      
	
            ;set soc 1  
            mov		al,00110111b
	        out		04h,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010111b
	        out       04h,al   
	
             ;make soc  0
	        mov       al,00000111b
	        out       04h,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr8:  
            in al, 0ah
            mov bl, al
            and bl, 00000010b 
            cmp bl, 00000010b
            jne pr8
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001111b ;Making OE 1
            out 04h, al  

            in al, 00h 
            mov ah, 00h
            mov sens8, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)
        
        ;Taking 9th Input from ADC
            mov al, 00000000b
            out 0ch, al    
        
            ;Set ale 1  
            mov       al,00100000b
	        out       0ch,al      
	
            ;set soc 1  
            mov		al,00110000b
	        out		0ch,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010000b
	        out       0ch,al   
	
             ;make soc  0
	        mov       al,00000000b
	        out       0ch,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr9:  
            in al, 0ah
            mov bl, al
            and bl, 00000100b 
            cmp bl, 00000100b 
            jne pr9
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001000b ;Making OE 1
            out 0ch, al  

            in al, 08h 
            mov ah, 00h
            mov sens9, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)
        
        ;Taking 10th Input from ADC
            mov al, 00000001b
            out 0ch, al    
        
            ;Set ale 1  
            mov       al,00100001b
	        out       0ch,al      
	
            ;set soc 1  
            mov		al,00110001b
	        out		0ch,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010001b
	        out       0ch,al   
	
             ;make soc  0
	        mov       al,00000001b
	        out       0ch,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr10:  
            in al, 0ah
            mov bl, al
            and bl, 00000100b  
            cmp bl, 00000100b 
            jne pr10
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001001b ;Making OE 1
            out 0ch, al  

            in al, 08h 
            mov ah, 00h
            mov sens10, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)
        
        ;Taking 11th Input from ADC
            mov al, 00000010b
            out 0ch, al    
        
            ;Set ale 1  
            mov       al,00100010b
	        out       0ch,al      
	
            ;set soc 1  
            mov		al,00110010b
	        out		0ch,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010010b
	        out       0ch,al   
	
             ;make soc  0
	        mov       al,00000010b
	        out       0ch,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr11:  
            in al, 0ah
            mov bl, al
            and bl, 00000100b 
            cmp bl, 00000100b 
            jne pr11
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001010b ;Making OE 1
            out 0ch, al  

            in al, 08h 
            mov ah, 00h
            mov sens11, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)

        ;Taking 12th Input from ADC
            mov al, 00000011b
            out 0ch, al    
        
            ;Set ale 1  
            mov       al,00100011b
	        out       0ch,al      
	
            ;set soc 1  
            mov		al,00110011b
	        out		0ch,al  
	
	        nop
	        nop
	        nop
	        nop

             ;make ale 0 
	        mov       al,00010011b
	        out       0ch,al   
	
             ;make soc  0
	        mov       al,00000011b
	        out       0ch,al     
    

            ;Reading PB0 of Port B
            ;Checking EOC
        
            pr12:  
            in al, 0ah
            mov bl, al
            and bl, 00000100b  
            cmp bl, 00000100b 
            jne pr12
            ;If EOC == 1, Then OE --> 1 and We read & store data from data lines of ADC to PORT A of 8255

            mov al, 00001011b ;Making OE 1
            out 0ch, al  

            in al, 08h 
            mov ah, 00h
            mov sens12, ax ;MOVE AL VALUE TO DATA LOCATION (Storing Data)
        
        
        
        ;Averaging
            
            ;Row 1
            mov ax, sens1
            add ax, sens2
            mov cl, 02h
			div cl
            mov ah, 00h
			mov avgrow1, al
            mov ax, 00h

           ;Row 2
            mov ax, sens3
            add ax, sens4
            mov cl, 02h
			div cl
            mov ah, 00h
			mov avgrow2, al
            mov ax, 00h

            ;Row 3
            mov ax, sens5
            add ax, sens6
            mov cl, 02h
			div cl
            mov ah, 00h
			mov avgrow3, al
            mov ax, 00h

            ;Row 4
            mov ax, sens7
            add ax, sens8
            mov cl, 02h
			div cl
            mov ah, 00h
			mov avgrow4, al
            mov ax, 00h

            ;Row5
            mov ax, sens9
            add ax, sens10
            mov cl, 02h
			div cl
            mov ah, 00h
			mov avgrow5, al
            mov ax, 00h

            ;Row 6
            mov ax, sens11
            add ax, sens12
            mov cl, 02h
			div cl
            mov ah, 00h
			mov avgrow6, al
            mov ax, 00h

		;Comparing Row 1 with Required Value
			mov al, avgrow1
			cmp al, req
            ja checkr11 ;Check 1 of Row 1


            ;Valves ON
            cmp run, 0          ;just decides all (Backflow, Master, Row Wise) ON simulateneously or sequentially
            jz checkr12 
            jmp checkr13


            checkr12: ;SWITCH ON SEQUENTIALLY
                    mov run, 01h ;Update run ;Signifise non first time for valves ON

                    mov al, valc ;backflow ON
                    or al,00000011b
			        out 02h, al ;Made to 02h from 14h
                    mov valc,al ;Update Valc

                    mov al,valc
			        or al, 00000100b ;Specific Row 1 ON 
                    out 02h, al ;Made to 02h fom 14h
                    mov valc, al ;UPDATE VALC

                    jmp row2


            checkr13:
                    cmp run, 1
                    jz checkr14
                    jmp row2

            checkr14: ;switching ON what was already ON before
                    mov al, valc ;Load that variable into al
                    out 02h, al ;Made to 02h fom 14h

                    jmp row2

            checkr11: ;Since moisture level > Required level --> Shut Specific Port
          
                mov al, valc
                and al, 11111011b ;made pc2 of valc 0
                mov valc, al ;Update Valc

                mov al, valc ;Output to Port C
			    out 02h, al ;Made to 02h fom 14h

        ;end of row 1 check 

        ;comparing Row 2 with Required Value
            row2: 
            mov al, avgrow2
			cmp al, req
            ja checkr21 ;Check 1 of Row 1


            ;Valves ON
            cmp run2, 0          ;just decides all (Backflow, Master, Row Wise) ON simulateneously or sequentially
            jz checkr22 
            jmp checkr23


            checkr22: ;SWITCH ON SEQUENTIALLY
                    mov run2, 01h ;Update run ;Signifise non first time for valves ON

                    mov al,valc
                    or al, 00000011b ;backflow & Master ON
			        out 02h, al ;Made to 02h from 14h
                    mov valc,al ;Update Valc

			        mov al, valc ;Specific Row 1 ON using apparent BSR Mode
                    or al, 00001000b
                    out 02h, al ;Made to 02h from 14h
                    mov valc, al ;UPDATE VALC

                    jmp row3


            checkr23:
                    cmp run2, 1
                    jz checkr24
                    jmp row3

            checkr24: ;switching ON what was already ON before
                    mov al, valc ;Load that variable into al
                    out 02h, al ;Made to 02h from 14h

                    jmp row3

            checkr21: ;Since moisture level > Required level --> Shut Specific Port
                mov al, valc
                and al, 11110111b ;made pc2 of valc 0
                mov valc, al ;Update Valc

                mov al, valc ;Output to Port C
			    out 02h, al  ;Made to 02h from 14h
		;end of row 2 check 

        ;comparing Row 3 with Required Value
            row3: 
            mov al, avgrow3
			cmp al, req
            ja checkr31 ;Check 1 of Row 1


            ;Valves ON
            cmp run3, 0          ;just decides all (Backflow, Master, Row Wise) ON simulateneously or sequentially
            jz checkr32 
            jmp checkr33


            checkr32: ;SWITCH ON SEQUENTIALLY
                    mov run3, 01h ;Update run ;Signifise non first time for valves ON

                    mov al,valc
                    or al, 00000011b ;backflow ON
			        out 02h, al ;Made to 02h from 14h
                    mov valc,al ;update Valce

			        mov al, valc ;Specific Row 1 ON using BSR Mode
                    or al, 00010000b
                    out 02h, al ;Made to 02h from 14h
                    mov valc, al ;UPDATE VALC

                    jmp row4


            checkr33:
                    cmp run3, 1
                    jz checkr34
                    jmp row4

            checkr34: ;switching ON what was already ON before
                    mov al, valc ;Load that variable into al
                    out 02h, al ;Made to 02h from 14h
                
                    jmp row4

            checkr31: ;Since moisture level > Required level --> Shut Specific Port
                mov al, valc
                and al, 11101111b ;made pc2 of valc 0
                mov valc, al ;Update Valc

                mov al, valc ;Output to Port C 
			    out 02h, al ;;Made to 02h from 14h
		;end of row 3 check 

        ;comparing Row 4 with Required Value
            row4: 
            mov al, avgrow4
			cmp al, req
            ja checkr41 ;Check 1 of Row 1


            ;Valves ON
            cmp run4, 0          ;just decides all (Backflow, Master, Row Wise) ON simulateneously or sequentially
            jz checkr42 
            jmp checkr43


            checkr42: ;SWITCH ON SEQUENTIALLY
                    mov run4, 01h ;Update run ;Signifise non first time for valves ON

                    mov al,valc
                    or al, 00000011b ;backflow ON
			        out 02h, al ;Made to 02h from 14h
                    mov valc,al

			        mov al, valc ;Specific Row 1 ON using BSR Mode
                    or al, 00100000b
                    out 02h, al ;Made to 02h from 14h
                    mov valc, al ;UPDATE VALC

                    jmp row5
            checkr43:
                    cmp run4, 1
                    jz checkr44
                    jmp row5

            checkr44: ;switching ON what was already ON before
                    mov al, valc ;;Load that variable into al
                    out 02h, al ;Made to 02h from 14h

                    jmp row5

            checkr41: ;Since moisture level > Required level --> Shut Specific Port
          
                mov al, valc
                and al, 11011111b ;made pc2 of valc 0
                mov valc, al ;Update Valc

                mov al, valc ;Output to Port C
			    out 02h, al ;Made to 02h from 14h
		
        
        ;end of row 4 check 

        ;comparing Row 5 with Required Value
            row5: 
            mov al, avgrow5
			cmp al, req
            ja checkr51 ;Check 1 of Row 1


            ;Valves ON
            cmp run5, 0          ;just decides all (Backflow, Master, Row Wise) ON simulateneously or sequentially
            jz checkr52 
            jmp checkr53


            checkr52: ;SWITCH ON SEQUENTIALLY
            mov run5, 01h ;Update run ;Signifise non first time for valves ON

            mov al,valc
            or al, 00000011b ;backflow ON
			out 02h, al ;Made to 02h from 14h
            mov valc,al

			mov al, valc ;Specific Row 1 ON using BSR Mode
            or al, 01000000b
            out 02h, al ;Made to 02h from 14h
            mov valc, al ;UPDATE VALC

            jmp row6

            checkr53:
                cmp run5, 1
                jz checkr54
                jmp row6

            checkr54: ;switching ON what was already ON before
                mov al, valc ;;Load that variable into al
                out 02h, al ;Made to 02h from 14h

                jmp row5

            checkr51: ;Since moisture level > Required level --> Shut Specific Port
          
                mov al, valc
                and al, 10111111b ;made pc2 of valc 0
                mov valc, al ;Update Valc

                mov al, valc ;Output to Port C 
			    out 02h, al ;Made to 02h from 14h

		;end of row 5 check 

        ;comparing Row 6 with Required Value
            row6: 
            mov al, avgrow6
			cmp al, req
            ja checkr61 ;Check 1 of Row 1


            ;Valves ON
            cmp run6, 0          ;just decides all (Backflow, Master, Row Wise) ON simulateneously or sequentially
            jz checkr62 
            jmp checkr63


            checkr62: ;SWITCH ON SEQUENTIALLY
            mov run6, 01h ;Update run ;Signifise non first time for valves ON

            mov al,valc
            or al, 00000011b ;backflow ON
			out 02h, al ;Made to 02h from 14h
            mov valc,al

			mov al, valc ;Specific Row 1 ON using BSR Mode
            or al, 10000000b
            out 02h, al ;Made to 02h from 14h
            mov valc, al ;UPDATE VALC

            jmp rowe


            checkr63:
                cmp run6, 1
                jz checkr64
                jmp rowe

            checkr64: ;switching ON what was already ON before
                mov al, valc ;;Load that variable into al
                out 02h, al ;Made to 02h from 14h

                jmp rowe

            checkr61: ;Since moisture level > Required level --> Shut Specific Port
          
                mov al, valc
                and al, 01111111b ;made pc2 of valc 0
                mov valc, al ;Update Valc

                mov al, valc ;Output to Port C
			    out 02h, al ;Made to 02h from 14h

		;end of row 6 check 

        rowe:

        ;Checking Master Switch
           
            check51:

            in al, 0ah
            and al, 01h
            cmp al, 00000000b
            jz check52
            jmp check53

            check52:
            mov al, 00000000b
			out 02h, al ;Made to 02h from 14h

            mov run, 00h
			
            jmp check51

            check53:

        endisr:


            ;for updating var1, run, backflow and master
            mov al, valc
            cmp al, 00000011b ;backflow and master are ON
            je check1
            
            jmp endisr1:
            
            check1: 
            mov al, 00h
            out 02h, al  ;Switching OFF backflow and master ;;Made to 02h from 14h
            mov valc, 00h

            mov var1, 00h   
            mov run, 00h
            mov run2, 00h
            mov run3, 00h
            mov run4, 00h
            mov run5, 00h
            mov run6, 00h


        endisr1:

			iret