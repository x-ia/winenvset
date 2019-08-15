@ECHO OFF
COLOR 0B
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############## setIPs.bat ##############
ECHO # Attempting to set IP address         #
ECHO #                      iteration batch #
ECHO #                                      #
ECHO #   1st release: 2019-05-12            #
ECHO #   Last update: 2019-07-13            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=%~n0
SET fList="%1"
SET nLine=0
SET tBak=bak
SET extLog=.log
SET extBak=.txt

IF %fList% EQU "" (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO NIC,HostIP/DHCP,Netmask,DefaultGW,DNS1,DNS2
  ECHO Enter the file includes IP address parameters like above.
  SET /P fList=filepath= 
) ELSE (
  ECHO Input file:
  ECHO %fList%
)
ECHO.

ECHO "%fList%" | FIND /I "\" >NUL
IF ERRORLEVEL 1 SET fList=%~dp0%fList%
SET fList="%fList:"=%"

:backup
ECHO %date% %time%	^>netsh interface ip dump>>%~dpn0-%tBak%%extLog%
netsh interface ip dump>>%~dpn0-%tBak%%extLog%
netsh interface ip dump>>%~dpn0-%tBak%%extBak%

:count
FOR /F "usebackq skip=1 tokens=1-2 delims=," %%a IN (%fList%) DO (
  SET /A nLine=nLine+1
)
SET nLineMax=%nLine%
SET nLine=0

:iterate
FOR /F "usebackq skip=1 tokens=1-7 delims=," %%a IN (%fList%) DO (
  SET /A nLine=nLine+1
  TITLE %tScr% !nLine!/%nLineMax%
  ECHO %%a %%b %%c %%d %%e %%f %%g

  SET flag=.
  ECHO "%%a" | FIND /I "#" >NUL
  IF NOT ERRORLEVEL 1 SET flag=#

  IF !flag! EQU # (
    ECHO %date% %time%	%tScr%	Skipped	%%a	%%b	%%c	%%d	%%e	%%f	%%g>>%~dpn0%extLog%
    ECHO %date% %time%	Skipped
  ) ELSE (
    ECHO Now attempting...
    CALL %~dp0%tScr%S.bat "%%b" %%c %%d %%e %%f %%g
    SET return=!ERRORLEVEL!
    ECHO %date% %time%	%tScr%	!return!	%%a	%%b	%%c	%%d	%%e	%%f	%%g>>%~dpn0%extLog%
    ECHO %date% %time%	Error code: !return!
    IF !return! EQU 0 (
      ECHO Succeeded.
      TITLE %tScr% !nLine!/%nLineMax% Success
      GOTO showconf
    )
    ECHO.
  )

)
ECHO Failed.
TITLE %tScr% !nLine!/%nLineMax% Failure

netsh -f %~dpn0-%tBak%%extBak%
DEL %~dpn0-%tBak%%extBak%

:showconf
netsh interface ip show config

:eof
TIMEOUT /T -1
ENDLOCAL
