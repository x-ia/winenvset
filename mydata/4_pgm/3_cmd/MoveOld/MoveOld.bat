@ECHO OFF
COLOR 0A
REM SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############# MoveOld.bat ##############
ECHO # Move old files by using date         #
ECHO #                in the filename batch #
ECHO #                                      #
ECHO #   1st release: 2019-06-03            #
ECHO #   Last update: 2019-10-01            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET dScr=%~dp0
SET extLog=.log
SET fList=%~dp0%tScr%-list.txt
REM SET tSearch=_
SET dOld=old
SET nLine=0
SET nLineMove=0
SET nLineMax=0
SET tName1=_

:loop
SET pFolder=
SET pInput=%1
CALL :dInput "%pInput:"=%"
IF "%pFolder:"=%" EQU "" GOTO eof
IF NOT DEFINED pFolder GOTO eof
IF NOT EXIST %pFolder% (
  ECHO File not exists.
  SHIFT
  GOTO loop
)

PUSHD %pFolder%

DIR /A-D-L /B /OE-N %pFolder%>%fList%

FOR /F "delims=" %%A IN (%fList%) DO (
SET /A nLineMax+=1
)

FOR /F "delims=" %%A IN (%fList%) DO (
  CALL :divname "%%A"
  CALL :compare "%%A"
)
ECHO.
POPD
SHIFT
GOTO loop
EXIT /B


:dInput
ECHO.
IF %1 NEQ "" (
  SET pFolder=%1
) ELSE (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO Enter the folder path within files to move old files.
  SET /P pFolder=folder path= 
)

SET pFolder="%pFolder%"
SET pFolder="%pFolder:"=%"
ECHO Input folder:
ECHO %pFolder%

IF %pFolder% EQU "" EXIT /B
ECHO "%pFolder%" | FIND /I "\" >NUL
IF ERRORLEVEL 1 SET pFolder=%~dp0%pFolder%
SET pFolder="%pFolder:"=%"

EXIT /B


:divname
SET tName="%~n1"
SET tExt="%~x1"
SET flag=

REM :shiftname
REM SET tExt=%tName:~-1%%tExt%
REM SET tName=%tName:~0,-1%
REM ECHO "%tExt:"=%"|FIND /I "%tSearch%">NUL
REM IF NOT ERRORLEVEL 1 EXIT /B
REM IF NOT DEFINED tName (
REM   SET tName=%1
REM   SET tExt=
REM   EXIT /B
REM )
REM GOTO shiftname

CALL :rmver %tName:_=..%
EXIT /B

:rmver
SET tName="%~n1%tExt%"
EXIT /B


:compare
SET /A nLine+=1
IF "%tName:"=%_" EQU "%tName1:"=%_" (
  CALL :movefile %1
)
TITLE %tScr% %nLineMove%/%nLine%/%nLineMax%
SET tName1=%tName%
EXIT /B


:movefile
SET tFile=%1
ECHO %tFile:^^=^% -^> %dOld%
IF NOT EXIST "%pFolder:"=%\%dOld%" (
  MKDIR "%pFolder:"=%\%dOld%"
)
MOVE %tFile:^^=^% .\%dOld%
SET err=%ERRORLEVEL%
IF %err%. EQU 0. (
  SET /A nLineMove+=1
)
ECHO %date% %time%	 %tScr%	%err%	%tFile:^^=^%>>%dScr%\%tScr%%extLog%
EXIT /B


:eof
ECHO Terminated. 
PAUSE
REM ENDLOCAL
