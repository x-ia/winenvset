# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"

"############## ModTS.ps1 ###############"
"# Modiify the timestamp of files batch #"
"#                                      #"
"#   1st release: 2019-07-15            #"
"#   Last update: 2019-07-25            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

$nameFileScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
$extLog = ".log"
$Host.UI.RawUI.WindowTitle = $nameFileScript
$pathFileLog = $dirPathScript + "\" + $nameFileScript + $extLog
$flagCont = 1
$flagCreate = 0
$iArg = 0
$numIn = 0
$numOut = 0
$timeNew = $null

if ($Args[0] -like "-*create*") {
  $flagCreate = 1
  $iArg = 1
}

if (($Args[0] -like "-*time*") -And ($Args[1] -match ".*[0-9].+[-/.][0-9].+[ T]+[0-2][0-9](:[0-5][0-9])+.*")) {
  $timeNew = $Args[1]
  $iArg = 2
}

if ($Args[$iArg] -ne "nul") {
  $flagCont = 0
}

do {
  $arg = $Args[$iArg]
  if ($arg -eq "nul") {
    # Input src dir and output file
    Write-Host "`r`nEnter the file path to modify the timestamp."
    Write-Host "To exit, hit the Enter key w/o any characters."
    $arg = Read-Host
    if (($arg -eq $null) -Or ($arg -eq "")) {
      Write-Host "`r`nTerminated by user.`r`n"
      break
    }
    if ((Test-Path $arg.Replace('"', '')) -ne $true) {
      Write-Host "`r`nFile not exists.`r`n"
      continue
    }
  } else {
    Write-Host "`r`nThe file to be modified:`r`n$arg`r`n"
  }

  $pathFileMod = $arg.Replace('"', '')
  ++$numIn

  while ($true) {
    if ((Test-Path $pathFileMod) -ne $true) {
      Write-Host "The files to be modified not exists.`r`n"
      break
    }

    $timeCreate = $(Get-ItemProperty $pathFileMod).CreationTime.ToString("yyyy-MM-dd HH:mm:ss.fff")
    $timeMod = $(Get-ItemProperty $pathFileMod).LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss.fff")
    Write-Host "Created:  $timeCreate"
    Write-Host "Modified: $timeMod"

    if ($timeNew -eq $null) {
      Write-Host "`r`nEnter the new timestamp"
      $timeNew = Read-Host
    }

    $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")

    if ($flagCreate -eq 1) {
      Set-ItemProperty $pathFileMod -Name CreationTime -Value "$timeNew"
    }
    Set-ItemProperty $pathFileMod -Name LastWriteTime -Value "$timeNew"
    Write-Host "Done modifying the timestamp.`r`n"
    ++$numOut
    break
  }

  "$timeStampNow`t$nameFileScript`t$pathFileMod`t$timeCreate`t$timeMod" | `
  Out-File $pathFileLog -Encoding Default -Append
  $Host.UI.RawUI.WindowTitle = "$nameFileScript $numOut/$numIn"

  if ($Args[$iArg] -ne "nul") {
    ++$iArg
  }
} while (($($Args[$iArg]) -ne "nul") -Or ($flagCont -eq 1))
