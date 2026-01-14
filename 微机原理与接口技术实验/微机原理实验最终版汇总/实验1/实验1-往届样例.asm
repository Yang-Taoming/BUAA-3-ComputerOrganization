DATA SEGMENT
    TEN DB 'TENTH:$'
    ONE DB 'ONETH:$'
    NUM DB 'NUMBER:$'
    TABLE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
    NUMBR DB 5 DUP(?)
DATA ENDS
 
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX
    ;读入第一位数字
    MOV DX,OFFSET TEN
    MOV AH,09H
    INT 21H                     ;显示提示一
    READIN1:                    ;输入第一位数字
        MOV AH,08H
        INT 21H
        CMP AL,'0'              ;判断是否小于0
        JB READIN1
        CMP AL,'9'              ;判断是否大于9
        JA READIN1
        MOV AH,02H
        MOV DL,AL
        INT 21H                 ;是0-9则回显
        SUB AL,30H              ;变为数字
        MOV SI,OFFSET NUMBR
        MOV [SI],AL
    INC SI
 
    MOV AH,02H
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H                     ;输出回车换行
 
    ;读入第二位数字
    MOV DX,OFFSET ONE
    MOV AH,09H
    INT 21H                     ;显示提示二
    READIN2:                    ;输入第二位数字
        MOV AH,08H
        INT 21H
        CMP AL,'0'              ;判断是否小于0
        JB READIN2
        CMP AL,'9'              ;判断是否大于9
        JA READIN2
        MOV AH,02H
        MOV DL,AL
        INT 21H                 ;是0-9则回显
        SUB AL,30H              ;变为数字
        MOV [SI],AL
     
    MOV AH,02H
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H                     ;输出回车换行
     
    MOV DX,OFFSET NUM
    MOV AH,09H
    INT 21H                     ;显示提示三
 
    MOV SI,OFFSET NUMBR             ;显示第一位数字
    MOV DL,[SI]
    ADD DL,30H
    MOV AH,02H
    INT 21H
    INC SI
 
    MOV AH,02H
    MOV DL,20H
    INT 21H                     ;空格
 
    MOV DL,[SI]                 ;显示第二位数字
    ADD DL,30H
    MOV AH,02H
    INT 21H
 
    MOV AH,02H
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H                     ;输出回车换行
 
    MOV DX,28FH
    MOV AL,10001010B            ;A输出，B输入，C高输入，C低输出
    OUT DX,AL
 
DISP:
    ;低位
    MOV DX,288H             ;A端口
    MOV BX,OFFSET TABLE    ;列表首地址
    MOV SI,OFFSET NUMBR         ;第一个数字
    MOV AL,[SI]
    INC SI                  ;指向第二个数字
    XLAT                    ;查表
    OUT DX,AL               ;写入8255
     
    MOV DX,28AH             ;C端口
    MOV AL,01B              ;选择第一位
    OUT DX,AL               
    CALL DELAY              ;延时
     
    MOV DX,288H             ;A端口
    MOV AL,0                ;什么也不输出
    OUT DX,AL               ;写入8255
    ;第二位
    MOV DX,288H             ;A端口
    MOV AL,[SI]
    XLAT
    OUT DX,AL               ;写入8255
     
    MOV DX,28AH             ;C端口
    MOV AL,10B              ;选择第二位
    OUT DX,AL
    CALL DELAY              ;延时
     
    MOV DX,288H             ;A端口
    MOV AL,0
    OUT DX,AL               ;写入8255
     
    MOV AH,06H
    MOV DL,0FFH
    INT 21H
    JZ DISP                     ;无按动时继续DISP，按任意键退出
     
CLEAR:
    ;低位
    MOV DX,288H             ;A端口
    MOV AL,0
    OUT DX,AL               ;写入8255
     
    MOV DX,28AH             ;C端口
    MOV AL,01B              ;选择第一位
    OUT DX,AL               
    CALL DELAY              ;延时
       
    ;第二位
    MOV DX,288H             ;A端口
    MOV AL,0
    OUT DX,AL               ;写入8255
     
    MOV DX,28AH             ;C端口
    MOV AL,10B              ;选择第二位
    OUT DX,AL
    CALL DELAY              ;延时
 
    MOV AH,4CH
    INT 21H
    
    DELAY PROC;延迟函数
        MOV AX,5FFH;外循环1535
        DELAY1:
            MOV CX,0FFH;内循环255
        DELAY2:
            LOOP DELAY2
        DEC AX
        CMP AX,0
        JNE DELAY1
        RET
    DELAY ENDP
CODE ENDS
END START