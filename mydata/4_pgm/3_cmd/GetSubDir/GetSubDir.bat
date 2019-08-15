@ECHO OFF
COLOR 0A
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############ GetSubDir.bat #############
ECHO # Getting subfolders                   #
ECHO #                                      #
ECHO #   Last update: 2019-05-18            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET fScr=%~dpn0
SET extOut=.txt
TITLE %tScr%

:loop
CALL :pInput %1
IF %pInput% EQU "" GOTO eof
IF NOT EXIST %pInput% (
  ECHO Specified directory not exists.
  GOTO loop
)

CALL :getsub
SET /A cnt=cnt+1
TITLE %tScr% %cnt%paths 

SHIFT
ECHO.
GOTO loop

:eof
ECHO Terminated. 
PAUSE
ENDLOCAL
EXIT /B


:pInput
ECHO.
IF %1. NEQ . (
  SET pInput="%1"
  ECHO !pInput!
) ELSE (
  SET pInput=
  ECHO Enter the directory to get subfolders.
  ECHO (To exit, hit the Enter key w/o any characters^)
  SET /P pInput=directory path= 
)
IF !pInput!. EQU . SET pInput=""
SET pInput="!pInput:"=!"
ECHO !pInput!
EXIT /B


:getsub
ECHO %date% %time%	%tScr%	%pInput%>>"%fScr:"=%%extOut%"
DIR /B /AD %pInput%>>"%fScr:"=%%extOut%"
ECHO.>>"%fScr:"=%%extOut%"
DIR /AD %pInput%
EXIT /B
