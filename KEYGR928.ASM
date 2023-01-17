;TITLE CUSTOM CHARACTER SET KEYBOARD DRIVER

;   Copyright 1992 ANGELOS KARAGEORGIOU 

;   update by Spiros Ioannou, http://www.softlab.ntua.gr/~sivann on (Nov/2000).
;   Changes by sivann:
;   * it now uses the ELOT-928 (iso8859-7) encoding instead of memotek's 437gr (737)
;   * support for accented diaeresis, capitals with diaeresis and the middle dot (Shift+w)
;   * fixed 1-2 minor bugs which prevented it to run with the above changes
;   Many thanks to Angelos for the sources, I found them on www.unix.gr (!). 
;   

;-------------------------------------------------------------------
;KEEP IN MIND THAT THIS PROGRAM HAS TO BE ASSEMBLED AS A COM FILE SO
;IT CAN PERFORM ACCORDING TO ITS SPECIFICATIONS WITH EXE2BIN
;-------------------------------------------------------------------


;------------------------
;MASM PSEUDO EQUIVALENCES
;------------------------

HOTKEY                  EQU     0C1FH	; CONTROL "-"
HOTKEY2					EQU		7800h	; Alt+1

DOS_IO				    EQU     09H
DOS_FUN				    EQU     21H
DOS_TERM			    EQU     27H
GET_VECTOR			    EQU     35H
SET_VECTOR				EQU     25H
INTERRUPT_NUMBER        EQU     9

stresskey               equ     ';'     ; accent
umlautkey               equ     ':'     ; diaeresis
BIG                     EQU     86
SMALLCASE               EQU     118
CONTROL                 EQU     22
ALT                     EQU     0
        ideal
        MODEL small


segment ROM_BIOS_DATA  AT 40H  ;BIOS statuses held here, also keyboard buffer
        org     17h
        status  db	 ?
        ORG     1AH
        HEAD DW      ?		                 ;Unread chars go from [ES:HEAD] to [ES:TAIL]
        TAIL DW      ?
        BUFFER       DW      16 DUP (?)      ;The buffer itself
        LABEL BUFFER_END   WORD
ENDS

CODESEG
segment code public 'code'
        ORG     100H						  ;ORG = 100H to make this into a .COM file
        assume cs:code,es:code,ds:rom_bios_data


FIRST:  JMP CS:LOAD_PROG					  ;First time through jump to initialize routine

        label OLD_KEY_INT    DWORD
        OLD_KEYBOARD_INT        DD      ?     ;Location of old kbd interrupt
;------------------------------------------------------------
;FOLLOWING VARIABLES ARE USED BY THE GREEKTRANSLATE PROCEDURE
;-------------------------------------------------------------
        TOGGLE_FLAG     DB        0
        STRESS_FLAG     DB        0
        UMLAUT_FLAG     DB        0

;---------------------------------------------------------------------------
;THE FOLLOWING TABLE IS A SUBSET OF ASCII THAT REMAPS A STANDARD CHARACTER
;TO ITS NEW VALUE.FAST EFFICIENT AND ONLY 128 BYTES WIDE.CHARACTERS THAT
;WERE NOT SUPPOSED TO BE REMAPPED HAVE THEIR OLD VALUES SO THAT WE CAN AVOID
;RECKING HAVOC TO THE MACHINE BY ALTERING THE SPECIAL CONTROL CHARACTERS
;---------------------------------------------------------------------------

GREEK_TABLE     DB        0       ;-------------------------
                DB        1       ;DON'T YOU DARE TOUCH THE
                DB        2       ;SPECIAL CHARACTERS
                DB        3       ;-------------------------
                DB        4
                DB        5
                DB        6
                DB        7
                DB        8
                DB        9
                DB       10
                DB       11
                DB       12
                DB       13
                DB       14
                DB       15
                DB       16
                DB       17
                DB       18
                DB       19
                DB       20
                DB       21
                DB       22
                DB       23
                DB       24
                DB       25
                DB       26
                DB       27
                DB       28
                DB       29
                DB       30
                DB       31
                DB       32
                DB       33
                DB       34
                DB       35
                DB       36
                DB       37
                DB       38
                DB       39
                DB       40
                DB       41
                DB       42
                DB       43
                DB       44
                DB       45
                DB       46
                DB       47
                DB       48
                DB       49
                DB       50
                DB       51
                DB       52
                DB       53
                DB       54
                DB       55
                DB       56
                DB       57
                DB       58
                DB       59
                DB       60
                DB       61
                DB       62       ;---------------
                DB       63       ;CAPITAL LETTERS
                DB       64       ;---------------

				DB      193 ;128       ;A
                DB      194 ;129       ;B
                DB      216 ;150       ;C
                DB      196 ;131       ;D
                DB      197 ;132       ;E
                DB      214 ;148       ;F
                DB      195 ;130       ;G
                DB      199 ;134       ;H
                DB      201 ;136       ;I
                DB      206 ;141       ;J
                DB      202 ;137       ;K
                DB      203 ;138       ;L
                DB      204 ;139       ;M
                DB      205 ;140       ;N
                DB      207 ;142       ;O
                DB      208 ;143       ;P
                DB      ':'			   ;Q
                DB      209 ;144       ;R
                DB      211 ;145       ;S
                DB      212 ;146       ;T
                DB      200 ;135       ;U
                DB      217 ;151       ;V
                DB      183	;anw teleia;W 
                DB      215 ;149       ;X
                DB      213 ;147       ;Y
                DB      198 ;133       ;Z

				DB       91
                DB       92
                DB       93
                DB       94        ;------------------
                DB       95        ;SMALL CASE LETTERS
                DB       96        ;------------------

                DB      225 ;152        ;A
                DB      226 ;153        ;B
                DB      248 ;175        ;C
                DB      228 ;155        ;D
                DB      229 ;156        ;E
                DB      246 ;173        ;F
                DB      227 ;154        ;G
                DB      231 ;158        ;H
                DB      233 ;160        ;I
                DB      238 ;165        ;J
                DB      234 ;161        ;K
                DB      235 ;162        ;L
                DB      236 ;163        ;M
                DB      237 ;164        ;N
                DB      239 ;166        ;O
                DB      240 ;167        ;P
                DB      ';'				;Q
                DB      241 ;168        ;R
                DB      243 ;169        ;S
                DB      244 ;171        ;T
                DB      232 ;159        ;U
                DB      249 ;224        ;V
                DB      242 ;170        ;W
                DB      247 ;174        ;X
                DB      245 ;172        ;Y
                DB      230 ;157        ;Z


                DB      123
                DB      124
                DB      125
                DB      126
                DB      127


GREEK_STRESS_TABLE DB     0          ;-------------------------
                DB        1          ;DON'T YOU DARE TOUCH THE
                DB        2          ;SPECIAL CHARACTERS
                DB        3          ;-------------------------
                DB        4
                DB        5
                DB        6
                DB        7
                DB        8
                DB        9
                DB       10
                DB       11
                DB       12
                DB       13
                DB       14
                DB       15
                DB       16
                DB       17
                DB       18
                DB       19
                DB       20
                DB       21
                DB       22
                DB       23
                DB       24
                DB       25
                DB       26
                DB       27
                DB       28
                DB       29
                DB       30
                DB       31
                DB       32
                DB       33
                DB       34
                DB       35
                DB       36
                DB       37
                DB       38
                DB       39
                DB       40
                DB       41
                DB       42
                DB       43
                DB       44
                DB       45
                DB       46
                DB       47
                DB       48
                DB       49
                DB       50
                DB       51
                DB       52
                DB       53
                DB       54
                DB       55
                DB       56
                DB       57
                DB       58
                DB       59
                DB       60
                DB       61
                DB       62       ;---------------
                DB       63       ;CAPITAL LETTERS (tonoumena-accented)
                DB       64       ;---------------

				DB      182			   ;A
                DB      194 ;129       ;B
                DB      216 ;150       ;C
                DB      196 ;131       ;D
                DB      184			   ;E
                DB      214 ;148       ;F
                DB      195 ;130       ;G
                DB      185			   ;H
                DB      186			   ;I
                DB      206 ;141       ;J
                DB      202 ;137       ;K
                DB      203 ;138       ;L
                DB      204 ;139       ;M
                DB      205 ;140       ;N
                DB      188			   ;O
                DB      208 ;143       ;P
                DB      ':'			   ;Q
                DB      209 ;144       ;R
                DB      211 ;145       ;S
                DB      212 ;146       ;T
                DB      245 ;159       ;U
                DB      191		       ;V
                DB      211		       ;W
                DB      215 ;149       ;X
                DB      190			   ;Y
                DB      198 ;133       ;Z

                DB       91
                DB       92
                DB       93
                DB       94        ;------------------
                DB       95        ;SMALL CASE LETTERS accented
                DB       96        ;------------------

                DB      220       ;A
                DB      226 ;153        ;B
                DB      248 ;175        ;C
                DB      228 ;155        ;D
                DB      221        ;E
                DB      246 ;173        ;F
                DB      227 ;154        ;G
                DB      222        ;H
                DB      223        ;I
                DB      238 ;165        ;J
                DB      234 ;161        ;K
                DB      235 ;162        ;L
                DB      236 ;163        ;M
                DB      237 ;164        ;N
                DB      252        ;O
                DB      240 ;167        ;P
                DB      ';'				;Q
                DB      241 ;168        ;R
                DB      243 ;169        ;S
                DB      244 ;171        ;T
                DB      232 ;159        ;U
                DB      254        ;V
                DB      242 ;170        ;W
                DB      247 ;174        ;X
                DB      253        ;Y
                DB      230 ;157        ;Z

                DB      123
                DB      124
                DB      125
                DB      126
                DB      127


PROC   prog                  ;The keyboard interrupt will now come here.
        PUSH    AX           ;Save the used registers for good form
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        PUSH    DS
        PUSH    ES
        assume cs:code
;        CMP [cs:KBACT],1               ;HAVE WE BEEN ACTIVATED PREVIOUSLY?
;        JNE XYZB                       ;NOPE CONTINUE
;        JMP near cs:EXIT               ;YEP GET OUT OF HERE
;xyzb:

        mov bx,cs
        mov es,bx
        assume es:code
;        mov [cs:kbact],1

        mov al,020h
        out 020h,al

        in al,060h
;        xor ah,ah


        STI							;ENABLE ALL OTHER INTERRUPTS
        PUSHF						;First, call old keyboard interrupt
        CALL    [OLD_KEYBOARD_INT]

                ;-------------------------------------------------
                ;now go into the keyboard buffer and get some data
                ;-------------------------------------------------
readrom:
        ASSUME  dS:ROM_BIOS_DATA        ;Examine the char just put in
        MOV     BX,ROM_BIOS_DATA
        MOV     dS,BX
        MOV     BX,[TAIL]               ;Point to current [ES:TAIL]
        CMP     BX,[HEAD]               ;If at [ES:HEAD], kbd int has deleted char
        JNE     GOPETE
        JMP near cs:EXIT                ;So leave
GOPETE:
        SUB     BX,2                    ;Point to just read in character
        CMP     BX,OFFSET BUFFER        ;Did we undershoot buffer?
        JAE     NO_WRAP                 ;Nope
        MOV     BX,OFFSET BUFFER_END    ;Yes -- move to buffer top
        SUB     BX,2                    ;Point to just read in character 
NO_WRAP:MOV     AX,[BX]                 ;Char in DX now

         CMP AX,hotkey                  ;IS IT OUR TOGGLE KEY COMBINATION?
         JE  TOGGLE_SET                 ;GO TO THE TOGGLING FUNCTION

		 cmp ax,hotkey2					;or this?
		 je TOGGLE_SET

         CMP AL,stresskey               ;IS IT OUR STRESS KEY COMBINATION?
         JE  STRESS_SET                 ;YES
         CMP AL,umlautkey               ;IS IT OUR UMLAUT KEY COMBINATION?
         JE  UMLAUT_SET                 ;YES
         JMP near cs:NORMAL             ;NONE OF THE ABOVE JUST TRANSLATE
TOGGLE_SET:
         CMP [TOGGLE_FLAG],0            ;READ JUST OUR TOGGLE STATUS
         JE  ZERO
         MOV [TOGGLE_FLAG],0
         MOV [TAIL],BX                  ;NO ECHO PLEASE
         JMP near cs:EXIT               ;GET READY FOR NEXT CHARACTER
 ZERO:
         MOV [TOGGLE_FLAG],1
         MOV [TAIL],BX                  ;NO ECHO PLEASE
         JMP near cs:EXIT               ;GET READY FOR NEXT CHARACTER
STRESS_SET:
         CMP [TOGGLE_FLAG],1
         JE  STRESS_CONT
         JMP near cs:EXIT
STRESS_CONT:
         CMP [STRESS_FLAG],1              ;IS THE FLAG ALREADY SET?
         JnE  ST_CONT
         MOV AL,stresskey                 ;SEND A STRESS
         MOV [BX],AX
         MOV [STRESS_FLAG],0              ;RESET THE FLAG
         JMP near cs:EXIT
ST_CONT:
         MOV [STRESS_FLAG],1              ;SET THE STRESS FLAG ON
         MOV [TAIL],BX                    ;SET NO ECHO
         JMP near cs:EXIT                 ;GET OUT OF HERE
UMLAUT_SET:
         CMP [TOGGLE_FLAG],1
         JE  UMLAUT_CONT
         JMP near cs:EXIT
UMLAUT_CONT:
         CMP [UMLAUT_FLAG],1              ;IS THE FLAG ALREADY ON?
         JnE UM_CONT
         MOV AL,umlautkey                 ;SEND an UMLAUT
         MOV [BX],AX
         MOV [UMLAUT_FLAG],0              ;RESET THE FLAG
         JMP near cs:EXIT
UM_CONT:
         MOV [UMLAUT_FLAG],1              ;SET THE UMLAUT FLAG ON
         MOV [TAIL],BX                    ;NO ECHO PLEASE
         JMP near cs:EXIT                 ;BYE

NORMAL:  CMP [TOGGLE_FLAG],0              ;ARE WE TOGGLED ON?
         JNE NOR                          ;YES
         JMP near cs:EXIT                 ;NO  GET OUT
NOR:     CMP [STRESS_FLAG],1              ;IS THE STRESS FLAG ON?
         JnE mornor
         JMP near cs:STRESS
mornor:
         CMP [UMLAUT_FLAG],1              ;OR IS THE UMLAUT FLAG ON?
         JnE  moUMLAUT
         JMP near cs:umlaut
moumlaut:
        cmp ah,0
        jne notzero                     ; is it an ALT COMBO ?
        jmp exit
notzero:
        cmp al,0                        ;is it a special key ?
        jne notzero1
        jmp exit
notzero1:
        cmp ah,47                       ;will it cause translation problems?
        jne notv1                       ;nop
        mov ah,0                        ;yep make it look like an ALT combo
notv1:
         MOV cX,AX                      ;CONTINUE BY ADJUSTING SI
         MOV cH,0
         MOV SI,cX
         CMP SI,128                     ;ARE WE ABOVE 128?
         JL  CONTY                      ;YES, NO TRANSLATION REQUIRED
         JMP EXIT
CONTY:   
		 MOV AL,[byte GREEK_TABLE+SI]   ;NO, TRANSLATE CHARACTER AND LEAVE
         
		 JMP putchar

UMLAUT:  MOV [UMLAUT_FLAG],0            ;RESET THE UMLAUT FLAG
         CMP [STRESS_FLAG],1            ;DOUBLE CHECK AGAIN PLEASE
         JnE  neither
         JMP near cs:BOTH
neither:
         CMP AL,'i'
         JE  UIOTA
		 CMP AL,'I'
         JE  UIOTA_CAP
         CMP AL,'y'
         JE  UYPSILON
		 CMP AL,'Y'
		 JE UYPSILON_CAP
         MOV AL,':'                     ;NONE OF THE ABOVE print ":"
         JMP near cs:putchar
UIOTA:   
		MOV AL,250 ;228		            ;GREEK SMALL LETTER IOTA WITH DIAERESIS
        JMP near cs:putchar
UIOTA_CAP:   
		MOV AL,218		                ;GREEK CAPITAL LETTER IOTA WITH DIAERESIS
        JMP near cs:putchar
UYPSILON:
		MOV AL,251						;GREEK SMALL LETTER UPSILON WITH DIAERESIS
        JMP near cs:putchar
UYPSILON_CAP:
		MOV AL,219	;232				;GREEK CAPITAL LETTER UPSILON WITH DIAERESIS
        JMP near cs:putchar


STRESS:  MOV [STRESS_FLAG],0            ;RESET THE STRESS FLAG
         CMP [UMLAUT_FLAG],1            ;IS THE UMLAUT FLAG ON ALSO?
         JnE  neither2
         JMP near cs:BOTH               ;DO THE DOUBLE
neither2:
        jne notzeros                    ;is it an ALT COMBO ?
        jmp exit
notzeros:
        cmp al,0                        ;is it a special key ?
        jne notzeros1
        jmp exit
notzeros1:
        cmp ah,47                       ;will it cause translation problems?
        jne notvs1                      ;nop
        mov ah,0                        ;yep make it look like an ALT combo
notvs1:
         MOV cX,AX                      ;CONTINUE BY ADJUSTING SI
         MOV cH,0
         MOV SI,cX
         CMP SI,128                     ;ARE WE ABOVE 128?
         JL  CONTYs                     ;YES, NO TRANSLATION REQUIRED
         JMP EXIT
CONTYs:  
		 MOV AL,[GREEK_STRESS_TABLE+SI] ;NO, TRANSLATE CHARACTER AND LEAVE
         JMP putchar


BOTH:    MOV [UMLAUT_FLAG],0            ;RESET THE UMLAUT FLAG (accented diaeresis)
         MOV [STRESS_FLAG],0            ;RESET THE STRESS FLAG
         CMP AL,'i'
         JE  BIOTA
         CMP AL,'y'
         JE  BYPSILON
         MOV [tAIL],BX                  ;NONE OF THE ABOVE
         JMP near cs:EXIT               ;GET OUT
BIOTA:   MOV AL,192						;GREEK SMALL LETTER IOTA WITH DIAERESIS AND ACCENT
         JMP near cs:putchar
BYPSILON:
         MOV AL,224						;GREEK SMALL LETTER UPSILON WITH DIAERESIS AND ACCENT
         JMP near cs:PUTCHAR

         JMP near cs:exit


putchar:
		mov ah,0		; Added by Spiros. Vre to atimo, to vrika.
		mov [bx],ax
        
EXIT:   CLI
;        mov [kbact],0
        POP     ES      ;Having done Pushes, here are the Pops
        POP     DS
        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX     
        IRET            ;An interrupt needs an IRET
ENDP


LOAD_PROG:                   ;This procedure intializes everything

JMP near MORE

; DATA NOT NEEDED DURING TSR OPERATION

crlf            db      10,13,'$'
Myname          db      'Copyright Angelos Karageorgiou','$'
company 		db		' (C) 1992 X.M.A.K. SYSTEMS INTERNATIONAL',10,13,'$'
MYTITLE         DB      'Greek / English Keyboard Driver ',10,13,'$'
MOREINFO        DB      'ISO8859-7 (ELOT-928), accented diaeresis, capital w/diaeresis and',10,13,'$'
MOREINFO1       DB      'middle dot (shift+w) support by Spiros Ioannou sivann@cs.ntua.gr, 2000',10,13,'$'
LOADED          DB      'ALREADY LOADED',10,13,'$'
GREETING        DB      10,13,'Use CONTROL "-" or Alt+1 to switch between English and Greek',10,13,'$'

;isname          db      'Bohfmpt!Lbsbhfpshjpv',10,13,'$'
;horror1         db      10,13,10,13,'           THIEF',10,13,10,13,10,13,10,13,'$'
;horror2         db      '           HACK',10,13,10,13,10,13,10,13,'$'
;horror3         db      '           MY PROGRAM',10,13,10,13,10,13,10,13,'$'
;horror4         db      '           You are doomed',10,13,10,13,10,13,10,13,'$'


MORE:   

		MOV     BX,CS
        MOV     DS,BX

        MOV DX,OFFSET crlf                   ;GIVE 'EM SOME TITLE
        MOV AH,09H
        INT 21H

		MOV DX,OFFSET MYTITLE                ;GIVE 'EM SOME TITLE
        MOV AH,09H
        INT 21H

        MOV DX,OFFSET MYNAME                 ;GIVE 'EM SOME NAME
        MOV AH,09H
        INT 21H

        MOV DX,OFFSET company                ;GIVE 'EM SOME NAME
        MOV AH,09H
        INT 21H

		MOV DX,OFFSET moreinfo                ;928 info
        MOV AH,09H
        INT 21H
		MOV DX,OFFSET moreinfo1               ;928 info
        MOV AH,09H
        INT 21H


        CLD                                  ;SEE IF WE ARE ALREADY LOADED
        MOV     CX,0
        MOV     ES,CX
        mov     cx,cs
        mov     ds,cx
        MOV     DI,0024H
        LES     DI,[ES:DI]
        MOV     SI,OFFSET PROG
        MOV     CX,40h                          ;HOW MANY CHARACTERS TO LOOK FOR
        REPE    CMPSB                           ;COMPARE THE STRINGS
        JE      GOOD_EXIT                       ;ALREADY LOADED

;		JMP		AFTERCHECK
;
;;see if anyone has fooled with our names
;        mov cx,cs
;        mov es,cx
;        assume es:code
;        mov ds,cx
;        assume ds:code
;        mov cx,20
;        mov bx,offset isname
;here:   dec [byte bx]           ;convert encrypted name to real
;        inc bx
;        loop here
;								 ;name is now decrypted
;        mov cx,20
;        cld
;        mov si,offset myname
;	  	 add si,10
;        mov di,offset isname
;        repe cmpsb
;        jne gohorror
;
;AFTERCHECK:

        MOV DX,OFFSET GREETING                  ;GIVE 'EM SOME ADVICE
        MOV AH,09H
        INT 21H


        MOV     AH,35H					;Get old vector into ES:BX
        MOV     AL,INTERRUPT_NUMBER     ;See EQU at beginning
        INT     21H

        mov     si,offset old_key_int
        MOV     [si],BX					;Store old interrupt vector
        MOV     [si + 2],ES

        MOV     AH,25H					;Set new interrupt vector
        mov     DX,offset PROG
        INT     21H

        MOV     DX,OFFSET LOAD_PROG     ;Set up everything but LOAD_PROG to
        INT     27H                     ;stay and attach itself to DOS

GOOD_EXIT:

        MOV DX,OFFSET LOADED                   ;GIVE 'EM SOME STUFF
        MOV AH,09H
        INT 21H

        MOV AH,4CH                             ;KILL ME
        INT 21h

;gohorror:
;
;        MOV DX,OFFSET Horror1                   ;GIVE 'EM SOME STUFF
;        MOV AH,09H
;        INT 21H
;        MOV DX,OFFSET Horror2                   ;GIVE 'EM SOME STUFF
;        MOV AH,09H
;        INT 21H
;        MOV DX,OFFSET Horror3                   ;GIVE 'EM SOME STUFF
;        MOV AH,09H
;        INT 21H
;
;       MOV DX,OFFSET Horror4                   ;GIVE 'EM SOME STUFF
;       MOV AH,09H
;       INT 21H
;
;        int 19h

ends
        END     FIRST			 ;END "FIRST" so 80x86 will go to FIRST first.
