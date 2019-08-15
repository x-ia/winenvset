@ECHO OFF
COLOR 0A
REM SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############## FSgrep.bat ##############
ECHO # grep batch by using findstr commamd  #
ECHO #                                      #
ECHO #   Last update: 2019-06-15            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET dScr=%~dp0
SET extOut=.txt
SET extLog=.log
SET tFile=*.*
SET nLoop=0

SET pFolder=
CALL :dInput %1
IF %pFolder% EQU "" GOTO eof
IF NOT DEFINED pFolder GOTO eof
IF NOT EXIST %pFolder% (
  ECHO File not exists.
  GOTO loop
)

CD /D %pFolder%
CALL :fInput

:loop
CALL :setflag
IF "%flag%" EQU "q" GOTO eof
CALL :setopt
CALL :setkey
CALL :setout
CALL :grep
CALL :getresult
CALL :putlog
ECHO.
SET tFilePrev=%tFile%
SET tFile=%fResult%
GOTO loop

PAUSE
EXIT /B


:dInput
ECHO.
IF "%1" NEQ "" (
  SET pFolder=%1
) ELSE (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO Enter the folder path to grep.
  SET /P pFolder=folderpath= 
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


:fInput
ECHO.
ECHO Enter the file to grep.
ECHO Wildcards is available. ( Default value= *.* )
SET /P tFile=file= 
EXIT /B


:setflag
ECHO.
SET flag=0
ECHO Enter option below. (Multiple option possible)
IF %nLoop% EQU 0 (
  ECHO To include sub directories, enter "s".
  ECHO To change the code page into "UTF-8", enter "u".
) ELSE (
  ECHO To undo the previous , enter "z".
)
ECHO To use regular expressions, enter "r".
ECHO To construe as leteral, enter "L".
ECHO To search w/o case-sensitive, enter "i".
ECHO To search lines that do not match the condition, enter "v".
ECHO To exit, enter "q"
SET /P flag=Choice= 
ECHO.
:xclflag
ECHO "%flag%" | FIND /I "r" >NUL
IF NOT ERRORLEVEL 1 (
  ECHO "%flag%" | FIND /I "l" >NUL
  IF NOT ERRORLEVEL 1 (
    ECHO Entered option is invalid, because "r" ^& "L" are exclusive.
    GOTO setflag
  )
)
EXIT /B


:setopt
IF %nLoop% EQU 0 (
  ECHO "%flag%" | FIND /I "s" >NUL
  IF NOT ERRORLEVEL 1 (
    SET optSD=/S 
    ECHO Including sub directories: ON
  ) ELSE (
    SET optSD=
    ECHO Including sub directories: OFF
  )
  ECHO "%flag%" | FIND /I "u" >NUL
  IF NOT ERRORLEVEL 1 (
    CHCP 65001
    ECHO Code page: UTF-8
  )
)

ECHO "%flag%" | FIND /I "z" >NUL
IF NOT ERRORLEVEL 1 (
  SET tFile=%tFilePrev% 
  ECHO Undo (%tFilePrev%^)
)

ECHO "%flag%" | FIND /I "r" >NUL
IF NOT ERRORLEVEL 1 (
  SET optRE=/R 
  ECHO Regular expression: ON
) ELSE (
  SET optRE=
  ECHO Regular expression: OFF
)

ECHO "%flag%" | FIND /I "l" >NUL
IF NOT ERRORLEVEL 1 (
  SET optL=/L 
  ECHO Literal: ON
) ELSE (
  SET optL=
  ECHO Literal: OFF
)

ECHO "%flag%" | FIND /I "i" >NUL
IF NOT ERRORLEVEL 1 (
  SET optCS=/I 
  ECHO Case-sensitive: OFF
) ELSE (
  SET optCS=
  ECHO Case-sensitive: ON
)

ECHO "%flag%" | FIND /I "v" >NUL
IF NOT ERRORLEVEL 1 (
  SET optInv=/V 
  ECHO Not match the condition: ON
) ELSE (
  SET optInv=
  ECHO Not match the condition: ON
)

ECHO.
EXIT /B


:setout
SET dateNow=%date:~0,4%%date:~5,2%%date:~8,2%
SET timeNow=%time:~0,2%%time:~3,2%%time:~6,2%
SET timeNow=%timeNow: =0%
SET fResult=%~dp0%tScr%-result_%dateNow%_%timeNow%%extOut%
SET fLog=%~dp0%tScr%%extLog%
EXIT /B


:setkey
ECHO Enter the keyword to grep.

ECHO "%flag%" | FIND /I "r" >NUL
IF NOT ERRORLEVEL 1 (
  ECHO 	. 	Wildcard: any character
  ECHO 	* 	Repeat: zero or more occurrences of the previous character or class
  ECHO 	\^ 	Line position: beginning of the line
  ECHO 	$ 	Line position: end of the line
  ECHO 	[class] 	Character class: any one character in a set
  ECHO 	[^class] 	Inverse class: any one character not in a set
  ECHO 	[x-y] 	Range: any characters within the specified range
  ECHO 	\x 	Escape: literal use of a metacharacter x
  ECHO 	\^<string 	Word position: beginning of the word
  ECHO 	string^> 	Word position: end of the word
  ECHO.
)

SET tKey=
SET /P tKey=keyword= 
IF NOT DEFINED tKey GOTO setkey
IF "%tKey: =%" EQU "" GOTO setkey
SET tKey="%tKey:"=\^"%"
EXIT /B


:grep
FINDSTR %optSD%%optRE%%optCS%%optL%%optInv% %tKey% %tFile%>>"%fResult%"
SET /A nLoop+=1
EXIT /B


:getresult
FOR /F %%I IN ('FIND /C ":" ^< "%fResult%"') DO SET nLine=%%I
ECHO %nLine% lines match.
TITLE %tScr% %nLoop%filt %nLine%lines
REM START /MIN CALL "%fResult%"
START "" "%fResult%"
EXIT /B


:putlog
REM ECHO %date% %time%	%nLine%	%pFolder%	%tFile%	%flag%	%tKey%
ECHO %date% %time%	%tScr%	%nLine%	%pFolder%	%tFile%	%flag%	%tKey%>>%fLog%
EXIT /B


:eof
ECHO Terminated. 
PAUSE
REM ENDLOCAL
EXIT /B
