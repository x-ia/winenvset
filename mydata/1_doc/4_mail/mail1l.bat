@ECHO OFF
SET dGrep=Z:\mydata\4_pgm\3_cmd\SakuraGrape
SET dBase=Z:\mydata\1_doc\4_mail
SET dTmp1=toGrep
SET dTmp2=toSort
SET fResult=tome.txt

SET tMon=%date%
SET tMon=%tMon:~0,4%%tMon:~5,2%
SET dTmp2%tMon%

PUSHD %dBase%
CALL :mkfldr %dTmp1%
CALL :mkfldr %dTmp2%

MOVE .\*.txt %dTmp1%\
CALL %dGrep%\SakuraGrape.bat %dGrep%\grepmail.csv
PING -n 2 localhost
MOVE .\%dTmp1%\*.txt .\%dTmp2%
%dGrep%\%fResult%
POPD
EXIT /B

:mkfldr
IF NOT EXIST "%1" (
  MKDIR "%1"
)
EXIT /B
