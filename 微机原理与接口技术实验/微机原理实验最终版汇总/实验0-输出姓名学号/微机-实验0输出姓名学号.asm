DATA SEGMENT
    DT1 DB 1,2,'AB'
    COUNT EQU $-DT1
    DT2 DW 1,2,'AB'
    DT3 DW DT2
    DT4 DW $-DT2
    SN DB 9 DUP(?)
    NAM DB 20                     
        DB ?
        DB 25 DUP('$')
        DB '$'                                  ;0AH功能：从键盘接收字符，并存放到内存缓冲区。
                                                ;在使用0AH号功能调用时，应当注意以下问题。
                                                ;1、执行前先定义一个输入缓冲区，缓冲区内第一个字节定义为允许最多输入的字符个数，
                                                ;2、字符个数应包括回车符0DH在内，不能为"0"值。第二个字节保留，在执行程序完毕存入输入的实际字符个数。
                                                ;3、从第三个字节开始存入从键盘上接收字符的ASCII码。数据段初始化全部为"$"，读字符串的时候就会去覆盖，能够保证回车后直接就是"$"

DATA ENDS

STKS SEGMENT STACK
    DW 100 DUP(0)
STKS ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:STKS
START:
    ;初始化及数据段、堆栈段观察记录
    MOV AX, STKS   
    MOV SS, AX
    MOV SP, 100*2
    
    MOV AX, DATA
    MOV DS, AX
    
 ;   MOV AH,02H;二号功能显示DT1中的1和A
 ;   MOV DL,DT1
 ;   INT 21H
 ;   MOV DL,DT1[2]
 ;   INT 21H

    MOV BX,0
NEXT1:
    MOV AH,01H;一号功能输入并显示学号，并保存在SN中
    INT 21H
    CMP AL,0DH;判断输入是否为回车
    JNE NEXT2;不为回车，跳转NEXT2
    JE  NEXT3;为回车，跳转NEXT3
NEXT2:
    MOV SN[BX],AL;将输入的一个符号存在SN中，并回到NEXT1继续输入
    INC BX
    JMP NEXT1

NEXT3:   
    MOV DL,0DH;输入回车换行
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H   
     
    LEA DX, NAM ;一号功能输入学号结束，使用0AH号功能输入姓名并保存在NAM中
    MOV AH,0AH
    INT 21H
    
    MOV DL,0DH;输入回车
    MOV AH,02H
    INT 21H
    MOV DL,0AH;输入换行
    MOV AH,02H
    INT 21H

    MOV CX,BX;将SN中存储的字符数给CX
    MOV BX,0
    MOV AH,02H
NEXT4:
    MOV DL,SN[BX];用2号功能显示SN中的字符
    INT 21H
    INC BX
    DEC CX;字符串长度减一
    JNZ NEXT4;未显示完，继续显示
    JZ  NEXT5;SN中学号显示结束
NEXT5:
    MOV DL,0DH;输入回车
    MOV AH,02H
    INT 21H 
    MOV DL,0AH;输入换行
    MOV AH,02H
    INT 21H 

    MOV DX,OFFSET NAM[2];使用09H功能显示NAM中的字符串,注意NAM中的名字是从NAM[2]开始的
    MOV AH,09H
    INT 21H

    MOV AH,4CH;结束
    INT 21H
       
CODES ENDS
END START
