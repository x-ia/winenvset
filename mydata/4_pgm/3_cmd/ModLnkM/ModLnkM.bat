@ECHO OFF
PowerShell -ExecutionPolicy Unrestricted -File %~dpn0.ps1 %* "nul" "nul"
EXIT /B