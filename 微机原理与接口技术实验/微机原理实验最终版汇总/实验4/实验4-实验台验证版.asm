;修改地址
PORTA       EQU     298H
PORTB       EQU     299H
PORTC       EQU     29AH
PORTCTL   EQU     29BH

PADC0    EQU      280H

DATA          SEGMENT
    DT1     DB   ?
    DT2     DB  4 DUP(0)
    LIST    DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H, 7FH,6FH

DATA          ENDS

STK  SEGMENT STACK
SSDAT    DW  100 DUP(?)
STK  ENDS

CODE          SEGMENT
                 ASSUME   CS:CODE,DS:DATA,SS:STK
START:
          MOV   AX, STK   ;初始化
          MOV   SS, AX
          MOV   SP, 2*100
          
          MOV    AX,DATA
          MOV    DS,AX
AGN:      
          MOV DX,PADC0   ;启动模数转换
          OUT DX,AL
          CALL DELAY
          IN  AL,DX      ;存入AL
          MOV BL,AL
          MOV AL,5
          MUL BL    ;乘以5后存入AX
          MOV DX,0
          MOV   BL,0FFH
          DIV  BL   ;AX/BL   ，余数在AH，商在AL
          MOV DT2,AL;          个位数存入DT2【0】
          
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
              MOV CX,10
 LOOP3:     
           MOV DX,PORTCTL
           MOV AL,88H     ;A,B,C端口都为输出
           OUT DX,AL
           MOV DX,PORTA     ;输出个位数
           MOV BX,0
           MOV BL,DT2
           MOV AL,LIST[BX]
           ADD AL,10000000B
           OUT DX,AL
           MOV DX,PORTC
           MOV AL,011B
           OUT DX,AL
           CALL DELAY
           MOV AL,111B
           OUT DX,AL
       
        
           MOV DX,PORTA;      输出小数点后一位
           MOV BL,DT2[1]
           MOV AL,LIST[BX]
           OUT DX,AL
           MOV DX,PORTC
           MOV AL,101B
           OUT DX,AL
           CALL DELAY
           MOV AL,111B
           OUT DX,AL
            
           MOV DX,PORTA   ;      输出小数点后两位
           MOV BL,DT2[2]
           MOV AL,LIST[BX]
           OUT DX,AL
           MOV DX,PORTC
           MOV AL,110B
           OUT DX,AL
           CALL DELAY
           MOV AL,111B
           OUT DX,AL
           
          LOOP LOOP3
           MOV DL,0FFH
           MOV AH,06H
           INT 21H
           CMP AL,'q'
           JE QUIT

           MOV AL,DT2[0]     ;比较电压值个位数的大小
           CMP AL,1           ;小于1或者大于等于4,PB1输出高电平，且连接蜂鸣器。
           JB ABB
           CMP AL,4
           JNB ABB
          ; CALL DELAY
           JMP AGN
           
ABB:
          MOV DX,PORTB  ;PB1输出高电平，蜂鸣器发出鸣响
          MOV AL,1B
          OUT DX,AL
          CALL DELAY2
          MOV AL,0B
          OUT DX,AL
          ;CALL DELAY
          JMP AGN
           
           
 QUIT:
         MOV AH,4CH
         INT 21H
 
DELAY    PROC
     PUSH  BX
     PUSH  CX
     
     MOV BX,100
NEXT1:   MOV CX,1000
NEXT:    LOOP NEXT
     DEC BX
     JNZ NEXT1
           
     POP   CX
     POP   BX
     RET
DELAY    ENDP

DELAY1    PROC
     PUSH  BX
     PUSH  CX
     
     MOV BX,100
NEXT5:   MOV CX,100
NEXT4:    LOOP NEXT4
     DEC BX
     JNZ NEXT5
           
     POP   CX
     POP   BX
     RET
DELAY1    ENDP
DELAY2    PROC
     PUSH  BX
     PUSH  CX
     
     MOV BX,1000
NEXT8:   MOV CX,1000
NEXT7:    LOOP NEXT7
     DEC BX
     JNZ NEXT8
           
     POP   CX
     POP   BX
     RET
DELAY2    ENDP



        
CODE          ENDS
              END         START

