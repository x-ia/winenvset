@ECHO OFF
COLOR 0E
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############## setIP.bat ###############
ECHO # Attempting to set IP address starter #
ECHO #                                      #
ECHO #   Remodeling : 2019-05-18            #
ECHO #   Last update: 2019-07-13            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET tScr=setIP
SET fList="%1"

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

ECHO Please click "Yes" button on User Account Control dialog.
powershell start-process %~dp0\%tScr%s.bat %fList% -verb runas

EXIT /B