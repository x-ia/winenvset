# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"
Add-Type -Assembly System.Windows.Forms

"############## SClip.ps1 ###############"
"# Scrap clipboard script               #"
"#                                      #"
"#   1st release: 2019-06-30            #"
"#   Last update: 2019-07-13            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

$filenameScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
# Write-Host $filenameScript
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
# Write-Host $dirPathScript
# $filenameScript = $MyInvocation.MyCommand.Name
# $filenameScript.Substring(0, $filenameScript.LastIndexOf('.'))
$extLog = ".log"
$Host.UI.RawUI.WindowTitle = $filenameScript
$timePause = 1500


function SetFile($arg, $dirPathScript, $filenameScript, $extLog) {
  if ($arg -eq "nul") {
    $dateNow = (Get-Date).ToString("yyyyMMdd")
    $timeNow = (Get-Date).ToString("HHmmss")
    $filePathOut = $dirPathScript + "\" + $filenameScript + "_" + $dateNow + "-" + $timeNow + $extLog
  } else {
    $filePathOut = $arg
  }
  return $filePathOut
}

function GetClip {
#  $strClip = Get-Clipboard -Format Image
#  $strClip = Get-Clipboard -Raw
#  $strClip = Get-Clipboard -TextFormatType Html
#  $strClip = [Windows.Forms.Clipboard]::GetImage()
  $strClip = [Windows.Forms.Clipboard]::GetText()
  return $strClip
}

function ViewClip($strClip) {
  "`r`n`r`n$strClip`r`n"
  $numSizeClip = $strClip.Length
  $numLineClip = 0
  foreach( $strLine in $strClip -split "`r`n" ){
    ++$numLineClip
  }
  Write-Host "`r`nRead $($numSizeClip.ToString("#,#")) chars ($($numLineClip.ToString("#,#")) lines) from the clipboard.`r`n"
#   return $numLineClip
}

function SetOut($strClip, $arg, $arg2) {
  if (($arg -ne "nul") -And ($arg2 -notlike "-nos*")) {
    $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $strOut = "`r`n>>>>> " + $timeStampNow + " >>>>>`r`n" + $strClip + "`r`n<<<<< " + $timeStampNow + " <<<<<`r`n"
  } else {
    $strOut = $strClip
  }
  return $strOut
}

function PutClip($strOut, $filePathOut) {
#   Write-Output "$strOut" >> $filePathOut
#   $strOut.Save($filePathOut)
  $strOut | Out-file -FilePath $filePathOut -Encoding "utf8" -Append
  return $?
}

function EoF($filenameScript, $err) {
  if ("$err" -eq "True") {
    $strResult = "Success"
  } else {
    $strResult = "Failure"
  }
  $Host.UI.RawUI.WindowTitle = "$filenameScript $strResult"
  Write-Host "$filenameScript process has resulted in $strResult."
  Start-Sleep -milliseconds $timePause
}


$filePathOut = SetFile $Args[0] $dirPathScript $filenameScript $extLog
$strClip = GetClip
ViewClip $strClip
$strOut = SetOut $strClip $Args[0] $Args[1]
# $err = PutClip $strClip $filePathOut
$err = PutClip $strOut $filePathOut
if ("$err" -ne "True") {
  $filePathOut = SetFile "nul" $dirPathScript $filenameScript $extLog
  $err = PutClip $strOut $filePathOut
}
EoF $filenameScript $err
