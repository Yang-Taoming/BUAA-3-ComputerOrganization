DATA SEGMENT
    DT1 DB ?
    DT2 DB ?
    LIST DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
DATA ENDS

STKS SEGMENT STACK
    DW 100 DUP(0)
STKS ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STKS
MAIN PROC FAR
    ;初始化及数据段、堆栈段观察记录
    MOV AX, STKS   
    MOV SS, AX
    MOV SP, 100*2
    
    MOV AX, DATA
    MOV DS, AX     
    
    MOV AL,8AH     ;确定工作方式
    MOV DX,28BH
    OUT DX,AL 
AA: 
    CALL KEYIN        ;键盘输入两个数字
    AND AL,0FH
    MOV DT1,AL
    CALL KEYIN
    AND AL,0FH
    MOV DT2,AL
    MOV BX,0
    
AGN:
    MOV BL,DT1
    MOV AL,LIST[BX] 
    MOV DX,288H   ;端口输出DT1
    OUT DX,AL
    MOV DX,28AH    ;C端口控制第一个显示管亮
    MOV AL, 01B
    OUT DX,AL
    CALL DELAY   ;延迟
        
    MOV DX,28AH     ;让两个都灭
    MOV AL,11B
    OUT DX,AL
    
    MOV BL,DT2     
    MOV AL,LIST[BX]
    MOV DX,288H    ;A端口输出DT2
    OUT DX,AL
    MOV DX,28AH     ;C端口控制第二个显示管亮
    MOV AL,10B
    OUT DX,AL
    CALL DELAY; 延迟
        
    MOV DX,28AH
    MOV AL,11B
    OUT DX,AL
 
    MOV AH ,06H
    MOV DL,0FFH
    INT 21H
    JNZ AGN
    CMP AL,'N'
    JNZ AA
    MOV AH,4CH
    INT 21H
    
MAIN ENDP

DELAY PROC NEAR    ;DELAY 起到延迟的作用
     MOV BX, 64H  
NEXT1:
     MOV CX,3E8H
NEXT2:
    LOOP NEXT2
    DEC BX
    JNZ NEXT1
    RET
DELAY ENDP

KEYIN PROC NEAR    ; 从键盘输入数字并显示，若不为数字则重新输入
BEG: 
    MOV AH,08H
    INT 21H
    CMP AL,30H
    JB BEG
    CMP AL,39H
    JA BEG
    MOV AH,02H
    PUSH AX
    MOV DL,AL
    INT 21H
    POP AX
    RET
KEYIN ENDP
       
CODE ENDS
END MAIN