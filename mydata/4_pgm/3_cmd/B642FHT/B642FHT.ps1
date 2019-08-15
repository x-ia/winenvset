# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"
Add-Type -Assembly System.Windows.Forms
# Write-Host (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
"############# B642FHT.ps1 ##############"
"# Converting data sequence             #"
"#            encoded in Base64         #"
"#       to real files continuously     #"
"# high-throughput script by PowerShell #"
"#                                      #"
"#   1st release: 2019-07-07            #"
"#   Last update: 2019-07-25            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

$filenameScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
$Host.UI.RawUI.WindowTitle = $filenameScript
$extLog = ".log"
$timePause = 1500


function ChDirWork($arg) {
  if (Test-Path $arg.Replace('"', '')) {
    ChDir $arg
    [System.IO.Directory]::SetCurrentDirectory((Get-Location -PSProvider FileSystem).Path)
  }
}

function GetClip {
  $strClip = [Windows.Forms.Clipboard]::GetText()
  return $strClip
}

function ViewClip($strClip) {
#   "`r`n`r`n$strClip`r`n"
  $numSizeClip = $strClip.Length
  $numLineClip = 0
  foreach( $strLine in $strClip -split "`r`n" ){
    ++$numLineClip
  }
  Write-Host "`r`nRead $($numSizeClip.ToString("#,#")) chars ($($numLineClip.ToString("#,#")) lines) from the clipboard.`r`n"
  return $numLineClip
}

function DivText($strClip, $numLineClip, $filenameScript, $extLog) {
  $strOut = $null
  $flagOut = 0
  $numOut = 0
  $numProgressNext = 0
  $numLineProcessed = 0
  foreach( $strLine in $strClip -split "`r`n" ){
    if (($strLine -like "``````*") -Or ($strLine -like "---*")) {
      $flagOut +=1
      if ($flagOut -eq 1) {
        $fileOut = $strLinePrev
      } elseif ($flagOut -eq 2) {
        $err = DecodeB64 $strOut $fileOut
        PutLog $err $fileOut $filenameScript $extLog
        $numOut += 1
        $strOut = $null
        $flagOut = 0
      }
    } elseif ($flagOut -eq 1) {
      $strOut += $strLine
    } else {
    $strLinePrev = $strLine
    }
    $numLineProcessed += 1
#     $numSizeProcessed += $strLine.Length
    $numProgress = [Math]::Floor(100 * $numLineProcessed / $numLineClip);
    if ($numProgress -ge $numProgressNext) {
      Write-Progress -activity "Processing the text from clipboard" `
      -status "$numProgress % processed" `
      -percentComplete $numProgress `
      -CurrentOperation "$($numLineProcessed.ToString("#,#")) / $($numLineClip.ToString("#,#")) lines, $numOut files created."
      $numProgressNext = $numProgress + 1
    }
#     $numSizeProcessed += 2
  }
}

function DecodeB64($strOut, $fileOut) {
  [System.IO.File]::WriteAllBytes($fileOut, [Convert]::FromBase64String($strOut))
  return $?
}

function PutLog($err, $fileOut, $filenameScript, $extLog) {
  if ("$err" -eq "True") {
    $strResult = "Success"
    Write-Host "Suceeded to create a file $fileOut."
  } else {
    $strResult = "Failure"
    Write-Host "Failed. An error occured."
  }
  $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
  $fileLog = $filenameScript + $extLog
  "$timeStampNow`t$filenameScript`t$strResult`t$fileOut" | `
  Out-File $fileLog -Encoding Default -Append
  $Host.UI.RawUI.WindowTitle = "$filenameScript $strResult"
}

function EoF($timePause) {
  Start-Sleep -milliseconds $timePause
}

ChDirWork $Args[0]
$strClip = GetClip
$numLineClip = ViewClip $strClip
DivText $strClip $numLineClip $filenameScript $extLog
# Write-Host (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
EoF $timePause
