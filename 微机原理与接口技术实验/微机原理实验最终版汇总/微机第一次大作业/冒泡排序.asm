;这是一个升序冒泡排序，要注意的是，有些电脑右侧的数字键无法输入进去，只能使用键盘上方的数字
STACK SEGMENT STACK
    DW 100 DUP(?)
STACK ENDS

DATA SEGMENT
    X1 DB 100 DUP(?)       
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA, SS:STACK
START:
    MOV AX, DATA
    MOV DS, AX
    MOV SI, OFFSET X1;将SI指向X1
    
INPUT:
    MOV AH, 01H ; 读取键盘输入，存入数据段的X1中
    INT 21H
    CMP AL, 0DH ; 检查回车符结束输入
    JE END_INPUT; 移除对'$'的检查，允许输入'$'
    MOV [SI], AL        ; 存储输入字符   
    INC CX
    INC SI              ; 增加字符计数   
    JMP INPUT

END_INPUT:
    MOV [SI], 0         ; 输入结束后添加结束符
    MOV BX, CX          ; 设置 BX 为字符数量
    DEC BX              ; 设置外循环次数，BX = 字符数 - 1
    MOV SI, OFFSET X1

OUTLOOP:
    MOV DI, OFFSET X1   ; 内层循环从头开始
    MOV CX, BX          ; 内层循环次数，逐渐减少

INLOOP:
    MOV AL, [DI]        ; AL = 当前字符
    MOV DL, [DI+1]      ; DL = 下一个字符
    CMP AL, DL
    JBE NO_SWAP         ; 如果当前字符小于等于下一个字符，不交换
    MOV [DI], DL        ; 否则交换
    MOV [DI+1], AL    
    
NO_SWAP:
    INC DI              ; DI 指向下一个字符
    LOOP INLOOP     ; 重复内循环直到排序完成
    DEC BX              ; 减少外循环次数
    JNZ OUTLOOP      ; 重复外循环直到所有数字排序完成

    MOV AH, 2         ; 输出换行
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    
    MOV SI, OFFSET X1  ; 从字符串起始位置输出排序后的字符
OUTPUT:
    MOV AL, [SI]
    CMP AL, 0           ; 检查是否到达字符串结尾
    JE EXIT
    MOV DL, AL
    MOV AH, 2
    INT 21H
    INC SI
    JMP OUTPUT     ; 持续输出字符直到遇到结束符号

EXIT:
    MOV AH, 4CH
    INT 21H
CODE ENDS
END START