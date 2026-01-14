;这是一个四位数与四位数的加法
DATA SEGMENT
     X1 DB 4 DUP(?)
     X2 DB 4 DUP(?)
     X3 DB 5 DUP(?)
DATA ENDS

STACK SEGMENT STACK
     DB 100 DUP(?)
STACK ENDS

CODE SEGMENT
     ASSUME CS:CODE, DS:DATA, SS:STACK
MAIN PROC
     MOV AX, DATA
     MOV DS, AX

     MOV BX, OFFSET X1;将X1的四个字符依次存好
     MOV CX, 4  
NEXT:
    CALL KEYIN;输入字符ASCII码存在AL中并显示
    AND AL, 0FH;与00001111相与，将AL中的ASCII码变成非压缩型BCD码
    MOV [BX], AL
    INC BX;BX自加，循环结束后正好在X1第四个位置
    LOOP NEXT
    
    MOV AH, 02H         ; 输出换行
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H


    MOV BX, OFFSET X2;将X2的四个字符依次存好
    MOV CX, 4  
NEXT1:
    CALL KEYIN;输入字符ASCII码存在AL中并显示
    AND AL, 0FH;与00001111相与，将AL中的ASCII码变成非压缩型BCD码
    MOV [BX], AL;将AL放进以BX为地址的数据段位置，即X2中的某一位置
    INC BX;BX自加，循环结束后正好在X2第四个位置
    LOOP NEXT1;至此已将两个四位数放进数据段
    
    MOV AH, 02H         ; 输出换行
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H


    MOV SI, OFFSET X1+3;将X1个位偏移地址放进SI
    MOV DI, OFFSET X2+3
    MOV BX, OFFSET X3+4
    MOV CX, 4;开始循环
    OR CX, CX;CX与自己或，CX不变，标志位CF清零
NEXT2:
    MOV AL, [SI];X1个位放入AL
    MOV AH, 0
    ADC AL, [DI];X1个位和X2个位相加（其他位再加上前一位的进位CF），结果放入AL
    AAA;AX为结果的非压缩型BCD码，并记录进位CF
    MOV [BX], AL;结果个位放入X3个位
    DEC SI;SI自减，转为指向X2十位
    DEC DI
    DEC BX
    LOOP NEXT2

    MOV AL, 0
    ADC AL, 0;将千位相加的进位CF取出放入AL
    MOV [BX], AL;将进位值放入X3万位，至此相加结果已放入X3数据段

    MOV BX, OFFSET X3
    MOV CX, 5
    XOR AL,AL
NEXT3:
    MOV DL, [BX]
    ADD DL, 30H
    CMP AL, 1
    JE SHOW
    CMP DL, 30H
    JE NOTSHOW
SHOW:
    MOV AH, 2
    INT 21H
    MOV AL, 1
NOTSHOW:
    INC BX
    LOOP NEXT3

    MOV AH, 4CH
    INT 21H;退出
MAIN ENDP

KEYIN PROC;判断输入程序并回显的子程序,8号功能键入，判断输入的内容ASCII是否'0'-'9'，是就回显
AGAIN:
     MOV AH, 8
     INT 21H;将输入数字ASCII码放进AL
     CMP AL, 30H
     JB AGAIN;小于返回，等待重新键入
     CMP AL, 39H
     JA AGAIN;大于返回，等待重新键入
     MOV DL, AL
     MOV AH, 2
     INT 21H;二号功能显示DL中输入的数字
     RET
KEYIN ENDP

CODE ENDS
     END MAIN