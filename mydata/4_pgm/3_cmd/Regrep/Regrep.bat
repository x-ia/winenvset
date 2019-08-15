@ECHO OFF
cmd.exe /K PowerShell -ExecutionPolicy RemoteSigned -File %~dpn0.ps1 %* "nul" "nul"