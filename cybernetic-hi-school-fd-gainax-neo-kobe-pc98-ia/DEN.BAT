echo on
echo [>1h
echo off
cls

:OPENNING
cls
IF EXIST o.exe GOTO ST_OPEN
echo  
echo  
echo  
echo 			ドライブ２のディスクが違います。
pause > nul
GOTO OPENNING

:ST_OPEN
o
IF ERRORLEVEL 99 GOTO END
IF ERRORLEVEL 92 GOTO MEMOVF

:HIROKO
IF NOT EXIST a.exe GOTO HIROKO
a
:HIRIKO_END
echo on
echo [>1h
echo off
cls
echo  
echo  
echo  
echo  
echo  
echo  
echo  
echo  
IF ERRORLEVEL 99 GOTO END
IF ERRORLEVEL 92 GOTO MEMOVF
IF ERRORLEVEL  4 GOTO SIZUKA1
IF ERRORLEVEL  3 GOTO SIZUKA0
IF ERRORLEVEL  2 GOTO YURI1
IF ERRORLEVEL  1 GOTO YURI0
IF ERRORLEVEL  0 GOTO END

:YURI0
echo 		ドライブ２に、Ｃディスクを入れてリターンしてね
pause > nul
IF NOT EXIST b.exe GOTO YURI
b 1
GOTO YURI_END

:YURI1
echo 		ドライブ２に、Ｃディスクを入れてリターンしてね
pause > nul
IF NOT EXIST b.exe GOTO YURI
b 2
:YURI_END
echo on
echo [>1h
echo off
cls
echo  
echo  
echo  
echo  
echo  
echo  
echo  
echo  
IF ERRORLEVEL 99 GOTO END
IF ERRORLEVEL 92 GOTO MEMOVF
IF ERRORLEVEL 4  GOTO SIZUKA1
IF ERRORLEVEL 3  GOTO SIZUKA0
IF ERRORLEVEL 0  GOTO END

:SIZUKA0
echo 		ドライブ２に、Ｄディスクを入れてリターンしてね
pause > nul
IF NOT EXIST c.exe GOTO SIZUKA
c 3
GOTO SIZUKAEND

:SIZUKA1
echo 		ドライブ２に、Ｄディスクを入れてリターンしてね
pause > nul
IF NOT EXIST c.exe GOTO SIZUKA
c 4

:SIZUKAEND
IF ERRORLEVEL 99 GOTO END
IF ERRORLEVEL 92 GOTO MEMOVF

:ENDING
e
GOTO END

:MEMOVF
echo on
echo [>1h
echo off
cls
echo  
echo  
echo  
echo  
echo 　メモリのフリーエリアが不足しています。別の立上げディスクが必要です。
echo  
echo  
echo  
echo  
echo  
echo 			Hit any key.
pause > nul
echo on
echo [>1h
echo off
cls
echo  
echo  
echo 	Ｃディスクのフリーエリアを利用して立ち上げ用ディスクを作製します。
echo  
echo  
echo  
echo 	ドライブ１にＭＳ−ＤＯＳ、ドライブ２にＣディスクを入れて
echo 		Ｂ：ＮＥＷとタイプし、リターンして下さい。
echo  
echo  
echo  
echo  

GOTO END

:END
