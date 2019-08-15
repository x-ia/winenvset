@ECHO OFF
COLOR 0A

REM ############# setIPsS.bat ##############
REM # Attempting to set IP address         #
REM #                         core process #
REM #                                      #
REM #   1st release: 2019-05-12            #
REM #   Last update: 2019-06-22            #
REM #   Author: Y. Kosaka                  #
REM #   See the web for more information   #
REM #   https://qiita.com/x-ia             #
REM ########################################

SETLOCAL ENABLEDELAYEDEXPANSION

SET tNIC=%~1
SET tNIC="%tNIC:"=%"
SET ipHost=%~2
SET ipNMask=%~3
SET ipDGW=%~4
SET ipDNS=%~5
SET ipDNS2=%~6
SET nPing=2
SET nWait=4
SET nCnt=0
SET nCntLim=3
SET return=-2

ECHO "%ipHost%" | FIND /I "d" >NUL
IF NOT ERRORLEVEL 1 GOTO setdhcp

:setstatic
netsh interface ip set address %tNIC% static %ipHost% %ipNMask% %ipDGW%

CALL :test

IF %return%. EQU 0. (
  IF %ipDNS%. NEQ . netsh interface ip set dns %tNIC% static %ipDNS% primary
  IF %ipDNS2%. NEQ . netsh interface ip add dns %tNIC% %ipDNS2%
)

GOTO eof


:setdhcp
netsh interface ip set address %tNIC% dhcp
netsh interface ip set dns %tNIC% dhcp

PING -n %nWait% 127.0.0.1>NUL
CALL :test

GOTO eof


:getaddr
PING -n %nPing% 127.0.0.1>NUL
FOR /f "usebackq delims=" %%i IN (`netsh interface ip show config %tNIC% ^| FINDSTR アドレス`) DO SET ipHost2=%%i
SET ipHost2=%ipHost2:~-15%
FOR /f "usebackq delims=" %%i IN (`netsh interface ip show config %tNIC% ^| FINDSTR デフォルト`) DO SET ipDGW=%%i
SET ipDGW=%ipDGW:~-15%
EXIT /B


:eof
EXIT /B %return%


:test
SET ipHost2=%ipHost%

ECHO "%ipHost%" | FIND /I "d" >NUL
IF NOT ERRORLEVEL 1 CALL :getaddr

:loop
PING -n %nPing% -S %ipHost2% %ipDGW% | FINDSTR TTL
SET return=%ERRORLEVEL%
IF %return%. EQU 0. (
  EXIT /B
) ELSE (
  SET /A nCnt=nCnt+1
  IF %nCnt% NEQ %nCntLim% GOTO loop
)
EXIT /B
