SET dateNow=%date:~0,4%%date:~5,2%%date:~8,2%
SET timeNow=%time:~0,2%%time:~3,2%
SET timeNow=%timeNow: =0%
netsh trace start capture=yes CaptureInterface="イーサネット" Ethernet.Type=IPv4 maxSize=100M traceFile=%~dp0%dateNow%%timeNow%.etl
