;TITLE VGA function blocker for greek character set

                ;  Copyright  1992 ANGELOS KARAGEORGIOU 

;-------------------------------------------------------------------
;KEEP IN MIND THAT THIS PROGRAM HAS TO BE ASSEMBLED AS A COM FILE SO
;IT CAN PERFORM ACCORDING TO ITS SPECIFICATIONS WITH EXE2BIN
;-------------------------------------------------------------------


;------------------------
;MASM PSEUDO EQUIVALENCES
;------------------------


DOS_IO          EQU     10H
DOS_FUN         EQU     21H
DOS_TERM        EQU     27H
GET_VECTOR      EQU     35H
SET_VECTOR      EQU     25H
teenysize       equ     1536		; 256 x 6
tinysize        equ     1792		; 256 x 7
SMALLSIZE		EQU		0800H		; 8 X 256 = 2048 DEC
MEDSIZE			EQU		0E00H		;14 X 256 = 3548 DEC
BIGSIZE			EQU		1000H		;16 X 256 = 4096 DEC

IDEAL
model small
segment CSEG    WORD 'CSEG'
        ASSUME	CS:CSEG,DS:CSEG,ES:CSEG
        ORG     100H
START:  JMP     INITIALIZE              ;MAKE THE PROGRAM TSR

OLD_VGA_IO      DD		?               ;KEEP THE OLD INTERRUPT
;VGAACT          DB        0             ;THEY SPEEK FOR THEMSELVES
teenyfont       db      teenysize   dup (0)
tinyfont		db      tinysize    dup (0)
smallfont       db      SMALLSIZE   dup (0)
MEDFONT         DB      MEDSIZE     DUP (0)
bigfont         db      BIGSIZE     dup (0)

;------------------------------------------------------------------------------
;THIS IS THE MAIN ROUTINE. IT REMAPS INT 10H SO THAT ANY REQUEST TO THE VGA
;PASSES THROUGH IT.
;------------------------------------------------------------------------------

proc VGA_INTERCEPTOR    far
        PUSH    BP
        PUSH    ES
        PUSH    DS                      ;SAVE OLD VALUES
        PUSH    SI
        push    ax
        push    bx
        push    cx
        push    dx

        sti
        push	cs
        pop		ds
        assume	ds:cseg


;        cmp [cs:vgaact],1
;        jne contv
;        jmp exit

contv:
;        mov [cs:vgaact],1
        cmp ah,11h
        je contx1
        cmp ah,0
        je contx1
jumpold:
         cli
;         MOV [CS:VGAACT],0                 ;NOT ACTIVE ANYMORE
         assume		es:nothing
         assume		ds:nothing
         pop	dx
         pop    cx
         pop    bx
         pop    ax
         POP    SI                      ;RESTORE PREVIOUS VALUES
         POP    DS
         POP    ES
         POP    BP
        jmp		[old_vga_io]
contx1:

        CMP     AH,11h                  ;CHECK AH
        JE      KEY                     ;O.K. DO YOUR WORK
        CMP     AH,0                    ; MODE SET?
        JE      MODESET                 ; go to it

KEY:									;ENABLE ALL OTHER INTERRUPTS
CONT:   JMP		VGASETUP

MODESET:STI								;ENABLE ALL OTHER INTERRUPTS
	push AX
	pushf
        call [old_vga_io]
	POP AX

        and al,01111111b

        CMP AL,03H                      ;VIDEO MODES
        Jg  X1
        JMP DO8X16
X1:
        CMP AL,04H
        Jne  X2
        JMP DOcga
X2:
        CMP AL,05H
        Jne  X25
        JMP DOcga
X25:
        CMP AL,06H
        Jne  X26
        JMP DOcga
X26:
        CMP AL,07H
        JnE  X3
        JMP DO8X16
X3:

        CMP AL,0DH
        Jne X4
        JMP DOgr8x8
;        jmp docga
X4:

        CMP AL,0EH
        JnE  X5
        JMP DOgr8X8
;        jmp docga
X5:

        CMP AL,0FH
        JnE  X6
        JMP DOgr8X14
X6:

        CMP AL,10H
        JnE  X7
        JMP DOgr8X14
X7:

        CMP AL,11H
        JnE  X8
        JMP DOgr8X16
X8:

        CMP AL,12H
        JnE  X9
        JMP DOgr8X16
X9:
        CMP AL,13H
        JnE  X10
        JMP DOgr8X8
;        jmp docga
X10:
        cmp al,35
        jge xx10
        jmp dogr8x8
xx10:
;        jmp do8x14                     ;works with vesa BIOS
        cmp al,50
        jg	xx11
        jmp do8x14
xx11:
        cmp al,82
        jg xx12
        jmp do8x8
xx12:
        cmp al,85
        jge test90
        jmp exit
test90:
        cmp al,90
        jg xx13
        jmp dogr8x14
xx13:
        cmp al,96
        jg xx14
        jmp do8x14
xx14:
        cmp al,98
        jg xx15
        jmp dogr8x14
xx15:
        cmp al,103
        jge test105
        jmp exit
test105:
        cmp al,105
        jg xx16
        jmp dogr8x8
xx16:
        cmp al,109
        jl xx17
        jmp dogr8x14
xx17:
        jmp exit


VGASETUP:
        CMP AL,0H                     ;allow font upload only in graphics modes
        JnE x19
        CMP BH,6
        JG NOTT6
        JMP DO8X6
NOTT6:
        CMP BH,7
        JG NOTT7
        JMP DO8X7
NOTT7:
        CMP BH,8
        JG NOTT8
        JMP DO8X8
NOTT8:
        cmp bh,13
        jg nott13
        jmp do8x8
nott13:
        CMP BH,14
        JG NOTT14
        JMP DO8X14
NOTT14:
        cmp bh,15
        jg nott15
        jmp do8x14
nott15:
        jmp do8x16                        ;disallow any selection


x19:
        CMP AL,1H
        jne not1
        Jmp DO8X14
not1:
        CMP AL,2H
        JnE d0
        jmp DO8X8
d0:
        CMP  AL,03H                     ;SELECT ACTIVE CHARACTER SET
        JNE X04
	jmp DO8X16
X04:
        CMP AL,4H
        JnE x20
        jmp DO8X16
x20:
        CMP AL,10H
        JNE AL11
        CMP BH,6
        JG NOTTS6
        JMP DO8X6
NOTTS6:
        CMP BH,7
        JG NOTTS7
        JMP DO8X7
NOTTS7:
        CMP BH,8
        JG NOTTS8
        JMP DO8X8
NOTTS8:
        cmp bh,13
        jg notts13
        jmp do8x8
notts13:
        CMP BH,14
        JG NOTTS14
        JMP DO8X14
NOTTS14:
        cmp bh,15
        jg notts15
        jmp do8x14
notts15:
        JE DO8X16

AL11:
        CMP AL,11H
        jne notr14
        Jmp DO8X14
notr14:
        CMP AL,12H
        jne notr12
        Jmp  DO8X8
notr12:
        CMP AL,14H
        JNE X11
        JMP DO8X16
X11:
        CMP AL,20H
        JnE x011
        jmp DOCGA
x011:
        cmp al,21h
        jne x011x
        jmp exit                ;kill the sucker
        CMP CX,6
        JG NOTTG6
        JMP DOGR8X6
NOTTG6:
        CMP CX,7
        JG NOTTG7
        JMP DOGR8X7
NOTTG7:
        CMP CX,8
        JG NOTTG8
        JMP DOGR8X8
NOTTG8:
        cmp cx,13
        jg nottg13
        jmp dogr8x8
nottg13:
        CMP CX,14
        JG NOTTG14
        jmp dogr8x14
nottg14:
        cmp cx,15
        jg nottg15
        JMP DOGR8X14
nottg15:
        CMP CX,16
        JG NOTTG16
        JMP DOGR8X16
NOTTG16:                        ;WHAT THE HELL , LET HIM GO
x011x:
        cmp al,22h
        jne x012
        jmp dogr8x14
x012:
        cmp al,23h
        jne x013
        jmp dogr8x8
x013:
        cmp al,24h
        jne x014
        jmp dogr8x16
x014:
        jmp jumpold

DO8X16:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        ASSUME ES:CSEG                          ;TELL THE ASSEMBLER
												;ENABLE 8 X 16 FONT
        MOV BP,OFFSET BIGFONT                   ;BP SETUP
        MOV AH,11H                              ;FUNCTION
        MOV AL,10H                              ;LOAD FONT
        MOV CX,0FFH                             ;256 CHARACTERS
        MOV DX,0                                ;STARTING OFFSET
        MOV BH,16                               ;I SAID 8x '16'
        MOV BL,0                                ;DEFAULT GENERATOR
        PUSHF
	call [OLD_VGA_IO]
        JMP EXIT                                ;DO IT

DO8X14:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        ASSUME ES:CSEG

;ENABLE 8 X 14 FONT
        MOV BP,OFFSET medFONT                   ;BP SETUP
        MOV AH,11H                              ;FUNCTION
        MOV AL,10H                              ;LOAD FONT
        MOV CX,0FFH                             ;256 CHARACTERS
        MOV DX,0                                ;STARTING OFFSET
        MOV BH,14                               ;I SAID 8x '14'
        MOV BL,0                                ;DEFAULT GENERATOR
        PUSHF
        CALL [OLD_VGA_IO]
        JMP EXIT                                ;DO IT

DO8X8:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        ASSUME ES:CSEG

        MOV BP,OFFSET smallFONT                   ;BP SETUP
        MOV AH,11H                              ;FUNCTION
        MOV AL,10H                              ;LOAD FONT
        MOV CX,0FFH                             ;256 CHARACTERS
        MOV DX,0                                ;STARTING OFFSET
        MOV BH,8                               ;I SAID 8x '8'
        MOV BL,0                                ;DEFAULT GENERATOR
        PUSHF
        CALL [OLD_VGA_IO]
        JMP EXIT                                ;DO IT
DO8X7:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        ASSUME ES:CSEG

        MOV BP,OFFSET TINYFONT                   ;BP SETUP
        MOV AH,11H                              ;FUNCTION
        MOV AL,10H                              ;LOAD FONT
        MOV CX,0FFH                             ;256 CHARACTERS
        MOV DX,0                                ;STARTING OFFSET
        MOV BH,7                                ;I SAID 8x '7'
        MOV BL,0                                ;DEFAULT GENERATOR
        PUSHF
        CALL [OLD_VGA_IO]
        JMP EXIT                                ;DO IT
DO8X6:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        ASSUME ES:CSEG

        MOV BP,OFFSET TEENYFONT                 ;BP SETUP
        MOV AH,11H                              ;FUNCTION
        MOV AL,10H                              ;LOAD FONT
        MOV CX,0FFH                             ;256 CHARACTERS
        MOV DX,0                                ;STARTING OFFSET
        MOV BH,6                                ;I SAID 8x '6'
        MOV BL,0                                ;DEFAULT GENERATOR
        PUSHF
        CALL [OLD_VGA_IO]
        JMP EXIT                                ;DO IT

DOGR8X8:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        MOV BP,OFFSET SMALLFONT
        MOV AL,21H
        mov bl,0
        mov dl,25
        mov cx,8
        mov ah,11h
        PUSHF
        call [old_vga_io]
        jmp exit
DOGR8X6:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        MOV BP,OFFSET teenyFONT
        MOV AL,21H
        mov bl,0
        mov dl,25
        mov cx,6
        mov ah,11h
        PUSHF
        call [old_vga_io]
        jmp exit
DOGR8X7:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        MOV BP,OFFSET tinyFONT
        MOV AL,21H
        mov bl,0
        mov dl,25
        mov cx,7
        mov ah,11h
        PUSHF
        call [old_vga_io]
        jmp exit

DOGR8X14:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        MOV BP,OFFSET MEDFONT
        MOV AL,21H
        mov bl,0
        mov dl,25
        mov cx,14
        mov ah,11h
        PUSHF
        call [old_vga_io]
        jmp exit
DOGR8X16:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        MOV BP,OFFSET BIGFONT
        MOV AL,21H
        mov bl,0
        mov dl,25
        mov cx,16
        mov ah,11h
        PUSHF
        call [old_vga_io]
        jmp exit



DOCGA:
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        ASSUME ES:CSEG
        MOV AH,11H
        MOV AL,20H
        MOV BP,OFFSET SMALLFONT
        add bp,1024
        pushf
        CALL [OLD_VGA_IO]
        JMP EXIT


EXIT:    CLI                             ;disable interrupts while cleaning up
;         MOV [CS:VGAACT],0                 ;NOT ACTIVE ANYMORE
         pop     dx
         pop     cx
         pop     bx
         pop     ax
         POP     SI                      ;RESTORE PREVIOUS VALUES
         POP     DS
         POP     ES
         POP     BP
         IRET                            ;RETURN

ENDP            ;THAT'S ALL FOLKS


INITIALIZE:jmp xmore
        ;DATA UNWANTED DURING TSR
crlf            db      10,13,'$'
MYTITLE         DB      'Bilingual (Greek/English) VGA Driver/Blocker',10,13,'$'
LOADED          DB      'ALREADY LOADED',10,13,'$'
Myname			db		'Copyright Angelos Karageorgiou   (C) 1992 X.M.A.K. SYSTEMS INTERNATIONAL',10,13,'$'
TEENYFILE       DW      0
TINYFILE        DW      0
smallfile       dw      0
bigfile         dw      0
MEDFILE         DW      0
TEENYNAME       DB      'GR8X6.FNT',0
TINYNAME        DB      'GR8X7.FNT',0
;smallname       db      'gr8x8.fnt',0
smallname       db      '928-8x8.fnt',0
;bigname         db      'gr8x16.fnt',0
bigname         db      '928-8x16.fnt',0
MEDNAME         DB      'GR8X14.FNT',0
errors          db      'File not found',10,13,'SOMETHING.fnt is/are missing',10,13,'$'
errors1         db      'ERROR while reading the 8 x 8/7/6 font',10,13,'$'
errors3         db      'ERROR while reading the 8 x 16 font',10,13,'$'
errors4         db      'ERROR while reading the 8 x 14 font',10,13,'$'
isname          db      'Bohfmpt!Lbsbhfpshjpv',10,13,'$'
horror1         db      10,13,10,13,'           THIEF',10,13,10,13,10,13,10,13,'$'
horror2         db      '           HACK',10,13,10,13,10,13,10,13,'$'
horror3         db      '           MY PROGRAM',10,13,10,13,10,13,10,13,'$'
horror4         db      '           You are doomed',10,13,10,13,10,13,10,13,'$'

xmore:   MOV     BX,CS
         MOV     DS,BX
         ASSUME DS:CSEG

        MOV DX,OFFSET CRLF                   ;GIVE 'EM SOME TITLE
        MOV AH,09H
        INT 21H

        MOV DX,OFFSET MYTITLE                   ;GIVE 'EM SOME TITLE
        MOV AH,09H
        INT 21H


        MOV DX,OFFSET MYNAME                    ;GIVE 'EM SOME NAME
        MOV AH,09H
        INT 21H

        CLD                                     ;SEE IF WE ARE ALREADY LOADED
        MOV     CX,0
        MOV     ES,CX
        MOV     DI,040H                         ;WHERE INT10 IS
        LES     DI,[ES:DI]                      ;10 hex * 4
        MOV     SI,OFFSET VGA_INTERCEPTOR       ;WHERE THE LOCAL STRING IS
        MOV     CX,40                           ;HOW MANY CHARACTERS TO LOOK FOR
        REPE    CMPSB                           ;COMPARE THE STRINGS
        jne goon
        Jmp      GOOD_EXIT                       ;ALREADY LOADED
goon:
;     see if anyone has fooled with our names
        mov cx,cs
        mov es,cx
	assume es:cseg
        mov ds,cx
	assume ds:cseg
        mov cx,20
        mov bx,offset isname
here:   dec [byte bx]                           ;convert encrypted name to real
        inc bx
        loop here
                        ;    name is now decrypted
        mov cx,20
        cld
        mov si,offset myname
	add si,10
        mov di,offset isname
        repe cmpsb
	je keepgoing
	jmp gohorror

keepgoing:
                ;READ THE CONTENTS OF THE 8X6 FILE

        MOV DX,OFFSET teenyNAME                 ;THE 8X8 FILENAME
        MOV AH,03DH                             ;OPEN FILE
        MOV AL,0                                ;READ ONLY
        INT 21H                                 ;DOIT
        JnC nERROR                                ;IS THERE AN ERROR ?
        jmp error
nerror:
        MOV [teenyFILE],AX                      ;SAVE THE HANDLE

        MOV AH,3FH                              ;DOS READ FILE
        MOV BX,[teenyFILE]                      ;HANDLE SET UP
        MOV CX,teenySIZE                        ;READ 128 CHARS
        MOV DX,OFFSET teenyFONT                 ;WHERE TO SAVE THEM
        INT 21H
        JnC nERROR12
        jmp error1
nerror12:

        MOV BX,[teenyFILE]                      ;SMALL FILE 8X8 FONT
        MOV AH,03EH                             ;DOS CLOSE FILE
        INT 21H                                 ;DO IT

                ;READ THE CONTENTS OF THE 8X7 FILE
        MOV DX,OFFSET tinyNAME                 ;THE 8X8 FILENAME
        MOV AH,03DH                             ;OPEN FILE
        MOV AL,0                                ;READ ONLY
        INT 21H                                 ;DOIT
        JnC xnERROR                                ;IS THERE AN ERROR ?
        jmp error
xnerror:
        MOV [tinyFILE],AX                      ;SAVE THE HANDLE

        MOV AH,3FH                              ;DOS READ FILE
        MOV BX,[tinyFILE]                      ;HANDLE SET UP
        MOV CX,tinySIZE                        ;READ 128 CHARS
        MOV DX,OFFSET tinyFONT                 ;WHERE TO SAVE THEM
        INT 21H
        JnC xnERROR12
        jmp error1
xnerror12:

        MOV BX,[tinyFILE]                      ;SMALL FILE 8X8 FONT
        MOV AH,03EH                             ;DOS CLOSE FILE
        INT 21H                                 ;DO IT
                ;READ THE CONTENTS OF THE 8X8 FILE

        MOV DX,OFFSET SMALLNAME                 ;THE 8X8 FILENAME
        MOV AH,03DH                             ;OPEN FILE
        MOV AL,0                                ;READ ONLY
        INT 21H                                 ;DOIT
        JC ERROR                                ;IS THERE AN ERROR ?
        MOV [SMALLFILE],AX                      ;SAVE THE HANDLE

        MOV AH,3FH                              ;DOS READ FILE
        MOV BX,[SMALLFILE]                      ;HANDLE SET UP
        MOV CX,SMALLSIZE                        ;READ 128 CHARS
        MOV DX,OFFSET SMALLFONT                 ;WHERE TO SAVE THEM
        INT 21H
        JC ERROR1

        MOV BX,[SMALLFILE]                      ;SMALL FILE 8X8 FONT
        MOV AH,03EH                             ;DOS CLOSE FILE
        INT 21H                                 ;DO IT


        ; READ THE CONTENTS OF THE 8X16 FILE

        MOV DX,OFFSET BIGNAME                   ;THE 8X16 FILENAME
        MOV AH,03DH                             ;OPEN FILE
        MOV AL,0                                ;READ ONLY
        INT 21H                                 ;DOIT
        JC ERROR                                ;IS THERE AN ERROR ?
        MOV [BIGFILE],AX                        ;SAVE THE HANDLE

        MOV AH,3FH                              ;DOS READ FILE
        MOV BX,[BIGFILE]                        ;HANDLE SET UP
        MOV CX,BIGSIZE                            ;READ 256 CHARS
        MOV DX,OFFSET BIGFONT                   ;WHERE TO SAVE THEM
        INT 21H
        JC ERROR3

        MOV BX,[BIGFILE]                        ;BIG FILE 8X16 FONT
        MOV AH,03EH                             ;DOS CLOSE FILE
        INT 21H                                 ;DO IT


                ;READ THE CONTENTS OF THE 8 X 14 FILE
        MOV DX,OFFSET MEDNAME                   ;THE 8X14 FILENAME
        MOV AH,03DH                             ;OPEN FILE
        MOV AL,0                                ;READ ONLY
        INT 21H                                 ;DOIT
        JC ERROR                                ;IS THERE AN ERROR ?
        MOV [MEDFILE],AX                        ;SAVE THE HANDLE

        MOV AH,3FH                              ;DOS READ FILE
        MOV BX,[MEDFILE]                        ;HANDLE SET UP
        MOV CX,MEDSIZE                          ;READ 256 CHARS
        MOV DX,OFFSET MEDFONT                   ;WHERE TO SAVE THEM
        INT 21H
        JC ERROR2

        MOV BX,[MEDFILE]                        ;MED FILE 8X14 FONT
        MOV AH,03EH                             ;DOS CLOSE FILE
        INT 21H                                 ;DO IT
        JMP CONTINUE

ERROR:  MOV DX,OFFSET ERRORS                    ;GIVE 'EM SOME ERRORS
        MOV AH,09H
        INT 21H
        JMP PROGOUT

ERROR1: MOV DX,OFFSET ERRORS1                    ;GIVE 'EM SOME ERRORS
        MOV AH,09H
        INT 21H
        JMP PROGOUT

ERROR2: MOV DX,OFFSET ERRORS4                    ;GIVE 'EM SOME ERRORS
        MOV AH,09H
        INT 21H
        JMP PROGOUT

ERROR3: MOV DX,OFFSET ERRORS3                    ;GIVE 'EM SOME ERRORS
        MOV AH,09H
        INT 21H
        JMP PROGOUT


CONTINUE:
        ; O.K. EVERYTHING IS HERE

        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        assume es:cseg
                ;ENABLE 8 X 16 FONT
        MOV BP,OFFSET BIGFONT                   ;BP SETUP
        MOV AH,11H                              ;FUNCTION
        MOV AL,10H                              ;LOAD FONT
        MOV CX,0FFH                             ;256 CHARACTERS
        MOV DX,0                                ;STARTING OFFSET
        MOV BH,16                               ;I SAID 8x '16'
        MOV BL,0                                ;DEFAULT GENERATOR
        INT 10H                                 ;DO IT
;                ; MAKE THE 8X16 FONT TO DISPLAY
;        MOV AH,11H                              ;VGA INT
;        MOV AL,03H                              ;SELECT GENERATOR
;        MOV BL,0                                ;WHICH ONE
;        INT 10H                                 ;DO IT
                ; MAKE THE 8X8 FONT VISIBLE UNDER INT 1FH
        MOV AX,CS                               ;ES SETUP
        MOV ES,AX
        assume es:cseg
        MOV AH,11H
        MOV AL,20H
        MOV BP,OFFSET SMALLFONT
        INT 10H


        mov     ax,cs
        mov     ds,ax

        MOV     AL,10H                          ;GET THE OLD INTERRUPT VALUES
        MOV     AH,GET_VECTOR
        INT     DOS_FUN

        mov		si,offset old_vga_io
        MOV     [si + 0],bx        ;KEEP THEM
        MOV     [si + 2],es

        mov     ax,cs
        mov     ds,ax

        MOV     DX,OFFSET VGA_INTERCEPTOR   ;SET THE NEW VALUES
        MOV     AL,DOS_IO
        MOV     AH,SET_VECTOR
        INT     DOS_FUN

        mov     ax,cs
        mov		ds,ax

        MOV     DX,OFFSET INITIALIZE
        INT     DOS_TERM                          ;MAKE THE PROGRAM TSR

GOOD_EXIT:

        MOV DX,OFFSET LOADED                   ;GIVE 'EM SOME STUFF
        MOV AH,09H
        INT 21H

PROGOUT:

        MOV AH,4CH                                ;KILL ME
        INT 21h
gohorror:

        MOV DX,OFFSET Horror1                   ;GIVE 'EM SOME STUFF
        MOV AH,09H
        INT 21H
        MOV DX,OFFSET Horror2                   ;GIVE 'EM SOME STUFF
        MOV AH,09H
        INT 21H
        MOV DX,OFFSET Horror3                   ;GIVE 'EM SOME STUFF
        MOV AH,09H
        INT 21H

        MOV DX,OFFSET Horror4                   ;GIVE 'EM SOME STUFF
        MOV AH,09H
        INT 21H

        int 19h

ENDS                                         ;END OF CODE SECTION

        END START                                 ;TOTAL END



