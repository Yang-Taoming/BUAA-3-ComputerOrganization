DATA SEGMENT
    DT1 DB '1','2','AB';注意，比如第一个1，如果不打单引号，打印出来是ASCII码为1的字符（标题开始符）
    COUNT EQU $-DT1
    DT2 DW '1','2','AB'
    DT3 DW DT2
    DT4 DW $-DT2
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
    
    MOV AH,02H;二号功能显示DT1中的1和A
    MOV DL,DT1
    INT 21H
    MOV DL,DT1[2]
    INT 21H


    MOV AH,4CH;结束
    INT 21H
       
CODES ENDS
END START
