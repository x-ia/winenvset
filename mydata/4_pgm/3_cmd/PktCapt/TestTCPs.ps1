Param( [string]$strHost, [int]$intPort )
Test-NetConnection -ComputerName $strHost -Port $intPort
