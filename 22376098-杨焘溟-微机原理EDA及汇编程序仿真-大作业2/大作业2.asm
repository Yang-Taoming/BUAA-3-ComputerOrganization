DATA SEGMENT
    DT1 DB 37
    DT2 DB 64H
    DT3 DW 0ABCDH
    DT4 DW 8765H
    DT5 EQU 0A7H
DATA ENDS

STKS SEGMENT STACK
    DW 100 DUP(0)
STKS ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA, SS:STKS
MAIN PROC FAR
;初始化及数据段、堆栈段观察记录
    MOV AX, STKS  ;(1)
    MOV SS, AX
    MOV SP, 100*2 
    
    
    MOV AX, DATA
    MOV DS, AX     ;(2)
    
    ;加减法、PSW 实验
    MOV AX, DT3    ;(3)
    ADD AX, DT4    ;(4)
    MOV DT4,AX     ;(5)
    
    MOV AL, DT1
    MOV BL, DT2
    SUB AL, BL     ; (6)
    MOV DT1, AL     ;(7)
    
;比较、条件转移、CALL 指令以及堆栈实验
    CMP AX, DT3    ; (8)
    JA NEXT1
    PUSH AX         ;(9)
    JMP NEXT2
NEXT1:
    PUSH DT3       ; (10)
NEXT2:
    POP DX          ; (11)
    CALL SPRC        ;(12)
    
    MOV AH, 4CH
    INT 21H         ; (15)
    
MAIN ENDP

SPRC PROC NEAR
    MOV CL, 3
    ROL DX, CL       ; (13)
    RET              ; (14)
SPRC ENDP
CODE ENDS
END MAIN
