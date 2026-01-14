DATA SEGMENT
       TBL  DB 128,168,203,232,250,255,250,232,203,168,128,88,53,24,6,0,6,24,53,88;正弦波
        COUNT1  EQU  $-TBL
       TBL2  DB  0,255   ; 方波
        COUNT2  EQU  $-TBL2
      
DATA ENDS

STK  SEGMENT
     SSDAT DW 100 DUP(?)
STK  ENDS


CODE SEGMENT
     ASSUME CS:CODE,DS:DATA,SS:STK
START:
         ;初始化及数据段、堆栈段观察记录
          MOV AX, STK
          MOV SS, AX
          MOV SP, 2*100
          
          MOV AX,DATA
          MOV DS,AX
;-------------------------------------------主程序从此开始
       
;键入1输出正弦波；键入2输出方波；键入3输出锯齿波；键入4输出三角波   
          MOV BX,0
          CALL KEYIN
          CMP AL,31H
          JE AGN1
          CMP AL,32H
          JE  AGN2
          CMP AL,33H
          JE AGN3
          CMP AL,34H
          JE AGN4
         
AGN1:;输出一个幅值为5V的正弦波
        MOV BL,0
AGN11:
         MOV DX,290H
         MOV AL,TBL[BX]
         OUT DX,AL
         CALL DELAY
         
         CALL TRAN
         INC BL
         CMP BL,COUNT1
         JNE AGN11
         JMP AGN1

 AGN2:;输出一个方波
         MOV BX,0 
AGN22:
         MOV DX,290H 
         MOV  AL,TBL2[BX]
         OUT DX,AL
         CALL DELAY
         
         CALL TRAN          
         INC BL
         CMP BL,COUNT2
         JNE AGN22
         JMP  AGN2
       ;也可以写成如下形式：
         ;AGN2:
         ;MOV DX,290H 
         ;MOV  AL,0
         ;OUT DX,AL
         ;CALL DELAY
         ;MOV  AL,255
         ;OUT DX,AL
         ;CALL TRAN 
         ;JMP AGN2
       
AGN3:;输出一个峰值为5V的锯齿波形
         MOV BX,0
AGN33:
          MOV DX,290H 
          MOV AL,BL
          OUT DX,AL
          CALL DELAY
          
          CALL TRAN
          INC BL
          CMP AL,255
          JB AGN33
          JMP AGN3
         
AGN4:;输出一个峰值为5V的三角波
    MOV BX,0
AGN41:
          MOV DX,290H 
          MOV AL,BL
          OUT DX,AL
          CALL DELAY
 
         CALL TRAN        
          INC BL
          CMP BL,255
          JB AGN41
AGN42:
          MOV DX,290H 
          MOV AL,BL
          OUT DX,AL
          CALL DELAY
          
          DEC BL 
          CMP BL,0
          JNE AGN42
         JMP AGN4

 

EXIT:
        MOV AH,4CH
        INT 21H
                       
;-------------------------------------------------------------------↓延迟函数

DELAY PROC
           PUSH  BX
           PUSH  CX
           MOV BX,10
NEXT5:    MOV CX,10
NEXT:    LOOP NEXT
           DEC BX
           JNZ NEXT5
           
           POP   CX
           POP   BX
           RET
DELAY    ENDP
;---------------------------------------------------------------------↓键入函数
KEYIN PROC     ; 从键盘输入数字并显示，若不为数字则重新输入
BEG: 
    MOV AH,08H  ;8号功能键入
    INT 21H
    CMP AL,31H
    JB BEG
    CMP AL,37H
    JA BEG
    MOV AH,02H
    PUSH AX
    MOV DL,AL
    INT 21H
    POP AX
    RET
KEYIN ENDP
;-----------------------------------------------------------------------↓跳转函数
TRAN PROC     ; 跳转函数,按q退出，按a输出正弦波，按b输出方波，按c输出锯齿波，按d输出三角波
 
        MOV DL,0FFH
        MOV AH,06H
        INT 21H
          
        CMP AL,'q'
        JNE  JP1
        JMP EXIT
JP1:    CMP AL,'a'
        JNE  JP2
        JMP AGN1
JP2:    CMP AL,'b'
        JNE  JP3
        JMP AGN2
JP3:    CMP AL,'c'
        JNE  JP4
        JMP AGN3
JP4:    CMP AL,'d'
        JNE  JP5
        JMP AGN4
JP5:
RET
TRAN ENDP
;---------------------------------------------------------------
CODE ENDS
END START

    