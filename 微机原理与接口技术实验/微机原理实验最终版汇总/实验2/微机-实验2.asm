DATA SEGMENT
    N DB 0AH
    MUSIC DB 1,0,1,0,5,0,5,0,6,0,6,0,5,5,5,5,4,0,4,0,3,0,3,0,2,0,2,0,1,1,1,1,5,0,5,0,4,0,4,0,3,0,3,0,2,2,2,2,5,0,5,0,4,0,4,0,3,0,3,0,2,2,2,2,1,0,1,0,5,0,5,0,6,0,6,0,5,5,5,5,4,0,4,0,3,0,3,0,2,0,2,0,1,1,1,1
    LEN_M EQU $-MUSIC
    FRE DW 262,294,330,347,392,440,494,524;1个频率占两个字节
 
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
    
    MOV DX,28BH  ;设置8255A的工作方式，A口输出
    MOV AL,8BH
    OUT DX,AL
    
    
    MOV DX,288H;PA=1使计数器开始计数，PA0=0禁止喇叭工作
    MOV AL,10B
    OUT DX,AL

    MOV DX,283H    ;8254控制端口
    MOV AL,36H     ;8254通道0设置工作方式3输出方波
    OUT DX,AL
AGN:
    CALL KEYIN     ;从键盘输入数字转为BCD码，放入DL
    AND AL,0FH
    MOV DL,AL
    
    DEC DL
    SHL DL,1

    MOV BH,0;查找数字对应频率
    MOV BL,DL
    MOV CX,FRE[BX]
   
    MOV DX,0FH  ;1000000=0F4240H
    MOV AX,4240H
    DIV CX   ;(DX,AX)/CX,商存在AX，即为时间常数
    
    MOV DX,280H  ;8254通道0写入时间常数
    OUT DX,AL    ;先写入n的低八位
    MOV AL,AH
    OUT DX,AL    ;再写入n的高八位
    MOV DX,288H  ;控制PA0=1使喇叭开始工作
    MOV AL,11B   
    OUT DX,AL
    CALL DELAY
    
    ;至此音已经播出
    
    MOV DX,288H;8255A的A端口，PA1=1使计数器开始计数，PA0=0禁止喇叭工作
    MOV AL,10B
    OUT DX,AL

JDG:
    MOV AH,08H
    INT 21H
    CMP AL,'n'   ;按n结束程序
    JE EXIT
    CMP AL,'a'   ;按a播放一段乐谱
    JE BC
    CMP AL,'b'   ;按b重新播放单个音符
    JE AGN
;------------------------------------------------------------↓替换JDG开始的程序，只实现播放单音的功能    
;    MOV AH,06H
;    MOV DL,0FFH
;    INT 21H
;    CMP AL,'n'   ;按n结束程序
;    JE EXIT
;    JNZ AGN      ;没有键盘键入跳回AGN重新键入播放单个音符
    
EXIT:
    MOV AH,4CH
    INT 21H
    
;------------------------------------------------------------↓播放乐谱
BC:    
    MOV DI,0
ABC:
    MOV BL,MUSIC[DI];将乐谱第一个音放入BL
    
    DEC BL
    SHL BL,1

    
    MOV BH,0
    MOV SI,FRE[BX]  ;BX对应频率写入SI
    
    
    MOV DX,0FH    ;1000000=0F4240H
    MOV AX,4240H   
    DIV SI        ;商存在AX里，余数存在DX里
    MOV DX,280H   ;8254的通道0写入时间常数n
    OUT DX,AL
    MOV AL,AH
    OUT DX,AL
    MOV DX,288H   ;控制PA0=1,PA0=1使喇叭开始工作
    MOV AL,11B   
    OUT DX,AL
    CALL DELAY
    INC DI        ;DI加1
  
    CMP DI,LEN_M   ;比较此时DI的值和乐谱长度
    JB ABC         ;小于则继续播放乐谱
    
    MOV DI,0
    MOV DX,288H;PA=1，PA0=0禁止喇叭工作
    MOV AL,10B
    OUT DX,AL
    JMP JDG         ;播放完乐谱后，跳转JDG重新判断

    
MAIN ENDP
;---------------------------------------------------------------延迟函数
DELAY PROC NEAR    ;DELAY 起到延迟的作用
     MOV BX, 10000 ;外循环次数10000
NEXT1:
     MOV CX,1000   ;内循环次数1000
NEXT2:
    LOOP NEXT2
    DEC BX
    JNZ NEXT1
    RET
DELAY ENDP

;-----------------------------------------------------------------键入函数
KEYIN PROC NEAR    ; 从键盘输入数字0-7并显示，若不为数字0-7则重新输入
BEG: 
    MOV AH,08H
    INT 21H
    CMP AL,31H
    JB BEG
    CMP AL,38H
    JA BEG
    MOV AH,02H
    PUSH AX
    MOV DL,AL
    INT 21H
    POP AX
    RET
KEYIN ENDP
;---------------------------------------------------------------------------       

CODE ENDS
END MAIN