@ECHO OFF
COLOR 0A

REM ############ ListFileS.bat #############
REM # Listing files                        #
REM #       in the specified directory     #
REM #                         core process #
REM #                                      #
REM #   1st release: 2019-05-12            #
REM #   Last update: 2019-07-13            #
REM #   Author: Y. Kosaka                  #
REM #   See the web for more information   #
REM #   https://qiita.com/x-ia             #
REM ########################################

SET nameDrvSearch=%2
SET drvSearch=%3
SET dirSearch=%4
SET drvSave=%5
SET dirSave=%6
SET optionList=%1
SET nameList=%7

SET nameDrvSearch=%nameDrvSearch:"=%
SET optionList=%optionList:"=%

SET nameFile=%~n0
SET nameAttr=FileAttr
SET namePath=FilePath

SET drvSearch="%drvSearch:~1,1%:"
SET drvSave="%drvSave:~1,1%:"
IF %dirSearch:~1,1%. NEQ \. SET dirSearch="\%dirSearch:"=%"
IF %dirSave:~1,1%. NEQ \. SET dirSave="\%dirSave:"=%"

SET namePathSearch="%nameDrvSearch:"=%\%dirSearch:"=%\"
SET namePathSearch=%namePathSearch:\\\=\%
SET namePathSearch=%namePathSearch:\\=\%
SET namePathSearch="%namePathSearch:"=%\"
SET dateNow=%date:~0,4%%date:~5,2%%date:~8,2%
SET timeNow=%time:~0,2%%time:~3,2%
SET timeNow=%timeNow: =0%
SET nameFileLog=err
SET extFileSave=.txt
SET extFileLog=.log

SET flagList=0
ECHO "%optionList%" | FIND /I "." >NUL
IF NOT ERRORLEVEL 1 (
  SET /A flagList=flagList+1  
  SET namePathSearch=%namePathSearch:\\=\%
) ELSE (
  SET namePathSearch=%namePathSearch:\\=%
  REM SET namePathSearch=%namePathSearch:~0,-2%"
)
SET namePathSearch=%namePathSearch:\=.%

ECHO "%optionList%" | FIND /I "p" >NUL
IF NOT ERRORLEVEL 1 SET /A flagList=flagList+2

SET pathSearch="%drvSearch:"=%%dirSearch:"=%\"
SET pathSave="%drvSave:"=%%dirSave:"=%\"
SET pathSearch=%pathSearch:\\=\%
SET pathSave=%pathSave:\\=\%
SET pathSaveFileAttr="%pathSave:"=%%nameAttr%-%namePathSearch:"=%_%dateNow%-%timeNow%%extFileSave%"
SET pathSaveFilePath="%pathSave:"=%%namePath%-%namePathSearch:"=%_%dateNow%-%timeNow%%extFileSave%"
REM SET fullNameFileLog="%nameFile%-%namePathSearch:"=%_%nameFileLog%%extFileLog%"
SET pathFileLog="%nameList:"=%-%nameFileLog%%extFileLog%"

REM CD /D "%drvSave%\%dirSave%"
REM IF ERRORLEVEL 1 CD /D %~dp0

ECHO %date% %time%	%pathSearch%>>%pathFileLog%

IF %flagList% EQU 2 (
  DIR /S /A /B %pathSearch% 1>> %pathSaveFilePath% 2>> %pathFileLog%
) ELSE IF %flagList% EQU 3 (
  DIR /A /B %pathSearch% 1>> %pathSaveFilePath% 2>> %pathFileLog%
) ELSE IF %flagList% EQU 0 (
  DIR /S /A-L /T:W /4 %pathSearch% 1>> %pathSaveFileAttr% 2>> %pathFileLog%
) ELSE IF %flagList% EQU 1 (
  DIR /A-L /T:W /4 %pathSearch% 1>> %pathSaveFileAttr% 2>> %pathFileLog%
)
EXIT /B