@ECHO OFF
COLOR 0A
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############# B642File.bat #############
ECHO # Converting data sequence             #
ECHO #           encoded in Base64          #
ECHO #               to a file continuously #
ECHO #                                      #
ECHO #   1st release: 2019-05-12            #
ECHO #   Last update: 2019-07-08            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET extTmp=.b64
SET extLog=.log
TITLE %tScr%

:initiate
SET nameFile=newFile
SET flagOut=0
SET nLine=0
ECHO.

:input
ECHO Paste the file name and content encoded in Base64
SET inCode=
SET /P inCode=
SET inCode=%inCode: =%
SET inCode=%inCode:,=%

IF "%inCode%" EQU "" GOTO input
SET inCode="%inCode:"=%"
SET inCodeInitial="%inCode:"=%..."
IF "%inCodeInitial:~1,3%" EQU "---" SET inCodeInitial="```"
IF "%inCodeInitial:~1,3%" EQU "```" (
  SET /A flagOut=flagOut+1
  IF !flagOut! EQU 1 (
    ECHO File name: %nameFile%
    TITLE %tScr% %nameFile%
    GOTO input
  )
  GOTO decode
) ELSE IF %flagOut% EQU 1 (
  CALL :output
) ELSE IF %inCode% EQU "exit" (
  GOTO eof
) ELSE (
  SET nameFile=%inCode%
)

GOTO input


:output
ECHO %inCode:"=%>>%nameFile%%extTmp%
SET /A nLine=nLine+1
ECHO !nLine! lines input
TITLE %tScr% %nameFile% !nLine!
EXIT /B


:decode
certutil -decode %nameFile%%extTmp% %nameFile%
SET err=%ERRORLEVEL%
IF %err%. EQU 0. (
  ECHO %date% %time%	%tScr%	%err%	%nameFile%>>%tScr%%extLog%
  ECHO Suceeded to create a file %nameFile%.
  TITLE %tScr% %nameFile% created
  DEL %nameFile%%extTmp%
) ELSE (
  ECHO %date% %time%	%tScr%	%err%	%nameFile%>>%tScr%%extLog%
  ECHO Error %err% occured.
  TITLE %tScr% Error%err%
)
ECHO If you want to exit, type "exit" and press Enter key.
GOTO initiate

:eof
ECHO Terminated.
ENDLOCAL
EXIT /B
