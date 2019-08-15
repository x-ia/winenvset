# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"
# $objHost = Get-Host
# $objWindow = $objHost.UI.RawUI
# $objWinSize = $objWindow.BufferSize
# $objWinSize.Height = 1024
# $objWinSize.Width = 526
# $objWindow.BufferSize = $objWinSize

"############## Regrep.ps1 ##############"
"# grep script by PowerShell            #"
"#                                      #"
"#   1st release: 2019-06-21            #"
"#   Last update: 2019-07-29            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

# [String[]]$strCredit = ""
# $strCredit += "############## Regrep.bat ##############"
# $strCredit += "# grep script by PowerShell            #"
# $strCredit += "#                                      #"
# $strCredit += "#   Last update: 2019-06-23            #"
# $strCredit += "#   Author: Y. Kosaka                  #"
# $strCredit += "#   See the web for more information   #"
# $strCredit += "#   https://qiita.com/x-ia             #"
# $strCredit += "########################################"

# Write-Host $strCredit[1]
# Write-Host $strCredit[2]
# Write-Host $strCredit[3]
# Write-Host $strCredit[4]
# Write-Host $strCredit[5]
# Write-Host $strCredit[6]
# Write-Host $strCredit[7]
# Write-Host $strCredit[8]


$filenameScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
# Write-Host $filenameScript
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
# Write-Host $dirPathScript
# $filenameScript = $MyInvocation.MyCommand.Name
# $filenameScript.Substring(0, $filenameScript.LastIndexOf('.'))
$extLog = ".log"
$extOut = ".txt"
$qryFile = "*.*"
$cntLoop = 0
$Host.UI.RawUI.WindowTitle = $filenameScript


function SetDir ($arg) {
  :direxists while ($true){
    if($arg -ne $null){
      $qryDir = $arg
    }else{
      Write-Host "`r`nCurrent directory = $dirPathScript"
      Write-Host "`r`nEnter the folder path to grep."
      Write-Host "directory path:"
      $qryDir = Read-Host
    }
    if ($qryDir -eq "") {
      $qryDir = $dirPathScript
    }
    Write-Host "`r`nInput folder:"
    Write-Host $qryDir
    if (Test-Path $qryDir.Replace('"', '')) { break direxists }
    Write-Host "File not exists."
    $arg = $null
  }
  return $qryDir
}


function SetFile {
  Write-Host "`r`nEnter the filename to grep."
  Write-Host "Wildcards is available. ( Default value= *.* )"
  Write-Host "filename:"
  $qryFile = Read-Host
  return $qryFile
}


function SetFlag($cntLoop) {
  $flag=0
  Write-Host "`r`nEnter option below. (Multiple option possible)"
  if ($cntLoop -eq 0) {
    Write-Host "To include sub directories, enter 's'."
    Write-Host "To change the code page into "UTF-8", enter 'u'."
    Write-Host "Not to output filenames, enter 'L'."
  } else {
    Write-Host "To undo the previous , enter 'z'."
  }
  Write-Host "To use regular expressions, enter 'r'."
  Write-Host "To search w/o case-sensitive, enter 'i'."
  Write-Host "To search lines that do not match the condition, enter 'v'."
  Write-Host "To exit, enter 'q'"
  Write-Host "option:"
  $flag = Read-Host
  if ($cntLoop -ne 0) {
    $flag = $flag + "L"
  }
  return $flag
}


function UnDoCnt($flag, $cntLoop) {
  if ($flag -like "*z*") {
    $cntLoop -= 1
  }
  return $cntLoop
}


function UnDoFile($flag, $qryFile, $qryFilePrev) {
  if ($flag -like "*z*") {
    $qryFile = $qryFilePrev
    Write-Host "Undo ($qryFilePrev)"
  }
  return $qryFile
}


function SetOptSD($flag, $cntLoop) {
  if ($cntLoop -eq 0) {
    if ($flag -like "*s*") {
      $optSD = " -recurse"
      Write-Host "Including sub directories: ON"
    } else {
      $optSD = ""
      Write-Host "Including sub directories: OFF"
    }
  } else {
    $optCP = ""
  }
  return $optSD
}

function SetOptCP($flag, $cntLoop) {
  if ($cntLoop -eq 0) {
    if ($flag -like "*u*") {
      $optCP = " -Encoding utf8"
      Write-Host "Code page: UTF-8"
    } else {
      $optCP = " -Encoding default"
      Write-Host "Code page: Shift_JIS"
    }
  } else {
    $optCP = ""
  }
  return $optCP
}

function SetOptRE($flag) {
  if ($flag -like "*r*") {
    $optRE = ""
    Write-Host "Regular expression: ON"
  } else {
    $optRE = " -SimpleMatch"
    Write-Host "Regular expression: OFF"
  }
  return $optRE
}

function SetOptCS($flag) {
  if ($flag -like "*i*") {
    $optCS = ""
    Write-Host "Case-sensitive: OFF"
  } else {
    $optCS = " -CaseSensitive"
    Write-Host "Case-sensitive: ON"
  }
  return $optCS
}

function SetOptInv($flag) {
  if ($flag -like "*v*") {
    $optInv = " -NotMatch"
    Write-Host "Not match the condition: ON"
  } else {
    $optInv = ""
  }
  return $optInv
}


function SetOut {
  $dateNow = (Get-Date).ToString("yyyyMMdd")
  $timeNow = (Get-Date).ToString("HHmmss")
  $fileResult = $dirPathScript + "\" + $filenameScript + "_" + $dateNow + "-" + $timeNow + $extOut
  return $fileResult
}


function SetLog {
  $fileLog = $dirPathScript + "\" + $filenameScript + $extLog
  return $fileLog
}


function SetKey() {
  :keyinput while ($true){
    Write-Host "`r`nEnter the keyword to grep."
    $qryKey = $null
    Write-Host "keyword:"
    $qryKey = Read-Host
    Write-Host $qryKey
    if (($qryKey -ne $null) -And ("$qryKey" -ne "")) { break keyinput }
    Write-Host "Keyword is empty."
  }
  return $qryKey
}


function Grep($flag, $qryKey, $optSD, $qryFile, $optCP, $optRE, $optCS, $optInv, $fileResult) {
#   Write-Host "flag $flag, qryKey $qryKey, optSD $optSD, qryFile $qryFile, optCP $optCP, optRE $optRE, optCS $optCS, optInv $optInv, fileResult $fileResult"
  if ($flag -like "*L*") {
    $optLine = "| Select Line"
  } else {
    $optLine = ""
  }
  $cmdGrep = "Select-String `"$qryKey`" (dir $optSD $qryFile) $optCP $optRE $optCS $optInv $optLine | `
  Select-Object Path,LineNumber,Line | ConvertTo-CSV -Delimiter `"`t`" -NoType | `
  % { `$_ -Replace `'`"`',`"`"} | Out-File -FilePath $fileResult -width 1000"
  Invoke-Expression $cmdGrep
}


function GetResult($fileResult, $cntLoop) {
  $numLine = (Select-String ":" $fileResult).Count
  Write-Host "`r`n $numLine lines match."
  $Host.UI.RawUI.WindowTitle = $filenameScript + " " + $cntLoop +"filts " + $numLine + "lines"
  return $numLine
}


function PutLog($filenameScript, $numLine, $qryDir, $qryFile, $flag, $qryKey, $fileLog) {
  $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
  "$timeStampNow`t$filenameScript`t$numLine`t$qryDir`t$qryFile`t$flag`t$qryKey" | `
  Out-File $fileLog -Encoding utf8 -Append
}


function EoF {
  Write-Host "Terminated by user.`r`nPlease any key."
  Write-Host "`r`n"
  $host.UI.RawUI.ReadKey()
  exit
}



$qryDir = $null
# Write-Host $Args[0]
$qryDir = SetDir $Args[0]
cd $qryDir

$qryFile = SetFile
:regrep while ($true) {
  $flag = SetFlag $cntLoop
  Write-Host "`r`n"
  if ($flag -like "*q*") {EoF}
  $cntLoop = UnDoCnt $flag $cntLoop
  $qryFile = UnDoFile $flag $qryFile $qryFilePrev
  $optSD = SetOptSD $flag $cntLoop
  $optCP = SetOptCP $flag $cntLoop
  $optRE = SetOptRE $flag
  $optCS = SetOptCS $flag
  $optInv = SetOptInv $flag
  $qryKey = SetKey
  $fileResult = SetOut
  $fileLog = SetLog
  Grep $flag $qryKey $optSD $qryFile $optCP $optRE $optCS $optInv $fileResult
  $cntLoop += 1
  $numLine = GetResult $fileResult $cntLoop
  & $fileResult
  PutLog $filenameScript $numLine $qryDir $qryFile $flag $qryKey $fileLog
  $qryFilePrev=$qryFile
  $qryFile=$fileResult
}
