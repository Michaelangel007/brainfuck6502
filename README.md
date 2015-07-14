# BrainFuck 6502 Interpreter for the Apple ][ //e

This is an 187 byte interpreter of BrainFuck for the 6502 Apple ]\[ //e

CALL-151
300: 20 D8 F3 20 E2 F3
306: A0 00 84 3C 84 40 84 EE
30E: A9 60 85 3D A9 20 85 41
316: B1 3C F0 1F 20 24 03 20 C2 FC A0 00 F0 F2
324: A2 07 D5 F0 F0 04 CA 10 F9 60
32E: A9 03 48 B5 F8 48 18 B1 40 60
338: 4C 11 FE
33B: A5 40 D0 02 C6 41 C6 40 60
344: 69 02 18
347: E9 00
349: A0 00 91 40 60
34E: 20 0C FD 29 7F 10 F4
355: 09 80 4C ED FD
35A: E6 EE B1 40 D0 E3 A5 EE 85 EF
364: 20 C2 FC B1 3C C9 5B D0 04 E6 EF D0 F3
371: C9 5D D0 EF A5 EE C5 EF F0 C8 C6 EF 18 90 E4
380: C6 EE B1 40 F0 BD A5 EE 85 EF
38A: A5 3C D0 02 C6 3D
390: C6 3C B1 3C C9 5D D0 04 C6 EF D0 EE
39C: C9 5B D0 EA A5 EE C5 EF F0 9D E6 EF 18 90 DF
F0: 2C 2E 5B 3C 5D 3E 2D 2B
F8: 4D 54 59 3A 7F 37 46 43

# Examples

NOTE:

* Watch out for hidden CRs since the Apple will break the line up.  You may need to copy paste these as multiple lines.

0 "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."
REM Hello World!
CALL -151
6000<806.900M
FA62G
CALL 768

REM http://esolangs.org/wiki/Talk:Brainfuck
0 "++++++++[->-[->-[->-[-]<]<]<]"
CALL-151
6000<806.900M
FA62G
CALL 768
REM -n/a-

0 ">++++++++[<++++++++++>-]<[>+>+<<-]>-.>-----.>"
REM OK
CALL 768

0 "+++++++++++++[>+++++++++>++++++++>++++++++>+++++<<<<-]>-.>.---.>++++
+.<----.<.>>+++++.<++++++++.>++++++.<----.----.<.-.>>+.----------.<<+
+.>>>-.<<<++++.>.+++++++.>..>------------------.<<-----.>.>.<-.<<+."
REM thematrixeatsyou@yahoo.co.nz
CALL 768

0 "++++++++[->-[->-[->-[-]<]<]<]>++++++++[<++++++++++>-]<[>+>+<<-]
>-.>-----.>"
CALL -151
6000<806.900M
FA62G
CALL 768

0 "++++[>++++++<-]>[>+++++>+++++++<<-]>>++++<[[>[[>>+<<-]<]>>>-]>-[>+>
+<<-]>]+++++[>+++++++<<++>-]>.<<."
REM Need 32K data!!!
REM Prints #
CALL -151
2000:0
2001<2000.BFFEM
FA62G
CALL 768

