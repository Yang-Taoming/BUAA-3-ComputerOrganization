;8255A端口地址，实验台是连续的，不像正常地址接低八位为偶地址
PORTA  EQU 298H
PORTB  EQU 299H
PORTC  EQU 29AH
PORTCTL  EQU 29BH
;ADC0809端口输出地址
PADC0 EQU 280H

DATA SEGMENT
    DT1     DB  ?
    DT2     DB  4 DUP(0)
    LIST    DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
DATA ENDS

STK  SEGMENT STACK
         DW 100 DUP(?)
STK  ENDS

CODE SEGMENT
    ASSUME   CS:CODE,DS:DATA,SS:STK
START:
          MOV   AX, STK   ;堆栈段初始化，堆栈段后加STACK可不写
          MOV   SS, AX
          MOV   SP, 2*100
          
          MOV  AX,DATA
          MOV  DS,AX
;------------------------------------------------------------主程序从这里开始
AGN:      
          MOV DX,PADC0   ;启动0809模数转换
          OUT DX,AL
          
          IN  AL,DX      ;读取的数字量存入AL
          MOV BL,AL
          MOV AL,5
          MUL BL              ;数字量乘以5后存入AX
          MOV DX,0            ;除数高16位
          MOV BL,0FFH         ;除数低16位
          DIV BL              ;AX/BL   ，余数在AH，商在AL
          MOV DT2,AL          ;个位数存入DT2【0】
          
          MOV CX,2
          MOV DI,1
          
LOOP2:    MOV BL,AH          ;小数点后2位分别存入DT2[1]和DT2[2]中
          MOV AL,10
          MUL BL             ;余数*10，再除以255提取后一位
          MOV DX,0           ;除数高16位
          MOV BL,0FFH        ;除数低16位
          DIV BL             ;AX/BL   ，余数在AH，商在AL
          MOV DT2[DI],AL     ;小数点后2位分别存入DT2[1]和DT2[2]中
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
           ADD AL,10000000B     ;七段码第一位置1，加上小数点
           OUT DX,AL
      ;实验箱上的七段码管为共阴极，阴极输入端加低电平，选中的数码管亮.     
           MOV DX,PORTC
           MOV AL,011B
           OUT DX,AL
           CALL DELAY
           
           MOV AL,111B;三个数码管全都灭
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
           
          LOOP LOOP3            ;让数字交替闪烁保留一段时间，使人肉眼可以分辨
           MOV DL,0FFH
           MOV AH,06H
           INT 21H
           CMP AL,27            ;按ESC退出
           JE EXIT

           MOV AL,DT2[0]     ;比较电压值个位数的大小
           CMP AL,1           ;小于1或者大于等于4,PB0输出高电平，接蜂鸣器。
           JB ABB
           CMP AL,4
           JNB ABB
           JMP AGN
           
ABB:
          MOV DX,PORTB  ;PB0输出高电平，蜂鸣器发出鸣响
          MOV AL,1B
          OUT DX,AL
          CALL DELAY2    ;鸣响一段时间后不再响，返回开头重新读入数字量
          MOV AL,0B
          OUT DX,AL
          JMP AGN
           
           
EXIT:
         MOV AH,4CH
         INT 21H
         
;----------------------------------延迟函数0，延迟时间100*1000 
DELAY  PROC
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
DELAY  ENDP

;----------------------------------延迟函数1，延迟时间100*100，时间较短
DELAY1 PROC
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

;--------------------------------延迟函数2，延迟时间1000*1000，时间较长
DELAY2 PROC
     PUSH  BX
     PUSH  CX
     
     MOV BX,1000
NEXT8:  MOV CX,1000
NEXT7:  LOOP NEXT7
     DEC BX
     JNZ NEXT8
           
     POP   CX
     POP   BX
     RET
DELAY2    ENDP
;-----------------------------------------------------------------     
CODE ENDS
END START

