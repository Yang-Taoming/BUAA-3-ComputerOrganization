DATA SEGMENT
     DT1   DB  37
     DT2   DB  64H
     DT3   DW  0ABCDH
     DT4   DW  8765H
     DT5   EQU 0A7H
DATA ENDS

STKS SEGMENT  STACK
     DW  100 DUP(0)
STKS ENDS

CODE SEGMENT
     ASSUME  CS:CODE, DS:DATA, SS:STKS
MAIN PROC FAR
    ;初始化及数据段、堆栈段观察记录
     MOV  AX, STKS
     MOV  SS, AX
     MOV  SP, 100*2

     MOV  AX, DATA
     MOV  DS, AX

    ;加减法、PSW实验
     MOV  AX, DT3
     ADD  AX, DT4
     MOV  DT4,AX
     
          MOV  AL, DT1
     MOV  BL, DT2
     SUB  AL, BL
     MOV  DT1, AL

     ;比较、条件转移、CALL指令以及堆栈实验
     CMP  AX, DT3
     JA   NEXT1
     PUSH AX
     JMP  NEXT2
NEXT1:
      PUSH DT3
NEXT2:
      POP  DX
      CALL  SPRC

      MOV  AH, 4CH
      INT  21H
      
MAIN ENDP

SPRC PROC NEAR
     MOV  CL, 3
     ROL  DX, CL
     RET
SPRC ENDP
CODE ENDS
END  MAIN