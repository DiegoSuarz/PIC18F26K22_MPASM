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

;DEFINIR LAS VARIABLES:	
  
	CBLOCK	0x00			;QUE EMPIECE EN LA PRIMERA DIRECCION DE LA MEMORIA RAM
	;VARIABLES PARA EL MANEJO DE INTERRUPCIONES
	;W_TEMP
	;STATUS_TEMP
	;BSR_TEMP
	
	;VARIABLES PARA EJECUCION DEL PROGRAMA
	DUTY
	ENDC
;VALORES DEFINIDOS:

;*************************ZONA DE CODIGOS*******************************************************************************************
 
;|ETIQUETAS | MNEMÓNICO	| OPERANDOS	    |COMENTARIOS

	    ORG		0x000		    ; ORIGEN INICIO RESET
	    GOTO	INICIO		    ; ME VOY A INICIO
;;DESCOMENTAR SI SE USA INTERRUPCIONES
;	    ORG		0x008		    ; ORIGEN ISR ALTA PRIORIDAD
;	    GOTO	ALTA_PRIORIDAD
;	    ORG		0x018		    ; ORIGEN ISR BAJA PRIORIDAD
;	    GOTO	BAJA_PRIORIDAD	    
;BAJA_PRIORIDAD
;	    MOVWF	W_TEMP		    ; MUEVO EL ULTIMA VALOR DE W 
;	    MOVFF	STATUS,STATUS_TEMP  ; DE STATUS Y DE BSR
;	    MOVFF	BSR,BSR_TEMP	    ; PARA RESTAURARLOS AL VALOR ANTES DE LA INTERRUPCION
;FIN_INTER
;	    MOVWF	W_TEMP		    ; MUEVO EL ULTIMA VALOR DE W 
;	    MOVFF	STATUS,STATUS_TEMP  ; DE STATUS Y DE BSR
;	    MOVFF	BSR,BSR_TEMP	    ; PARA RESTAURARLOS AL VALOR ANTES DE LA INTERRUPCION
;	    RETURN			    ; REGRESO DE INTERRUPCION
;ALTA_PRIORIDAD
;	    GOTO	FIN_INTER	    ; VE A FINAL DE INTERRUPCION
	
;*********************************************************************************
;**************************CONFIGURACIÓN DE PUERTOS ******************************
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
	;CONFIGURAR GPIO
	    
	    CLRF	TRISB
	;CONFIGURACION PARA ADC
	    MOVLB	0xF		    ;ACCEDEMOS AL BANCO 15
	    BSF		ANSELA,ANSA0	    ;CONFIGURAMOS LA ENTRADA ANALAGICA AN0
	    MOVLB	0X0		    ;ACCEDEMOS AL BANCO 0	
	    BSF		TRISA,0		    ;PIN RA0 COMO ENTRADA ANALOGICA
	    
	    MOVLW	B'00111110'	    ;JUSTIFICADO A LA IZQUIERDA,TIEMPO DE ADQUISICION 20 TAD, CLOCL DE CONVERSION FOSC/64
	    MOVWF	ADCON2		    ;CARGO EL VALOR EN EL REGISTRO
	    MOVLW	B'00001111'	    
	    MOVWF	ADCON1		    ;REFERENCIA VDD-VSS
	    
	;CONFIGURACIÓN PWM: PARA EL FUNCIONAMIENTO SE NECESITA UN TEMPORIZADOR,
	;EN ESTE CASO USAREMOS EL TMR2
	    BSF		TRISC,2		    ;PIN RC2 CCP1 MODO PWM
	    
	    BCF		CCPTMRS0,0	    ;SELECCION DEL TIMER 2, PARA MODULO PWM
	    BCF		CCPTMRS0,1
	    
	    MOVLW	0X63		    
	    MOVWF	PR2		    ;PERIODO DEL PWM, PARA UNA FRECUENCIA DE 10KHZ, CON PREESCALER DE 16
	    
	    MOVLW	B'00001100'
	    MOVWF	CCP1CON		    ;CONFIGURAR MODULO CCP, EN MODO PWM
	    
	    CLRF	CCPR1L		    ;CARGAR EL DUTY CYCLE CON 0
	    
	    MOVLW	B'00000111'
	    MOVWF	T2CON		    ;ENCENDER EL TMR2 CON UN PRESCALER DE 16
	    
	    BCF		PIR1,TMR2IF	    ;LIMPIAR LA BANDERA DE INTERRUPCION DEL TMR2
	    
	    BCF		TRISC,2		    ;HABILITAR LA SALIDA PWM DEL MODULO CCP1 (RC2)
	    
;**********************************LOOP***********************************************	    
	    CLRF	DUTY
	    
PRINCIPAL
	    CALL	ADC_CONFIG
	    CALL	ADC_CONVERSION	    ;EMPEZAR CONVERSION CANAL AN0
	    MOVFF	DUTY,CCPR1L	    ;CARGAR EL DUTY CYCLE CON EL VALOR DEL ADC
	    MOVFF	DUTY,LATB	    ;MOVER EL VALOR DEL DUTY CYCLE HACIA EL PUERTO B
	    CALL	RET_100MS		    ;GENERAR UN RETARDO DE 1 MS
	    GOTO	PRINCIPAL	    ;VUELVE AL LOOP PRINCIPAL
	    
;**********************************SUBRUTINAS******************************************** 
	    
ADC_CONFIG
	    MOVLW	B'00000001'	    ;SELECCIONAMOS CANAL ANALOGICO 0 Y HABILITAMOS LA CONVERSION
	    MOVWF	ADCON0		    
	    BSF		ADCON0,ADON	    ;HABILITAR ADC
	    BSF		ADCON0,GO	    ;INICIAR CONVERSION
	    
ADC_CONVERSION
	    BTFSC	ADCON0,GO	    ;ESPERAR A QUE ACABE LA CONVERSION
	    GOTO	ADC_CONVERSION	    ;BUCLE PARA SONDEAR EL BIT GO//DONE
	    
	    MOVFF	ADRESH,DUTY	    ;MUEVO LA PARTE ALTA DE LA CONVERSION A LA REGISTRO DE LA RAM DUTY
;	    MOVFF	ADRESL,RESULTADO_L  ;MUEVO LA PARTE BAJA DE LA CONVERSION A LA VARIABLE RESULTADO_L
	    RETURN
	    
#include "MY_RETARDOS.inc"
	    
	    END