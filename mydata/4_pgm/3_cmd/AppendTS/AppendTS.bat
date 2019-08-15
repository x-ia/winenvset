@ECHO OFF
COLOR 0A

ECHO ############# AppendTS.bat #############
ECHO # Append the date ^& time               #
ECHO #                    to filename batch #
ECHO #                                      #
ECHO #   1st release: 2019-05-30            #
ECHO #   Last update: 2019-07-13            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET dScr=%~dp0
SET extLog=.log
SET tSearch=.

:option
SET opt=""
SET tSep=
SET arg="%~1-"
IF %arg% NEQ "" (
  IF "%arg:~1,1%" EQU "/" (
    SET opt="%arg:~1,2%"
    SET tSep=%arg:~3,1%
    SHIFT
  )
)
:loop
SET pInput=
CALL :indir %1
SHIFT
IF %pInput: =% EQU "" GOTO eof
IF NOT DEFINED pInput GOTO eof
IF NOT EXIST %pInput% (
  ECHO File not exists.
  GOTO loop
)

CALL :isfile %pInput%
IF %flagFile% EQU 1 GOTO tgtfile


:tgtdir
PUSHD %pInput%
SET dTgt=%pInput%\

SET nLineMax=0
FOR %%A IN (*.*) DO (
  SET /A nLineMax+=1
)
SET nLine=0
FOR %%A IN (*.*) DO (
  CALL :gettime "%%A"
  CALL :divname "%%A"
  CALL :renfile
)
ECHO.
POPD
GOTO loop
EXIT /B


:tgtfile
CALL :getdir %pInput%
PUSHD %dInput%
SET dTgt=
SET /A nLineMax+=1
CALL :gettime %pInput%
CALL :divname %pInput%
CALL :renfile
ECHO.
POPD
GOTO loop
EXIT /B


:isfile
SET tAttr=%~a1
IF "%tAttr:~0,1%" EQU "d" (
  SET flagFile=0
) ELSE (
  SET flagFile=1
)
EXIT /B


:indir
ECHO.
IF "%~1" NEQ "" (
  SET pInput=%1
) ELSE (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO Enter the folder path within files to rename.
  SET /P pInput=folder path= 
)

SET pInput="%pInput%"
SET pInput="%pInput:"=%"
ECHO Input folder:
ECHO %pInput%

IF %pInput: =% EQU "" EXIT /B
ECHO "%pInput%" | FIND /I "\" >NUL
IF ERRORLEVEL 1 SET pInput=%~dp0%pInput%
SET pInput="%pInput:"=%"

EXIT /B


:getdir
SET dInput="%~dp1"
EXIT /B


:gettime
SET tName="%~1"
FOR /f "usebackq delims=" %%i IN (`DIR %dTgt%%tName:^^=^% ^| FINDSTR \/`) DO SET tTs=%%i
SET tDate=%tTs:~0,10%
SET tDate=%tDate:/=%
SET tDate=%tDate:-=%
SET tTime=%tTs:~12,8%
SET tTime=%tTime::=%
IF %opt% EQU "" (
  SET tTime=
)ELSE IF %opt% NEQ "/S" (
  SET tTime=%tTime:~0,4%
)
SET tFTime=%tDate%%tSep%%tTime%
EXIT /B


:divname
SET tName=%~n1
SET tExt=%~x1
SET flag=

:shiftname

EXIT /B


:renfile
ECHO %tName:^^=^%%tExt% -^> %tName:^^=^%_%tFTime:"=%%tExt%
REN "%tName:^^=^%%tExt%" "%tName:^^=^%_%tFTime:"=%%tExt%"
SET err=%ERRORLEVEL%
IF %err% EQU 0 (
  SET /A nLine+=1
)
TITLE %tScr% %nLine%/%nLineMax%
ECHO %date% %time%     %tScr%    %err%    %tName:^^=^%    %tFTime:"=%    %tExt%>>%dScr%\%tScr%%extLog%
EXIT /B


:eof
ECHO Terminated. 
TIMEOUT /T 2
EXIT /B
