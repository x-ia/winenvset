@ECHO ON
COLOR 0A

REM ########### SakuraGrapeS.bat ###########
REM # Grep with Sakura Editor core process #
REM #                                      #
REM #   1st release: 2019-05-20            #
REM #   Last update: 2019-08-25            #
REM #   Author: Y. Kosaka                  #
REM #   See the web for more information   #
REM #   https://qiita.com/x-ia             #
REM ########################################
REM Command line option for Sakura Editor
REM https://sakura-editor.github.io/help/HLP000109.html
REM ########################################

SET aSakura=C:\Program\sakura\sakura.exe

SET dGrep=%2
SET fGrep=%3
REM SET fGrep=%fGrep:?=^?%
SET tOpt=%4
SET tOpt=%tOpt:"=%
SET nCode=%5
SET nCode=%nCode:"=%
SET tKey=%6
SET tKey=%tKey:^^^^=^%
REM SET tKey=%tKey:?=^?%
SET tOut=%7
SET tOut=%tOut:^^^^=^%
SET extLog=.log
SET optGrep=%1

SET dScr=%~dp0

REM SET dateNow=%date:~0,4%%date:~5,2%%date:~8,2%
REM SET timeNow=%time:~0,2%%time:~3,2%
REM SET timeNow=%timeNow: =0%
SET extSave=.txt

ECHO %optGrep% | FIND /I "r" >NUL
IF ERRORLEVEL 1 (
  ECHO %optGrep% | FIND /I "v" >NUL
  IF NOT ERRORLEVEL 1 (
    SET tOpt=%tOpt:U=%
  ) ELSE (
    SET tOpt=%tOpt:U=%U
    ECHO %tOut% | FIND /l "." >NUL
    IF ERRORLEVEL 1 SET tOut="%tOut:"=%%extSave%"
  )
)

ECHO %optGrep% | FIND /I "r" >NUL
IF NOT ERRORLEVEL 1 (
  "%aSakura%" -GREPMODE -GFOLDER=%dGrep% -GOPT=%tOpt% -GFILE=%fGrep% -GCODE=%nCode% -GKEY=%tKey% -GREPR=%tOut%>>"%dScr%%tScr%-%optGrep%%extLog%"
) ELSE (
  ECHO %optGrep% | FIND /I "v" >NUL
  IF NOT ERRORLEVEL 1 (
    START "%aSakura%" -GREPMODE -GFOLDER=%dGrep% -GOPT=%tOpt% -GFILE=%fGrep% -GCODE=%nCode% -GKEY=%tKey%
  ) ELSE (
    SET tOpt=%tOpt:U=%U
    ECHO %tOut% | FIND /I "." >NUL
    "%aSakura%" -GREPMODE -GFOLDER=%dGrep% -GOPT=%tOpt% -GFILE=%fGrep% -GCODE=%nCode% -GKEY=%tKey%>>"%dScr%%tOut:"=%"
  )
)
EXIT /B
