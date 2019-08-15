@ECHO OFF
PowerShell -ExecutionPolicy RemoteSigned -STA -File %~dpn0.ps1 %* "nul" "nul"
EXIT /B
