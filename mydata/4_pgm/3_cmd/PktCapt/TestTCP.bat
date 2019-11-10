@ECHO OFF
COLOR 0E

PowerShell Start-Process %~dpn0s.bat -verb runas -ArgumentList %1,%2

EXIT /B
