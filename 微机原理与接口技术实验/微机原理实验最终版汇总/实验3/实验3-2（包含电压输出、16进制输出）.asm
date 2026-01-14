;ADC0809输出端口地址
PADC0 EQU 2A0H

DATA SEGMENT
    DT2 DB  4 DUP(0)
DATA ENDS

STK  SEGMENT STACK
      DW  100 DUP(?)
STK  ENDS

CODE SEGMENT
    ASSUME   CS:CODE,DS:DATA,SS:STK
START:;初始化及数据段、堆栈段观察记录  
    MOV   AX, STK
    MOV   SS, AX
    MOV   SP, 2*100

    MOV AX,DATA
    MOV DS,AX                
AGN:
    MOV DX,PADC0;启动AD转换
    OUT DX,AL
    CALL DELAY
          
    IN  AL,DX      ;存入AL
    MOV BL,AL
          
    ;16进制输出
    PUSH AX
          
    SHR AL,4;高四位
    AND AL,0FH
    CMP AL,9
    JBE NUM
    ADD AL,37H;数字A-F
    JMP NEXT11
NUM:ADD AL,30H;数字0-9
          
          
NEXT11: 
    MOV DL,AL
    MOV AH,02H
    INT 21H   
    POP AX
    PUSH AX
           
    AND AL,0FH;低四位
    CMP AL,9
    JBE NUM1
    ADD AL,37H;数字A-F
    JMP NEXT10
NUM1: 
    ADD AL,30H;数字0-9
          
NEXT10:
    MOV DL,AL
    MOV AH,02H
    INT 21H          
         
    MOV DL,'H'
    MOV AH,02H
    INT 21H;输出H
           
    MOV DL,20H;输出空格
    INT 21H
        
    POP AX 
          
    MOV AL,5
    MUL BL    ;乘以5后存入AX
    MOV DX,0
    MOV BL,0FFH
    DIV  BL   ;AX/BL   ，余数在AH，商在AL
    MOV DT2,AL;          个位数存入DT2[0]
          
    MOV CX,2
    MOV DI,1
LOOP2:    MOV BL,AH;         小数点后2位分别存入DT2[1]和DT2[2]中
          MOV  AL,10
          MUL  BL
          MOV DX,0
          MOV BL,0FFH
          DIV BL
          MOV DT2[DI],AL
          INC DI
          LOOP LOOP2
                     
           MOV CX,3
           MOV BX,0
LOOP1:
           MOV AL,DT2[BX]    ;输出存入DT2中的电压值
           INC BL
           ADD AL,30H;转为ASCII码
           
           MOV AH,02H
           MOV DL,AL
           INT 21H
           
           CMP BL,1
           JNE NEXT6
           
           MOV DL,'.';输出小数点
           MOV AH,02H
           INT 21H
           
NEXT6:      LOOP LOOP1
           MOV DL,'V'
           MOV AH,02H
           INT 21H;输出V
           
           MOV DL,0DH;输出回车换行
           INT 21H
           MOV DL,0AH
           INT 21H
           
           MOV AH,08H;输出n退出
           INT 21H
           CMP AL,'n'
           JE EXIT
           JMP AGN
           
EXIT:
           MOV AH,4CH
           INT 21H
                          
DELAY PROC
     PUSH  BX
     PUSH  CX
     
     MOV BX,100
NEXT1:   MOV CX,10
NEXT:    
     LOOP NEXT
     DEC BX
     JNZ NEXT1
           
     POP CX
     POP BX
     RET
DELAY ENDP
    
CODE ENDS
END START