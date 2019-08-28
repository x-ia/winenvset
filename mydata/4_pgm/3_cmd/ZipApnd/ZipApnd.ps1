# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"

############# ZipApnd.ps1 ##############
# ZIP appending                        #
#                                      #
#   1st release: 2019-08-22            #
#   Last update: 2019-08-21            #
#   Author: Y. Kosaka                  #
#   See the web for more information   #
#   https://qiita.com/x-ia             #
########################################
# PS compressing and shell objects
# http://qshino.hatenablog.com/entry/2017/03/16/210106
#   Quoted on  : 2019-07-14
########################################

$nameFileScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
$extZip = ".zip"
$extLog = ".log"
$Host.UI.RawUI.WindowTitle = $nameFileScript
$pathFileLog = $dirPathScript + "\" + $nameFileScript + $extLog
$timePause = 1500
$numIn = 0
$numOut = 0

$pathFileZip = $Args[0]
$iArg = 1

Write-Host "`r`nThe zip file which files archived into:`r`n$pathFileZip"

if ($pathFileZip -ne "nul") {
  if ((Test-Path $pathFileZip) -ne $true) {
    "PK"+ [char]5 + [char]6  + ("$([char]0)"*18) | `
    New-Item -Path $pathFileZip -Type File | Out-Null
  }
} else {
  Write-Host "`r`nNo arguments"
  Exit
}

# Create a shell object
$objSh = New-Object -Com Shell.Application

# Get an empty ZIP file
$objZip = $objSh.NameSpace($pathFileZip)

do {
  $arg = $Args[$iArg]
  if ($arg -ne "nul") {
    if ((Test-Path $arg) -ne $true) {
      Write-Host "`r`nFile not exists.`r`n"
      continue
    }
  } else {
    Write-Host "`r`nFinished."
    break
  }

  # Set path variables
  $pathDirSrc = $arg
  Write-Host "`r`n$pathDirSrc"
  ++$numIn

  while ($true) {
    if ((Test-Path $pathDirSrc) -ne $true) {
      Write-Host "The files to be archived not exists.`r`n"
      $strResult = "Failure(source)"
      break
    }

    # hash
    $hash = @{}
    $numCnt = 0
    foreach($eleDir in ($pathDirSrc | %{Get-Item $_})){
      if ( $hash.ContainsKey($eleDir) ){continue}
      $hash[$eleDir] = $true
      $numCnt++
      $objZip.CopyHere($eleDir.FullName)
    }

    # Wait until all items are archived
    while($true){
      Start-Sleep -milliseconds 500
      if ($numCnt -le $objZip.Items().Count) {
        break
      }
    }

    $strResult = "Success($numCnt)"
    Write-Host "Done archiving."

    ++$numOut
    break
  }

  # Output log
  $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
  "$timeStampNow`t$nameFileScript`t$strResult`t$pathDirSrc" | `
  Out-File $pathFileLog -Encoding Default -Append
  $Host.UI.RawUI.WindowTitle = "$nameFileScript $numOut/$numIn"

  if ($Args[$iArg] -ne "nul") {
    ++$iArg
  }
} while ($($Args[$iArg]) -ne "nul")

# Destroy shell application
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($objSh) | Out-Null
Remove-Variable objSh
Start-Sleep -milliseconds $timePause
