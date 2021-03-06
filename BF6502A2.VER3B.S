; Title: BrainFuck 6502 Interpreter for the Apple ][ //e
; File: BF6502A2.VER3B.S
;
: CPU: 6502
; Platform: Apple ][ //e
; By: Michael Pohoreski
; Date: Dec, 2008
; Last updated: Jul, 2015
; Description: 187 Byte Interpreter of BrainFuck
; Version 3b
;    - No new functionality
;    - Cleaned up source code for readability
;    - Switched to Merlin directives
; License: BSD "Sharing is Caring!"
; https://github.com/Michaelangel007/brainfuck6502
;
; Discussion:
; https://groups.google.com/d/msg/comp.emulators.apple2/Om3JKqDZoEA/cwa5U1Hr3TAJ
;
; Definition:
; http://en.wikipedia.org/wiki/Brainfuck
;
; >  ++pData;
; <  --pData;
; +  ++(*pData);
; -  --(*pData);
; .  putchar(*pData);
; ,  *pData=getchar();
; [  while (*pData) { // if( *pData == 0 ), pCode = find_same_depth ( ']' );
; ]  }                // if( *pData != 0 ), pCode = find_same_depth ( '[' );
;
; Reference Tests:
; http://esoteric.sange.fi/brainfuck/bf-source/prog/tests.b
;
; Examples:
; http://esoteric.sange.fi/brainfuck/bf-source/prog/
; http://esolangs.org/wiki/Brainfuck#Implementations
; http://www.muppetlabs.com/~breadbox/bf/standards.html
; http://software.xfx.net/utilities/vbbfck/index.php
; http://nesdev.parodius.com/6502.txt

; ===================================================================
; Source
; This was hand-assembled so don't blame me if this doesn't assemble.
; Well, technically you can, but I'm to lazy to fix it.
; Send me a patch and I'll try to update it.
; Merlin has a 64 char limit of OPERAND+COMMENT
; So you'll probably run into that issue
; One day you'll be able to assemble this directly inside AppleWin

OPCODE          EQU        $F0   ; Applesoft SPEED @ $F1, Flash mask $F3
OPFUNCPTR       EQU        $F8   ; Applesoft ROT @ $F9
                                 ; Applesoft Free soace $EB .. $EF
CUR_DEPTH       EQU        $EE   ; // current nested depth
NUM_BRACKET     EQU        $EF   ; // depth to find[]

BFPC            EQU        $3C   ; BFPC/pCode same as A1L/H
DATA            EQU        $40   ; DATA/pData same as A3L/H

HGR             EQU        $F3D8
HGR2            EQU        $F3E2

COUT            EQU        $FDED
RDKEY           EQU        $FD0C

NXTA1           EQU        $FCBA
NXTA1_8         EQU        $FCC2 ; standard entry point is NXTA1 = $FCBA

STOR            EQU        $FE0B
STOR_6          EQU        $FE11 ; standard entry point is STOR = $FE0B

CLRTEXT         EQU        $C050
SETTEXT         EQU        $C051

HGR             EQU        $F3E2
HGR2            EQU        $F3D8
RDKEY           EQU        $FD0C
COUT            EQU        $FDED ; trashes A, Y

; Used to read start address of $0806 = first Applesoft token
; If you use Applesoft as a helper text entry such as
;    0 "...brainfuck code..."
; You must manually move the BF code to $6000 via:
;     CALL -151
;     6000<806.900M
;     300G

        ORG $300
;       STA CLRTEXT     ; 8D 50 C0 ; Optional: C051 or C050

        JSR HGR         ; 20 D8 F3 ; Clear top 8K of data
        JSR HGR2        ; 20 E2 F3 ; Clear bot 8K of data

        LDY #$00        ; A0 00    ;
        STY BFPC        ; 84 3C    ;
        STY DATA        ; 84 40    ;
        STY CUR_DEPTH   ; 84 EE    ;
; Code needs to end with a zero byte 
; DEFAULT:  $60/$20 for   big code ($6000..$BFFF = 24K) / medium data ($2000..$5FFF = 16K)
; Optional: $08/$10 for small code ($0800..$0FFF =  2K) / large  data ($1000..$BFFF = 44K)
; Note: You will also need to zero memory if you use large data
        LDA #$60        ; A9 60    ; Start CODE buffer
        STA BFPC+1      ; 85 3D    ;
        LDA #$20        ; A9 20    ; Start DATA buffer
        STA DATA+1      ; 85 41    ;
FETCH
        LDA (BFPC),Y    ; B1 3C    ;
        BEQ EXIT        ; F0 1F    ;
        JSR INTERPRET   ; 20 24 03 ;

        JSR NXTA1_8     ; 20 C2 FC ;
        LDY #$00        ; A0 00    ; because COUT trashes Y
        BEQ FETCH       ; F0 F2    ; branch always
INTERPRET

        LDX #$07        ; A2 07    ; 8 Instructions
FIND_OP
        CMP OPCODE,X    ; D5 F0    ; table of opcodes (char)
        BEQ EXEC        ; F0 03    ;
        DEX             ; CA       ;
        BPL FIND_OP     ; 10 F9    ;
        RTS             ; 60       ; ignore non-tokens, allows for comments
EXEC
        LDA #$03        ; A9 03    ; high byte of this code address
        PHA             ; 48       ;
        LDA OPFUNCPTR,X ; B5 F8    ; function pointer table (address)
        PHA             ; 48       ;
        CLC             ; 18       ; optimization: common code
        LDA (DATA),Y    ; B1 40    ; optimization: common code
EXIT
        RTS             ; 60       ; 1) exit to caller,
                                   ; 2) relative jsr to our bf_*(), or
                                   ; 3) exit our bf_*()
BF_NEXT
        JMP STOR+6      ; 4C 11 FE ; optimization: INC A3L, BNE +2, INC A3H, RTS
BF_PREV
        LDA DATA        ; A5 40    ;
        BNE .1          ; D0 02    ;
        DEC DATA+1      ; C6 41    ;
.1      
        DEC DATA        ; C6 40    ;
EXIT_2

        RTS             ; 60       ;
BF_INC
        ADC #$02        ; 69 02    ; optimization: n+2-1 = n+1
        CLC             ; 18       ; optimization: fall-through into BF_INCDEC
BF_DEC
        SBC #$00        ; E9 00    ;
STORE_DATA
        LDY #$00        ; A0 00    ;
        STA (DATA),Y    ; 91 40    ;
        RTS             ; 60       ;
BF_IN
        JSR RDKEY       ; 20 0C FD ; trashes Y
        AND #$7F        ; 29 7F    ; convert 8-bit Apple Text to 7-bit ASCII
        BPL STORE_DATA  ; 10 F4    ; always
; BrainFuck spec is ambigous -- is Return/Enter stored as 0x0D or 0x0A ?
;        CMP #$0D       ; C9 0D    ;
;        BNE STORE_DATA ; D0 F5    ;
;        LDA #$0A       ; A9 0A    ;
;        BPL STORE_DATA ; 10 F2    ; optmization: BPL BF_INCDEC (10 F4)

BF_OUT
        ORA #$80        ; 09 80    ; output Hi-Bit Apple Text !
;        CMP #$8A       ; C9 8A    ; BrainFuck spec is again ambigous
;        BNE .1         ; D0 02    ; what ASCII char is newline? 0x0D 0x0A?
;        LDA #8D        ; A9 8D    ; map newline 0A to 8D
.1
        JMP COUT        ; 4C ED FD ; trashes A, Y
BF_IF                   ;          ; if( *pData == 0 ) pc = ']'
        INC CUR_DEPTH   ; E6 EE    ; *** depth++

        LDA (DATA),Y    ; B1 40    ; optimization: common code
        BNE EXIT_2      ; D0 E3    ; optimization: BEQ .1, therefore BNE RTS
        LDA CUR_DEPTH   ; A5 EE    ; match_depth = depth
        STA NUM_BRACKET ; 85 EF    ;
.2                                 ; Sub-Total Bytes #101
        JSR NXTA1+8     ; 20 C2 FC ; optimization: INC A1L, BNE +2, INC A1H, RTS
        LDA (BFPC), Y   ; B1 3C    ;
        CMP '['         ; C9 5B    ; ***
        BNE .4          ; D0 04    ;
        INC NUM_BRACKET ; E6 EF    ; *** inc stack
        BNE .2          ; D0 F3    ;
.4
        CMP ']'         ; C9 5D    ; ***
        BNE .2          ; D0 EF    ;
        LDA CUR_DEPTH   ; A5 EE    ;
        CMP NUM_BRACKET ; C5 EF    ;
        BEQ EXIT_2      ; F0 C8    ;
        DEC NUM_BRACKET ; C6 EF    ; *** dec stack
        CLC             ; 18       ;
        BCC .2          ; 90 E4    ;
BF_FI                   ;          ; if( *pData != 0 ) pc = '['
        DEC CUR_DEPTH   ; C6 EE    ; depth--
        LDA (DATA),Y    ; B1 40    ;
        BEQ EXIT_2      ; F0 BD    ; optimization: BNE .1, therefore BEQ RTS
        LDA CUR_DEPTH   ; A5 EE    ; match_depth = depth
        STA NUM_BRACKET ; 85 EF    ;
.2
        LDA BFPC        ; A5 3C    ;
        BNE .3          ; D0 02    ;
        DEC BFPC+1      ; C6 3D    ;
.3
        DEC BFPC        ; C6 3C    ;

        LDA (BFPC),Y    ; B1 3C    ;
        CMP ']'         ; C9 5D    ;
        BNE .4          ; D0 04    ;
        DEC NUM_BRACKET ; C6 EF    ; dec stack
        BNE .2          ; D0 EE    ;
.4
        CMP '['         ; C9 5B    ;
        BNE .2          ; D0 EA    ;
        LDA CUR_DEPTH   ; A5 EE    ;
        CMP NUM_BRACKET ; C5 EF    ;
        BEQ EXIT_2      ; F0 9D    ;
        INC NUM_BRACKET ; E6 EF    ; dec stack
        CLC             ; 18       ;
        BCC .2          ; 90 DF    ;

        ORG $F0
OPCODE  ASC ',.[<]>-+'  ;          ; sorted: 2B 2C 2D 2E 3C 3E 5B 5D
OPFUNCPTR               ;          ; by usage: least commonly called to most
        DFB BF_IN  -1   ; 4D       ; ,
        DFB BF_OUT -1   ; 54       ; .
        DFB BF_IF  -1   ; 59       ; [
        DFB BF_PREV-1   ; 3A       ; <
        DFB BF_FI  -1   ; 7F       ; ]
        DFB BF_NEXT-1   ; 37       ; >
        DFB BF_DEC -1   ; 46       ; -
        DFB BF_INC -1   ; 43       ; +
