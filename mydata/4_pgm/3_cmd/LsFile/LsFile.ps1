# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"

"############## LsFile.ps1 ##############"
"# Listing files                        #"
"#       in the specified directory     #"
"#                        by PowerShell #"
"#                                      #"
"#   1st release: 2019-07-30            #"
"#   Last update: 2019-08-19            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

$nameFileScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
$extOut = ".txt"
$nameOut = "FList-"
$nameErr = "LsErr"
$extLog = ".log"
$extLock = ".lock"
$Host.UI.RawUI.WindowTitle = $nameFileScript
$pathFileList = $Args[0]
$pathFileLog = $dirPathScript + "\" + $nameFileScript + $extLog
$timePause = 1500
$cntProc = 0
$cntSucc = 0

if (-Not (Test-Path $pathFileList)) {
  Write-Host "`r`nOption,SearchDrvName/Cmd,SearchDrv/LockFile,SearchPath,SaveDrive,SavePath,Option"
  Write-Host "Enter the path of a CSV file containing parameters for listing up files like above."
  $pathFileList = Read-Host
  if ($pathFileList -eq $null) {
    $pathFileList = "nul"
  }
  if (-Not (Test-Path $pathFileList)) {
    Write-Host "`r`nFile not found.`r`nTerminated."
    Start-Sleep -milliseconds $timePause
    Exit
  }
} else {
  Write-Host "`r`nCSV file containing parameters for listing up files`r`n$pathFileList`r`n"
}

$pathDirList = Split-Path $pathFileList -Parent
$arrList = Get-Content $pathFileList | `
  ConvertFrom-CSV -header keyOpt,keyLabelSearch,keyDrvSearch,keyPathSearch,keyDrvOut,keyPathOut -Delimiter ","
$pathFileLock = $pathFileList + $extLock
(Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff") | `
  Out-File $pathFileLock -Encoding Default -Append

$pathFileLog = $dirPathScript + "\" + $nameFileScript + `
  "-" + $(Get-ChildItem $pathFileList).BaseName + $extLog
$pathFileErr = $dirPathScript + "\" + $nameErr + `
  "-" + $(Get-ChildItem $pathFileList).BaseName + $extLog

for ($i=0; $i -lt $arrList.Length; $i++) {
  $error.clear()
  $dateNow = (Get-Date).ToString("yyyyMMdd")
  $timeNow = (Get-Date).ToString("HHmmss")
  $timeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")

  $strParams = $arrList[$i].keyOpt + `
    "`t" + $arrList[$i].keyLabelSearch + `
    "`t" + $arrList[$i].keyDrvSearch + `
    "`t" + $arrList[$i].keyPathSearch + `
    "`t" + $arrList[$i].keyDrvOut + `
    "`t" + $arrList[$i].keyPathOut

  ++$cntProc
  $Host.UI.RawUI.WindowTitle = "$nameFileScript $cntSucc/$cntProc"

  "`r`n$strParams`r`n>>>>> " + $timeStamp + " >>>>>" | `
    Out-File $pathFileErr -Append

  if ($arrList[$i].keyOpt -like "*#*") {
    $strResult = "Skipped"
  } elseif (($arrList[$i].keyOpt -like "*cmd*") -Or ($arrList[$i].keyOpt -like "*command*")) {
    if ($arrList[$i].keyDrvSearch.Length -gt 0) {
      $pathFileChk = $pathDirList + "\" + $arrList[$i].keyDrvSearch
    } else {
      $pathFileChk = "nul"
    }
    if (Test-Path $pathFileChk) {
      Write-Host "$timeStamp`tSkipped executing`t$($arrList[$i].keyLabelSearch)"
      Write-Host "`tdue to a lock file`t$($arrList[$i].keyDrvSearch)"
      $strResult = "Skipped"
    } else {
      try {
        $strResult = "Executed"
        Write-Host "$timeStamp`tExecuting`t$strParams"
        "$timeStamp`t$nameFileScript`tExecuting`t$strParams" | `
          Out-File $pathFileLog -Encoding Default -Append
        if (($arrList[$i].keyOpt -like "*cmdlet*") -Or ($arrList[$i].keyOpt -like "*commandlet*")) {
          Invoke-Expression $arrList[$i].keyLabelSearch >> $pathFileErr 2>&1
        } else {
          CMD /C $arrList[$i].keyLabelSearch >> $pathFileErr 2>&1
        }
      } catch {
        $error[0] | Out-String | Out-File "$pathFileErr" -Append
        $strResult = "Error"
      } finally {
        $strResult += "(" + @($error).Length + ")"
      }
    }
  } else {
    if ($arrList[$i].keyOpt -like "*`.*") {
      $optSub = ""
    } else {
      $optSub = "-Recurse"
    }

    if ($arrList[$i].keyDrvSearch.SubString(0,1) -ne "\") {
      $arrList[$i].keyDrvSearch = $arrList[$i].keyDrvSearch.SubString(0,1) + ":"
    }
    $pathDir = $arrList[$i].keyDrvSearch + "\" + $arrList[$i].keyPathSearch
    $pathDir = $pathDir.Replace("\\", "\")
    if ($pathDir.SubString(0,1) -eq "\") {
      $pathDir = "\" + $pathDir
    }

    if ($arrList[$i].keyDrvOut.SubString(0,1) -ne "\"){
      $arrList[$i].keyDrvOut = $arrList[$i].keyDrvOut.SubString(0,1) + ":"
    }
    $pathFileOut = $nameOut + $arrList[$i].keyLabelSearch + "." + `
      $arrList[$i].keyPathSearch.Replace("\", ".") + "." 
    if ($arrList[$i].keyOpt -notlike "*`.*") {
      $pathFileOut = $pathFileOut.SubString(0, $pathFileOut.Length - 1)
    }
    $pathFileOut = $arrList[$i].keyDrvOut + `
      "\" + $arrList[$i].keyPathOut + `
      "\" + $pathFileOut + "_" + $dateNow + `
      "-" + $timeNow + $extOut
    $pathFileOut = $pathFileOut.Replace("\\", "\").Replace("..", ".")
    if ($pathFileOut.SubString(0,1) -eq "\") {
      $pathFileOut = "\" + $pathFileOut
    }

    Write-Host "$timeStamp`tStarted`t$strParams"
    "$timeStamp`t$nameFileScript`tStarted`t$strParams" | `
      Out-File $pathFileLog -Encoding Default -Append
    try {
      $strResult = "Finished"
      $cmdLs = "Get-ChildItem `"$pathDir`" * $optSub -Force 2>> `"$pathFileErr`" `| `
        Select-Object Mode,Length,LastWriteTime,FullName `| `
        ConvertTo-CSV -Delimiter `"`t`" -NoType `| % { `$_ -Replace `'`"`', `"`" } `| `
        Out-File `"`$pathFileOut`" -Encoding Default"
      Invoke-Expression $cmdLs
    } catch {
      $error[0] | Out-String | Out-File "$pathFileErr" -Append
      $strResult = "Error"
    } finally {
      $strResult += "(" + @($error).Length + ")"
    }
  }

  $timeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")

  Write-Host "$timeStamp`t$strResult`t$strParams"
  "$timeStamp`t$nameFileScript`t$strResult`t$strParams" | `
    Out-File $pathFileLog -Encoding Default -Append

  "<<<<< " + $timeStamp + " <<<<<`r`n" | `
    Out-File $pathFileErr -Append

  if (@($error).Length -eq 0) {
    ++$cntSucc
  }

  if (-Not (Test-Path $pathFileLock)) {
    $i = 0
    Write-Host "Batch list has reset."
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff") | `
      Out-File $pathFileLock -Encoding Default -Append
  }
}

$Host.UI.RawUI.WindowTitle = "$nameFileScript $cntSucc/$cntProc"
Remove-Item $pathFileLock
Start-Sleep -milliseconds $timePause
