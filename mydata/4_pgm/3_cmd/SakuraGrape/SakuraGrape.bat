@ECHO OFF
COLOR 0B
REM SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ########### SakuraGrape.bat ############
ECHO # Grep with Sakura Editor              #
ECHO #                      iteration batch #
ECHO #                                      #
ECHO #   1st release: 2019-05-20            #
ECHO #   Last update: 2019-08-25            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET fList="%1"
SET extLog=.log
SET extLock=.lock

:inFile
IF %fList% EQU "" (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO ModeOption,SearchDirectory,SearchFile,GrepOption,Encoding,FindKeyword,OutputFile,ReplaceKeyword
  ECHO Enter the file includes parameters for listing up files like above.
  SET /P fList=filepath= 
) ELSE (
  ECHO Input file:
  ECHO %fList%
)

ECHO "%fList%" | FIND /I "\" >NUL
IF ERRORLEVEL 1 SET fList=%~dp0%fList%
SET fList="%fList:"=%"

COPY /Y %fList% "%fList:"=%%extLock%">NUL

:count
SET nLine=0
FOR /F "usebackq skip=1 tokens=1-2 delims=," %%a IN ("%fList:"=%%extLock%") DO (
  SET /A nLine=nLine+1
)
SET nLineMax=%nLine%
SET nLine=0

REM ECHO %date% %time%	%fList%	%nLineMax%>>"%fList:"=%%extLock%"

:iterate
FOR /F "usebackq skip=1 tokens=1-7 delims=," %%a IN ("%fList:"=%%extLock%") DO (
  SET /A nLine=nLine+1
  CALL TITLE %tScr% %%nLine%%/%nLineMax%

  ECHO "%%a" | FIND /I "#" >NUL
  IF NOT ERRORLEVEL 1 (
    ECHO %date% %time%	Skipped	%%a	%%b	%%c	%%d	%%e	%%f	%%g
    ECHO %date% %time%	%tScr%	Skipped	%%a	%%b	%%c	%%d	%%e	%%f	%%g>>%~dpn0%extLog%
  ) ELSE (
    CALL :callgrep  "%%a" "%%b" "%%c" "%%d" "%%e" "%%f" "%%g"
  )
  IF NOT EXIST "%fList:"=%%extLock%" (
    ECHO Batch list has reset.
    GOTO infile
  )
  ECHO.
)

DEL "%fList:"=%%extLock%"
TIMEOUT /T 1
REM ENDLOCAL
EXIT /B


:callgrep
    ECHO %date% %time%	Start	%1	%2	%3	%4	%5	%6	%7
    ECHO %date% %time%	%tScr%	Start	%1	%2	%3	%4	%5	%6	%7>>%~dpn0%extLog%
    CALL %~dp0%tScr%S.bat %1 %2 %3 %4 %5 %6 %7
    SET return=%ERRORLEVEL%
    IF %return% EQU 0 (
      SET return=Finish
    ) ELSE (
      SET return=Error %return%
    )
    ECHO %date% %time%	%return%	%1	%2	%3	%4	%5	%6	%7
    ECHO %date% %time%	%tScr%	%return%	%1	%2	%3	%4	%5	%6	%7>>%~dpn0%extLog%
EXIT /B
