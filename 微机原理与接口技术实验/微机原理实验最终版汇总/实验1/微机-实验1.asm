;8255A端口地址，实验箱端口地址是连续的，而Proteus一般设置成偶地址
PORTA    EQU     288H
PORTB    EQU     289H
PORTC    EQU     28AH
PORTCTL  EQU     28BH

DATA SEGMENT
    DT1 DB ?
    DT2 DB ?
    LIST DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH;0-9字型码
DATA ENDS

STKS SEGMENT STACK
    DW 100 DUP(0)
STKS ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STKS
MAIN PROC FAR
    ;初始化及数据段、堆栈段观察记录
    MOV AX, STKS   ;堆栈段后加STACK可不写
    MOV SS, AX
    MOV SP, 100*2
    
    MOV AX, DATA
    MOV DS, AX     
    
    MOV AL,8AH     ;确定8255A工作方式
    MOV DX,28BH    ;8255A控制端口
    OUT DX,AL 
AA: 
    CALL KEYIN        ;键盘输入两个数字，BCD码分别放入DT1与DT2中
    AND AL,0FH        ;ASCII码转非压缩BCD码
    MOV DT1,AL
    CALL KEYIN
    AND AL,0FH
    MOV DT2,AL
    
    MOV BX,0   
AGN:
    MOV BL,DT1
    MOV AL,LIST[BX] 
    MOV DX,288H    ;A端口输出DT1的七段码
    OUT DX,AL
    MOV DX,28AH    ;C端口控制第一个显示管亮，第二个显示管灭
                   ;实验箱上的七段码管为共阴极，阴极输入端加低电平，选中的数码管亮.
    MOV AL,01B     ;C端口控制第一个显示管亮，即十位
    OUT DX,AL
    CALL DELAY     ;延迟
        
    MOV DX,28AH    ;让两个都灭
    MOV AL,11B
    OUT DX,AL
    
    MOV BL,DT2     
    MOV AL,LIST[BX]
    MOV DX,288H     ;A端口输出DT2的七段码
    OUT DX,AL
    MOV DX,28AH     ;C端口控制第二个显示管亮，即个位
    MOV AL,10B
    OUT DX,AL
    CALL DELAY      ; 延迟
        
    MOV DX,28AH     ;让两个都灭
    MOV AL,11B
    OUT DX,AL
 
    MOV AH ,06H        ;6号功能检测按键是否按下
    MOV DL,0FFH
    INT 21H
    JNZ AGN            ;若无按键按下则跳转AGN继续显示    
    CMP AL,27          ;检查是否按下ESC
    JE EXIT            ;如果是ESC则退出
    JMP AGN             ;否则回到开头重新读取数字并显示
    
EXIT:    
    MOV AH,4CH
    INT 21H
    
MAIN ENDP

;-----------------------------------------------------------------延迟函数
DELAY PROC NEAR    ;DELAY 起到延迟的作用
     MOV BX, 190H  ;外循环400
NEXT1:
     MOV CX,3E8H  ;内循环1000
NEXT2:
    LOOP NEXT2
    DEC BX
    JNZ NEXT1
    RET
DELAY ENDP

;------------------------------------------------------------------键入函数
KEYIN PROC NEAR    ; 从键盘输入数字并显示，若不为数字则重新输入
BEG: 
    MOV AH,08H     ;8号功能键入
    INT 21H
    CMP AL,30H
    JB BEG          ;小于0跳转
    CMP AL,39H
    JA BEG          ;大于9跳转
    MOV AH,02H      ;2号功能显示
    PUSH AX
    MOV DL,AL
    INT 21H
    POP AX
    RET
KEYIN ENDP
;----------------------------------------------------------------------------       
CODE ENDS
END MAIN