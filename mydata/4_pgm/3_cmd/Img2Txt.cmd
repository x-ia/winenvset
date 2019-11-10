@ECHO OFF
SET ext=.bat

IF "%CD%" EQU "%~dp0" (
  CD /D "%~dpn0"
)

START "%~n0" "%~dpn0\%~n0%ext%" %*
EXIT /B
