@ECHO OFF
COLOR 0A
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############## NWdrv.bat ###############
ECHO # Assigning the network drives         #
ECHO #                      iteration batch #
ECHO #                                      #
ECHO #   Last update: 2019-05-31            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET fList="%1"
SET extLog=.log

IF %fList% EQU "" (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO NetworkPath/Option,DriveLetter/Option,UserName,DomainName
  ECHO Enter the file includes parameters for connecting network folder like above.
  SET /P fList=filepath= 
) ELSE (
  ECHO Input file:
  ECHO %fList%
)

ECHO "%fList%" | FIND /I "\" >NUL
IF ERRORLEVEL 1 SET fList=%~dp0%fList%
SET fList="%fList:"=%"

ECHO Enter your password.
ECHO >nul
ECHO +5LQ+4U92JZa4GPBAx5oHOleFoTpBgFV1uTLS5Phz3ZG+y6P0SdVfBJAHu7+3hyA^
HQAAAFdpbkVudlNldC9Bc3NpZ25EcnYtc3Vic3QuYmF04OmrYSq5eHSOzj+5Szlr^
ICJ1j56sFM5xEvA+Cx1V8qQJlXTdfp6teh+otW4bLTAUL1zIkcb/hu1P1+QGql0q
SET /P pw=P0urwc/QRqNcChrQd1gjzNF7Ap9MMiMQiANAGvn6M262+
CLS

:count
FOR /F "usebackq skip=1 tokens=1-2 delims=," %%a IN (%fList%) DO (
  SET /A nLine=nLine+1
)
SET nLineMax=%nLine%
SET nLine=0

:iterate
FOR /F "usebackq skip=1 tokens=1-5 delims=," %%a IN (%fList%) DO (
  SET /A nLine=nLine+1
  TITLE %tScr% !nLine!/%nLineMax%
  ECHO %%a %%b %%c %%d %%e

  SET tPath="%%~b"
  SET tDrv=%%~c
  SET uid=%%~d
  SET tDomain=%%~e

  SET flag=.
  ECHO "%%a" | FIND /I "#" >NUL
  IF NOT ERRORLEVEL 1 SET flag=#

  IF !flag! EQU # (
    ECHO %date% %time%	%tScr%	Skipped	!tDrv!	!tPath!	!Domain!	!uid!>>%~dpn0%extLog%
    ECHO Skipped %tPath% -^> %tDrv%
  ) ELSE (
    CALL :netuse
  )

)
REM ECHO Total values of errorlevels is %err%
PAUSE
EXIT /B


:netuse
ECHO %tDrv% | FIND /I "/" >NUL
IF NOT ERRORLEVEL 1 (
  CALL :disconnect
) ELSE (
  IF "%tPath:~1,1%." EQU "/." (
    CALL :deldrv
  ) ELSE (
    CALL :connect
  )
)
ECHO %date% %time%	%tScr%	!err!	!tDrv!	!tPath!	!Domain!	!uid!>>%~dpn0%extLog%
EXIT /B


:disconnect
IF %tPath:~1,1%. NEQ \. SET tPath="\%tPath:"=%
IF %tPath:~1,2%. NEQ \\. SET tPath="\%tPath:"=%
IF %tPath:~-2,1%. EQU \. SET tPath="%tPath:~0,-2%
ECHO Disconnecting %tPath%

NET USE %tPath% %tDrv%
SET err=%ERRORLEVEL%
EXIT /B


:deldrv
SET tDrv=%tDrv:~0,1%:
ECHO Deleting %tDrv%

NET USE %tDrv% %tPath%
SET err=%ERRORLEVEL%
EXIT /B


:connect
SET tDrv=%tDrv:~0,1%:
IF %tPath:~1,1%. NEQ \. SET tPath="\%tPath:"=%
IF %tPath:~1,2%. NEQ \\. SET tPath="\%tPath:"=%
IF %tPath:~-2,1%. EQU \. SET tPath="%tPath:~0,-2%"
IF %tDomain%. NEQ . SET tDomain=%tDomain%\
ECHO %tPath% -^> %tDrv%

IF %uid%. EQU . (
  NET USE %tDrv% %tPath%
) ELSE (
  NET USE %tDrv% %tPath% %pw% /USER:%tDomain%%uid%
)
SET err=%ERRORLEVEL%
REM IF %err% EQU 0 (
REM   ECHO   Success
REM ) ELSE (
REM   ECHO   Error: %err%
REM )
EXIT /B
