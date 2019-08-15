@ECHO OFF
COLOR 0A
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############# Bin2B64.bat ##############
ECHO # Converting file to Base64 sequence   #
ECHO #                                      #
ECHO #   Last update: 2019-05-18            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET extOut=.txt
TITLE %tScr%
SET nFileIn=0
SET nFileOut=0

:loop
CALL :fInput %1
IF %fInput% EQU "" GOTO eof
IF NOT EXIST %fInput% (
  ECHO File not exists.
  GOTO loop
)
CALL :delold
CALL :encode
SHIFT
ECHO.
GOTO loop

:eof
ECHO Terminated. 
PAUSE
ENDLOCAL
EXIT /B


:fInput
ECHO.
IF %1. NEQ . (
  SET fInput="%1"
  ECHO !fInput!
) ELSE (
  SET fInput=
  ECHO Enter the file to encode in Base64.
  ECHO (To exit, hit the Enter key w/o any characters^)
  SET /P fInput=filepath= 
)
IF !fInput!. EQU . SET fInput=""
SET fInput="!fInput:"=!"
REM ECHO !fInput!
EXIT /B


:delold
IF EXIST "%fInput:"=%%extOut%" (
  DEL "%fInput:"=%%extOut%"
)
EXIT /B

:encode
SET /A nFileIn=nFileIn+1
certutil -encode %fInput% "%fInput:"=%%extOut%"
SET err=%ERRORLEVEL%
IF %err%. EQU 0. (
  ECHO Suceeded to encode a file.
  ECHO "%fInput:"=%%extOut%"
  SET /A nFileOut=nFileOut+1
  TITLE %tScr% !nFileOut!/!nFileIn!

  START "" "%fInput:"=%%extOut%"

) ELSE (
  ECHO Error %err% occured.
  TITLE %tScr% !nFileOut!/!nFileIn!
)
EXIT /B
