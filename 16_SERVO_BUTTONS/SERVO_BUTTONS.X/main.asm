;DESCRIPCION:
;	    CONFIGURAR Y UTILIZAR EL TMR0 PARA CONTROL DE SERVOS, ADEMAS AGREGAR BOTTONES
;	    PARA EL CONTROL DE LA POSICION DEL SERVOMOTOR
;ZONA DE DATOS ******************************************************************************************

    List p=18F26k22
#include "p18f26k22.inc"

; CONFIG1H
  CONFIG  FOSC = HSHP           ; Oscillator Selection bits (HS oscillator (medium power 4-16 MHz))
  CONFIG  PLLCFG = ON           ; 4X PLL Enable (Oscillator multiplied by 4)
  CONFIG  PRICLKEN = ON         ; Primary clock enable bit (Primary clock enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRTEN = OFF          ; Power-up Timer Enable bit (Power up timer disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 190            ; Brown Out Reset Voltage bits (VBOR set to 1.90 V nominal)
  
; CONFIG2H
  CONFIG  WDTEN = OFF            ; Watchdog Timer Enable bits (WDT is always enabled. SWDTEN bit has no effect)
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC1       ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as digital I/O on Reset)
  CONFIG  CCP3MX = PORTB5       ; P3A/CCP3 Mux bit (P3A/CCP3 input/output is multiplexed with RB5)
  CONFIG  HFOFST = ON           ; HFINTOSC Fast Start-up (HFINTOSC output and ready status are not delayed by the oscillator stable status)
  CONFIG  T3CMX = PORTC0        ; Timer3 Clock input mux bit (T3CKI is on RC0)
  CONFIG  P2BMX = PORTB5        ; ECCP2 B output mux bit (P2B is on RB5)
  CONFIG  MCLRE = EXTMCLR       ; MCLR Pin Enable bit (MCLR pin enabled, RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection Block 0 (Block 0 (000800-003FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection Block 1 (Block 1 (004000-007FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection Block 2 (Block 2 (008000-00BFFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection Block 3 (Block 3 (00C000-00FFFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection Block 0 (Block 0 (000800-003FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection Block 1 (Block 1 (004000-007FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection Block 2 (Block 2 (008000-00BFFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection Block 3 (Block 3 (00C000-00FFFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection Block 0 (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection Block 1 (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection Block 2 (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection Block 3 (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)

;ZONA DE DEFINICIONES**************************************************************************************
#DEFINE	  SERVO_A  LATB,0	;PIN DE CONTROL PINB0
  
;DEFINIR LAS VARIABLES:	
	CBLOCK	0x00			;QUE EMPIECE EN LA PRIMERA DIRECCION DE LA MEMORIA RAM
	W_TEMP
	STATUS_TEMP
	BSR_TEMP

	
	POSM				;POSICION MUESTRA
	POSICION_SERVO
	POS_S1
	ENDC
;VALORES DEFINIDOS:
MUESTRAS    EQU	    .15

;ZONA DE CODIGOS*******************************************************************************************
 
;|ETIQUETAS | MNEM�NICO	| OPERANDOS	    |COMENTARIOS

	    ORG		0x000		    ; ORIGEN INICIO RESET
	    GOTO	INICIO		    ; ME VOY A INICIO
	    ORG		0x008		    ; ORIGEN ISR ALTA PRIORIDAD
	    GOTO	ALTA_PRIORIDAD
	    ORG		0x018		    ; ORIGEN ISR BAJA PRIORIDAD
	    GOTO	BAJA_PRIORIDAD	    
BAJA_PRIORIDAD
	    MOVWF	W_TEMP		    ; MUEVO EL ULTIMA VALOR DE W 
	    MOVFF	STATUS,STATUS_TEMP  ; DE STATUS Y DE BSR
	    MOVFF	BSR,BSR_TEMP	    ; PARA RESTAURARLOS AL VALOR ANTES DE LA INTERRUPCION
FIN_INTER
	    MOVWF	W_TEMP		    ; MUEVO EL ULTIMA VALOR DE W 
	    MOVFF	STATUS,STATUS_TEMP  ; DE STATUS Y DE BSR
	    MOVFF	BSR,BSR_TEMP	    ; PARA RESTAURARLOS AL VALOR ANTES DE LA INTERRUPCION
	    RETURN			    ; REGRESO DE INTERRUPCION
ALTA_PRIORIDAD
	    GOTO	FIN_INTER	    ; VE A FINAL DE INTERRUPCION
	
;*********************************************************************************
;**************************CONFIGURACI�N DE PUERTOS ******************************
;*********************************************************************************
INICIO	
	    MOVLB 	0xF		    ; PARA ACCEDER CORRECTAMENTE
	    CLRF	ANSELA		    ; ANALOGICAS NECESARIAS Y LO
	    CLRF	ANSELB		    ; DEMAS COMO ENTRADAS Y SALIDAS
	    CLRF	ANSELC		    ; DIGITALES
	    MOVLB	0xF
	    CLRF	PORTA		    ; LIMPIO EL PUERTO A
	    CLRF	PORTB		    ; LIMPIO EL PUERTO B
	    CLRF	PORTC		    ; LIMPIO EL PUERTO C
	    MOVLB	0X0		    ; PARA ACCEDER CORRECTAMENTE	
	    CLRF	LATA		    ; LIMPIO LATCH A
	    CLRF	LATB		    ; LIMPIO LATCH B
	    CLRF	LATC		    ; LIMPIO LATCH C
	
	    CLRF	TRISA		    ; SALIDAS DIGITALES PUERTO A
	    CLRF	TRISB		    ; SALIDAS DIGITALES PUERTO B
	    CLRF	TRISC		    ; SALIDAS DIGITALES PUERTO C

	   	    
;*********************************************************************************
;**************************  ZONA DE CODIGO USUARIO  *****************************
;*********************************************************************************	
	    BSF		TRISA,0
	    BSF		TRISA,1
	    
	    BCF		TRISB,0
	    
	    CLRF	POS_S1
	    BCF		SERVO_A		    ;LIMPAR PIN RB0
	    MOVLW	MUESTRAS
	    MOVWF	POSM		    ;POSICION MUESTRA
	    
	    ;pasos del servo  1ms -> 180�
	    ;			x -> 1�    x =(1x10^-3 * 1�)/180� = 5.55x10^-6 -> 5.6us

	    ; 1ms es la se�al minima y se debe dividir en 180 pasos
	    
PRINCIPAL
	   
	    BTFSS	PORTA,0
	    GOTO	INC_POS1
	    BTFSS	PORTA,1
	    GOTO	DEC_POS1
	    
EJECUTA_SERVO1
	    MOVFF	POS_S1,POSICION_SERVO
	    BSF		SERVO_A
	    CALL	RET_1MS			    ;SERVO EMPIEZA EN LA POSICION 0 QUE CORRESPONTE A UN PULSO DE 1MS (YA QUE LA SE�AL COMPLETA ES DE 2 MILISEGUNDOS)

;RUTINA DE ENCENDIDO/APAGADO DURANTE EL SIGUIENTE MILI SEGUNDO PARA COMPLETAR LOS 2 MILISEGUNDOS
MOVIMIENTO_SERVO1
	    CALL	RET_SERVO		    ;RETARDO DE 5.5 uS QUE ES EL RETARDO PARA GENERAR 1� EN EL SERVO  
	    DECF	POSICION_SERVO,F
	    MOVF	POSICION_SERVO,W
	    SUBLW	.255
	    BTFSS	STATUS,Z
	    GOTO	MOVIMIENTO_SERVO1
	    BCF		SERVO_A
	    CLRF	POSICION_SERVO
	    MOVLW	.180
	    SUBWF	POS_S1,W
	    MOVWF	POSICION_SERVO
	    
COMPLEMENTO_SERVO1
	    CALL	RET_NOP
	    DECF	POSICION_SERVO,F
	    MOVF	POSICION_SERVO,W
	    SUBLW	.255
	    BTFSS	STATUS,Z
	    GOTO	COMPLEMENTO_SERVO1
;AQUI TERMINO LOS 2 MILI SEGUNDOS PARA PODER CONTROLAR EL SERVO, Y QUEDA 18MILISEGUNDO PARA COMPLETAR LOS 20MS QUE SE REQUIEREN PARA EL CONTROL DE SERVOMOTOR
	    CALL	RET_18MS
	    GOTO	PRINCIPAL

INC_POS1    
	    INCF	POS_S1,F
	    MOVF	POS_S1,W
	    XORLW	.181
	    BTFSS	STATUS,Z
	    GOTO	EJECUTA_SERVO1
	    MOVLW	.180
	    MOVWF	POS_S1
	    GOTO	EJECUTA_SERVO1
	    
DEC_POS1
	    DECF	POS_S1,F
	    MOVF	POS_S1,W
	    XORLW	.255
	    BTFSS	STATUS,Z
	    GOTO	EJECUTA_SERVO1
	    MOVLW	.0
	    MOVWF	POS_S1
	    GOTO	EJECUTA_SERVO1
	    
RET_NOP	    RETURN
	    
	    
	    
	    
;simpre se debe respetar que el tiempo minimo es 1ms y el tiempo maximo es de 2ms , se debe completar los 2 ms siempre	    
SERVO_0	    ;para que se mantenga en 45� de deba mandar un pulso de alto de 1.00ms y 1.00ms en bajo
	    BSF		SERVO_A
	    CALL	RET_1MS
	    BCF		SERVO_A
	    CALL	RET_1MS
	    RETURN
	    
SERVO_45    ;para que se mantenga en 45� de deba mandar un pulso de alto de 1.25ms y 0.75ms en bajo
	    BSF		SERVO_A
	    CALL	RET_1MS
	    CALL	RET_250US
	    BCF		SERVO_A
	    CALL	RET_500US
	    CALL	RET_250US
	    RETURN

SERVO_90    ;para que se mantenga en 90� de deba mandar un pulso de alto de 1.5ms y 0.5ms en bajo
	    BSF		SERVO_A
	    CALL	RET_1MS
	    CALL	RET_500US
	    BCF		SERVO_A
	    CALL	RET_500US
	    RETURN
	    
SERVO_135   ;para que se mantenga en 135� de deba mandar un pulso de alto de 1.75ms y 0.25ms en bajo
	    BSF		SERVO_A
	    CALL	RET_1MS
	    CALL	RET_500US
	    CALL	RET_250US
	    BCF		SERVO_A
	    CALL	RET_250US
	    RETURN
	    
SERVO_180   ;para que se mantenga en 180� de deba mandar un pulso de alto de 2ms y 0ms en bajo
	    BSF		SERVO_A
	    CALL	RET_1MS
	    CALL	RET_1MS
	    BCF		SERVO_A
	    RETURN

RET_SERVO   ;RETARDO DE 5.5 uS QUE ES EL RETARDO PARA GENERAR 1� EN EL SERVO
	    MOVLW	B'00000100'
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0XFF
	    MOVWF	TMR0H
	    MOVLW	0XFC
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO
	    
	    
	    
;FORMULA:
;    MODO 8 BITS: T=(4/FOSC)*[PREE]*[255-TMR0]
;    
;    MODO 8 BITS: T=(4/FOSC)*[PREE]*[65535-TMR0]
RET_100MS
	    MOVLW	B'00000100'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0X3C
	    MOVWF	TMR0H
	    MOVLW	0XB0
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO 
	    
RET_50MS
	    MOVLW	B'00000100'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0X9E
	    MOVWF	TMR0H
	    MOVLW	0X57
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO 
	    
RET_10MS
	    MOVLW	B'00000010'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0XB1
	    MOVWF	TMR0H
	    MOVLW	0XE0
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO


RET_1MS
	    
	    MOVLW	B'01000101'	    ;EMPEZAR DETENIDO, MODO 8 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:64
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF	    ;LIMPIAR BANDERA DE DESBORDAMIENTO DE TMR0
	    MOVLW	.4
	    MOVWF	TMR0		    ;CARGAR EL REGISTRO TMR0
	    BSF		T0CON,TMR0ON	    ;ENCENDER EL TEMPORIZADOR
	    GOTO	BUCLE_RETARDO
RET_5MS
	    MOVLW	B'00000000'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	.82
	    MOVWF	TMR0L
	    MOVLW	.99
	    MOVWF	TMR0H
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO
	    
RET_500US
	    MOVLW	B'00000100'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0XFF
	    MOVWF	TMR0H
	    MOVLW	0X05
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO
	    
RET_250US
	    MOVLW	B'00000100'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0XFF
	    MOVWF	TMR0H
	    MOVLW	0X82
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO
	    
RET_18MS
	    MOVLW	B'00000100'	    ;EMPEZAR DETENIDO, MODO 16 BITS, CLK INTERNO (FCY),PREE ASIGNADO; PRE= 1:2   
	    MOVWF	T0CON
	    BCF		INTCON,TMR0IF
	    MOVLW	0XDC
	    MOVWF	TMR0H
	    MOVLW	0XD7
	    MOVWF	TMR0L
	    BSF		T0CON,TMR0ON
	    GOTO	BUCLE_RETARDO
	    
BUCLE_RETARDO
	    BTFSS	INTCON,TMR0IF	    ;EL LA BANDERA SE PUSO A 1?
	    GOTO	BUCLE_RETARDO	    ;NO, QUEDATE EN UN BUCLE Y DETEN LA EJECUCION CODIGO
	    BCF		INTCON,TMR0IF	    ;SI, LIMPIAR LA BANDERA DE DESBORDAMIENTO TMR0
	    BCF		T0CON,TMR0ON	    ;APAGAR EL TEMPORIZADOR
	    RETURN
	    

	    
	    END