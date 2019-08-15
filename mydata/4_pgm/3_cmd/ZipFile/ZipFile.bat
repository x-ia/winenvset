@ECHO OFF
PowerShell -ExecutionPolicy RemoteSigned -File %~dpn0.ps1 %* "nul" "nul"
EXIT /B