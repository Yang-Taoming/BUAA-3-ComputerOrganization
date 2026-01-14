###############################################################################
# Makefile for project 
###############################################################################

## General options
PROJECT = 
MCU = 8086
COMPILER = "Digital Mars C"
TARGET = Debug
SHELL = C:\WINDOWS\system32\cmd.exe

## Tools general options
ASMFLAGS=/c
CCFLAGS=-g -ms -0 -c
LDFLAGS=/CO /NODEF:SDS

## Processing Tools
CC=dmc.exe
ASM=ml.exe
LD=optlink.exe
#  C:/Users/zhuojianfei/AppData/Local/Temp/d67cfb68263b42b4b0702be06d92d090/8086/Debug/Debug.exe: TOOL=LD
#     C:/Users/zhuojianfei/AppData/Local/Temp/d67cfb68263b42b4b0702be06d92d090/8086/Debug/rtl.obj: TOOL=ASM
#        C:/Users/zhuojianfei/AppData/Local/Temp/d67cfb68263b42b4b0702be06d92d090/8086/rtl.asm

# Build tree:
all:	Debug

Debug:	Debug.exe

Debug.exe:	rtl.obj 
	$(LD) $(LDFLAGS) rtl.obj,Debug.exe

rtl.obj:	../rtl.asm 
	$(ASM) $(ASMFLAGS) ../rtl.asm

# tidy - delete all temporary files which are not involved in the target generation
tidy:

# cleanup - delete all generated files
clean:	tidy
	rm -rf Debug.exe
	rm -rf rtl.obj
