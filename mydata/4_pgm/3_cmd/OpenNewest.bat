REM @ECHO OFF
SET pFile=S:\PJ
SET tFile=%~n0

FOR /f "DELIMS=" %%A IN ('DIR /A-D-L /B /O-N %pFile%\%tFile%*') DO SET tFileNew=%%A
ECHO %tFileNew%

START %pFile%\%tFileNew%
