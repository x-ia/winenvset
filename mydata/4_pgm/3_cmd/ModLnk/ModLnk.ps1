$Host.UI.RawUI.ForeGroundColor = "Green"

"############## ModLnk.ps1 ##############"
"# Replace the target of shortcuts      #"
"#                                      #"
"#   1st release: 2019-07-24            #"
"#   Last update: 2019-07-25            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

$nameFileScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
$extLnk = ".lnk"
$extBak = ".bak"
$extLog = ".log"
$Host.UI.RawUI.WindowTitle = $nameFileScript
$pathFileLog = $dirPathScript + "\" + $nameFileScript + $extLog
$flagCont = 1
$flagOpt = 1
$arrFlag = 7,5,3,2
$strSearch = $null
$strReplace = $null
$iArg = 0
$numIn = 0
$numOut = 0
$timePause = 1500

while ($Args[$iArg] -like "-*") {
  $iArgOffset = 1
  if (($Args[$iArg] -like "-*target*") -Or ($Args[$iArg] -like "-*tgt*")) {
    $flagOpt *= $arrFlag[0]
  }
  if (($Args[$iArg] -like "-*argument*") -Or ($Args[$iArg] -like "-*args*")) {
    $flagOpt *= $arrFlag[1]
  }
  if (($Args[$iArg] -like "-*work*") -Or ($Args[$iArg] -like "-*dir*")) {
    $flagOpt *= $arrFlag[2]
  }
  if ($Args[$iArg] -like "-*reg*") {
    $flagOpt *= $arrFlag[3]
  }

  if (($Args[$iArg] -like "-*search*") -Or ($Args[$iArg] -like "-*src*")) {
    $strSearch = $Args[$($iArg + 1)]
    $iArgOffset = 2
  }
  if (($Args[$iArg] -like "-*replace*") -Or ($Args[$iArg] -like "-*dst*")) {
    $strReplace = $Args[$($iArg + 1)]
    $iArgOffset = 2
  }
  $iArg += $iArgOffset
}

if ($Args[$iArg] -ne "nul") {
  $flagCont = 0
}
if ($flagOpt -le $arrFlag[3]) {
  $flagOpt *= $arrFlag[0] * $arrFlag[1] * $arrFlag[2]
}

do {
  $arg = $Args[$iArg]
  if ($arg -eq "nul") {
    Write-Host "`r`nEnter the path of a shortcut file to modify the link target."
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

  $pathFile = $arg.Replace('"', '')
  ++$numIn

  while ($true) {
    if ((Test-Path $pathFile) -ne $true) {
      Write-Host "The files to be modified not exists.`r`n"
      break
    }

    $pathBak = $pathFile + $extBak
    Copy-Item $pathFile $pathBak  ## Get the lnk we want to use as a template
    $objSh = New-Object -ComObject WScript.Shell
    $objLnk = $objSh.CreateShortcut($pathFile)  ## Open the lnk

    $pathTarget = $objLnk.TargetPath
    $strArgs = $objLnk.Arguments
    $pathWork = $objLnk.WorkingDirectory

    Write-Host "Current target: $pathTarget"

    if ($strSearch -eq $null) {
    Write-Host "`r`nEnter the string to search for."
      $strSearch = Read-Host
    }
    if ($strReplace -eq $null) {
    Write-Host "`r`nEnter the string to replace into."
      $strReplace = Read-Host
    }

    $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $strLog = $null

    if ($flagOpt % $arrFlag[0] -eq 0) {
      if ($flagOpt % $arrFlag[3] -eq 0) {
      Write-Host "$strSearch, $strReplace"
        $objLnk.TargetPath = $pathTarget -ireplace $strSearch, $strReplace  ## Make changes
      } else {
        $objLnk.TargetPath = $pathTarget -ireplace [regex]::escape($strSearch), [regex]::escape($strReplace)  ## Make changes
      }
      $strLog += $pathTarget
    }

    if ($flagOpt % $arrFlag[1] -eq 0) {
      if ($flagOpt % $arrFlag[3] -eq 0) {
        $objLnk.Arguments = $strArgs -ireplace $strSearch, $strReplace  ## Make changes
      } else {
        $objLnk.Arguments = $strArgs -ireplace [regex]::escape($strSearch), [regex]::escape($strReplace)  ## Make changes
      }
      $objLnk.Arguments = $strArgs -ireplace [regex]::escape($strSearch), $strReplace  ## Make changes
      $strLog += "`t" + $strArgs
    } else {
      $strLog += "`t"
    }

    if ($flagOpt % $arrFlag[2] -eq 0) {
      if ($flagOpt % $arrFlag[3] -eq 0) {
        $objLnk.WorkingDirectory = $pathWork -ireplace $strSearch, $strReplace  ## Make changes
      } else {
        $objLnk.WorkingDirectory = $pathWork -ireplace [regex]::escape($strSearch), [regex]::escape($strReplace)  ## Make changes
      }
      $strLog += "`t" + $pathWork
    } else {
      $strLog += "`t"
    }

    $objLnk.Save()  ## Save

    Write-Host "Done modifying the target of a shortcut file.`r`n"
    ++$numOut
    break
  }

  "$timeStampNow`t$nameFileScript`t$pathFile`t$strLog`t$strSearch`t$strReplace" | `
  Out-File $pathFileLog -Encoding Default -Append
  $Host.UI.RawUI.WindowTitle = "$nameFileScript $numOut/$numIn"

  if ($Args[$iArg] -ne "nul") {
    ++$iArg
  }
} while (($($Args[$iArg]) -ne "nul") -Or ($flagCont -eq 1))
Start-Sleep -milliseconds $timePause
