@ECHO OFF
COLOR 0A
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############## cfHash.bat ##############
ECHO # Comparing hash values of the files   #
ECHO #                                      #
ECHO #   Last update: 2019-05-11            #
ECHO #   Author: Y. Kosaka                  #
ECHO #   See the web for more information   #
ECHO #   https://qiita.com/x-ia             #
ECHO ########################################

SET fScr=%~dpn0
SET tScr=%~n0
SET extLog=.log
SET tAlg=SHA1
REM SET tAlg=MD5
REM SET tAlg=SHA256

SET cnt1=0
SET cnt2=0
SET list1=
SET list2=
SET list3=
SET hash1=
SET hash2=
SET hash3=

ECHO Using hash algorithm: %tAlg%

:loop
CALL :infile %1
IF %fInput% EQU "" GOTO eof
IF NOT EXIST %fInput% (
  ECHO File not exists.
  GOTO loop
)
CALL :gethash %fInput%
CALL :getsize %fInput%
CALL :compare
IF "%hash3%" NEQ "" (
  TITLE %tScr% %cnt1%, %cnt2%, 1 files
  GOTO eof
) ELSE IF "%hash2%" NEQ "" (
  TITLE %tScr% %cnt1%, %cnt2% files
) ELSE IF "%hash1%" NEQ "" (
  TITLE %tScr% %cnt1% files
)
SHIFT
GOTO loop


:eof
CALL :putout
ECHO Terminated.
PAUSE
EXIT /B


:infile
ECHO.
IF %1. NEQ . (
  SET fInput="%1"
  ECHO !fInput!
) ELSE (
  SET fInput=
  ECHO Enter the file to compare.
  ECHO (To exit, hit Enter key w/o any characters^)
  SET /P fInput=filepath= 
)
IF !fInput!. EQU . SET fInput=""
SET fInput="!fInput:"=!"
ECHO !fInput!
EXIT /B


:gethash
FOR /f "usebackq delims=" %%i IN (`certutil -hashfile %1 %tAlg% ^| FINDSTR /V :`) DO SET hash=%%i
ECHO %hash%
EXIT /B


:getsize
FOR %%i IN (%1) DO (SET nSize=%%~zi)
ECHO !nSize! bytes
EXIT /B


:compare
IF %cnt1% EQU 0 (
  SET list1=%fInput%
  SET hash1=%hash%
  SET /A cnt1=1
) ELSE IF "%hash%" EQU "%hash1%" (
  SET list1=!list1!	^

%fInput%
  SET /A cnt1=cnt1+1
) ELSE IF %cnt2% EQU 0 (
  SET list2=%fInput%
  SET hash2=%hash%
  SET /A cnt2=1
) ELSE IF "%hash%" EQU "%hash2%" (
  SET list2=!list2!	^

%fInput%
  SET /A cnt2=cnt2+1
) ELSE (
  SET list3=%fInput%
  SET hash3=%hash%
)
EXIT /B


:putout
ECHO.
ECHO %date% %time% %tScr% %tAlg%
ECHO pattern1 %cnt1% files
ECHO %date% %time% %tScr% %tAlg%>>%fScr%%extLog%
ECHO pattern1 %cnt1% files>>%fScr%%extLog%
IF "%hash1%" NEQ "" (
  ECHO !hash1!
  ECHO !list1!
  ECHO.
  ECHO !hash1!>>%fScr%%extLog%
  ECHO !list1!>>%fScr%%extLog%
  ECHO. >>%fScr%%extLog%
)

IF "%hash2%" NEQ "" (
  ECHO pattern2 %cnt2% files
  ECHO !hash2!
  ECHO !list2!
  ECHO.
  ECHO pattern2 %cnt2% files>>%fScr%%extLog%
  ECHO !hash2!>>%fScr%%extLog%
  ECHO !list2!>>%fScr%%extLog%
  ECHO.>>%fScr%%extLog%
)

IF "%hash3%" NEQ "" (
  ECHO pattern3
  ECHO !hash3!
  ECHO !list3!
  ECHO.
  ECHO pattern3>>%fScr%%extLog%
  ECHO !hash3!>>%fScr%%extLog%
  ECHO !list3!>>%fScr%%extLog%
  ECHO.>>%fScr%%extLog%
)

EXIT /B
