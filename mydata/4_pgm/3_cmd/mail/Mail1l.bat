@ECHO OFF
SET dirBase=Z:\mydata\1_doc\4_mail
SET dirTmp1=toGrep
SET dirTmp2=toSort
SET aSakura=Z:\mydata\4_pgm\1_bin\sakura\sakura.exe
SET dsakuraMac=Z:\mydata\5_env\4_conf\sakura

SET tMon=%date%
SET tMon=%tMon:~0,4%%tMon:~5,2%
SET dirTmp2=%tMon%

PUSHD %dirBase%
ECHO.>>.\tome_old.log + .\tome.log
CALL :mkfldr %dirTmp1%
CALL :mkfldr %dirTmp2%
MOVE .\*.txt \dirTmp1%\

CALL Z:\mydata\4_pgm\3_cmd\SakuraGrape\SakuraGrape.bat Z:\mydata\4_pgm\3_cmd\SakuraGrape\grepmail.csv
PING -n 2 localhost

MOVE .\%dirTmp1%*.txt .\%dirTmp2%\

:movefile
MOVE /Y Z:\mydata\4_pgm\3_cmd\SakuraGrape\tome.txt .\tome.log
IF ERRORLEVEL 1 (
  COLOR 4F
  ECHO File Move Error
  PAUSE
  GOTO movefile
)


START %aSakura% -M=%dSakuraMac%\ReLine.mac .\tome.log
POPD
EXIT /B

:mkfldr
IF NOT EXIST "%1" (
  MKDIR "%1"
)
EXIT /B
