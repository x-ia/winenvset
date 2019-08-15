@ECHO OFF
COLOR 0B
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO ############# ListFile.bat #############
ECHO # Listing files                        #
ECHO #       in the specified directory     #
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
SET extLog=.log
SET extLock=.lock

:inFile
IF %fList% EQU "" (
  ECHO Current directory = %~dp0
  ECHO.
  ECHO Option,SearchDrvName/Cmd,SearchDrv/LockFile,SearchPath,SaveDrive,SavePath,Option
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
  SET /A nLine+=1
)
SET nLineMax=%nLine%
SET nLine=0
SET nLineSucc=0

REM ECHO %date% %time%	%fList%	%nLineMax%>>"%fList:"=%%extLock%"

:iterate
FOR /F "usebackq skip=1 tokens=1-6 delims=," %%a IN ("%fList:"=%%extLock%") DO (
  SET /A nLine+=1
  TITLE %tScr% !nLineSucc!/!nLine!/%nLineMax%

  SET flag=.
  ECHO "%%a" | FIND /I "c" >NUL
  IF NOT ERRORLEVEL 1 SET flag=c
  ECHO "%%a" | FIND /I "#" >NUL
  IF NOT ERRORLEVEL 1 SET flag=#

  IF !flag! EQU # (
    ECHO !date! !time!	Skipped	%%a	%%b	%%c	%%d	%%e	%%f
    ECHO !date! !time!	%tScr%	Skipped	%%a	%%b	%%c	%%d	%%e	%%f>>%~dpn0%extLog%
  ) ELSE IF !flag! EQU c (
    IF EXIST %%c (
        ECHO !date! !time!	Skipped executing %%a
        ECHO due to a lock file %%c
        ECHO !date! !time!	%tScr%	Skipped	%%a	%%b	%%c>>%~dpn0%extLog%
    ) ELSE (
      ECHO !date! !time!	Execute	%%a	%%b
      ECHO !date! !time!	%tScr%	Execute	%%a	%%b>>%~dpn0%extLog%
      %%b
      SET return=!ERRORLEVEL!
      IF !return! EQU 0 (
        SET return=Done
        SET /A nLineSucc+=1
      ) ELSE (
        SET return=Error !return!
      )
      ECHO !date! !time!	%tScr%	!return!	%%a	%%b>>%~dpn0%extLog%
    )
  ) ELSE (
    ECHO !date! !time!	Start	%%a	%%b	%%c	%%d	%%e	%%f
    ECHO !date! !time!	%tScr%	Start	%%a	%%b	%%c	%%d	%%e	%%f>>%~dpn0%extLog%
    CALL %~dp0%tScr%S.bat "%%a" "%%b" "%%c" "%%d" "%%e" "%%f" %fList%
    SET return=!ERRORLEVEL!
    IF !return! EQU 0 (
      SET return=Finish
      SET /A nLineSucc+=1
    ) ELSE (
      SET return=Error !return!
    )
    ECHO !date! !time!	!return!	%%a	%%b	%%c	%%d	%%e	%%f
    ECHO !date! !time!	%tScr%	!return!	%%a	%%b	%%c	%%d	%%e	%%f>>%~dpn0%extLog%
  )
  IF NOT EXIST "%fList:"=%%extLock%" (
    ECHO Batch list has reset.
    GOTO infile
  )
  ECHO.
)

TITLE %tScr% !nLineSucc!/!nLine!/%nLineMax%
DEL "%fList:"=%%extLock%"
TIMEOUT /T -1
ENDLOCAL
EXIT /B
