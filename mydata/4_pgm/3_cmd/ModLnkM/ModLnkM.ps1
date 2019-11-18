$Host.UI.RawUI.ForeGroundColor = "Green"

 "############# ModLnkM.ps1 ##############"
 "# Replace the target of shortcuts      #"
 "#                     multiple edition #"
 "#                                      #"
 "#   1st release: 2019-07-24            #
 "#   Remodeling : 2019-10-26            #"
 "#   Last update: 2019-11-09            #"
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
$flagOpt = 1
$arrFlag = 7,5,3,2
$strSearch = $null
$strReplace = $null
$iArg = 0
$i = 0
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

  if (($Args[$iArg] -like "-*conv*") -Or ($Args[$iArg] -like "-*criteri*")) {
    $pathTableConv = $Args[$($iArg + 1)]
    $iArgOffset = 2
  }
  $iArg += $iArgOffset
}

if ($flagOpt -le $arrFlag[3]) {
  $flagOpt *= $arrFlag[0] * $arrFlag[1] * $arrFlag[2]
}

  $pathListFile = $Args[$iArg]
  if ( $pathListFile -eq "nul") {
    Write-Host "`r`nEnter the path of the list file of shortcut files to modify the link target."
    Write-Host "To exit, hit the Enter key w/o any characters."
    $pathListFile = Read-Host
    if (($pathListFile -eq $null) -Or ($pathListFile -eq "")) {
      Write-Host "`r`nTerminated by user.`r`n"
      break
    }
  } else {
    Write-Host "`r`nThe list file to be processed:`r`n$pathListFile`r`n"
  }
  $listFile = (Import-Csv $pathListFile -Encoding Default -Delimiter "`t" | `
    Where-Object {$_.FullName -like "*.lnk"} | `
    Select-Object -Property "FullName" `
    )
  $numAll = @($listFile).Length

  if ($pathTableConv.Length -le 7) {
    Write-Host "`r`nEnter the path of the list file of keywords to search & replace targets for."
    Write-Host "To exit, hit the Enter key w/o any characters."
    $pathTableConv = Read-Host
    if (($pathTableConv -eq $null) -Or ($pathTableConv -eq "")) {
      Write-Host "`r`nTerminated by user.`r`n"
      break
    }
  } else {
    Write-Host "`r`nThe list file of search criteria :`r`n$pathTableConv`r`n"
  }
  $tableConv = (Get-Content $pathTableConv -Encoding Default | `
    ConvertFrom-CSV -header keySearch,keyReplace,flagOpt `
    -Delimiter "`t")

for ($i=0; $i -lt $numAll; $i++) {
  $pathFile = $listFile[$i].Fullname

  if ((Test-Path $pathFile.Replace('"', '')) -ne $true) {
#    Write-Host "The file to be modified not exists.`r`n"
    continue
  }

  if ((Get-Item $pathFile).Extension -ne ".lnk") {
#    Write-Host "`r`nFile not a shortcut file.`r`n"
    continue
  }

  ++$numIn

    $flagChg = 1

    $objSh = New-Object -ComObject WScript.Shell
    $objLnk = $objSh.CreateShortcut($pathFile)  ## Open the lnk

    $pathTarget = $objLnk.TargetPath
    $strArgs = $objLnk.Arguments
    $pathWork = $objLnk.WorkingDirectory

    Write-Host "Current target: $pathTarget"

    $timeStampNow = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $strLog = $pathTarget + "`t" + $strArgs + "`t" + $pathWork

    for ($j=0; $j -lt @($tableConv).Length; $j++) {
      $strSearch = $tableConv[$j].keySearch
      $strReplace = $tableConv[$j].keyReplace
      if ( [int]::TryParse($tableConv[$j].flagOpt, [ref]$null) ) {
        $flagOpt = $tableConv[$j].flagOpt
      }

      if ($flagOpt % $arrFlag[0] -eq 0) {
        if ($flagOpt % $arrFlag[3] -eq 0) {
          Write-Host "$strSearch, $strReplace"
          $tmp = $pathTarget -ireplace $strSearch, $strReplace
        } else {
          $tmp = $pathTarget -ireplace [regex]::escape($strSearch), $strReplace
        }
        if ($tmp -ne $pathTarget) {
          $flagChg *= $arrFlag[0]
          $pathTarget = $tmp  ## Re-enter
        }
      }

      if ($flagOpt % $arrFlag[1] -eq 0) {
        if ($flagOpt % $arrFlag[3] -eq 0) {
          $tmp = $strArgs -ireplace $strSearch, $strReplace
        } else {
          $tmp = $strArgs -ireplace [regex]::escape($strSearch), $strReplace
        }
        if ($tmp -ne $strArgs) {
          $flagChg *= $arrFlag[1]
          $strArgs = $tmp  ## Re-enter
        }
      }

      if ($flagOpt % $arrFlag[2] -eq 0) {
        if ($flagOpt % $arrFlag[3] -eq 0) {
          $tmp = $pathWork -ireplace $strSearch, $strReplace
        } else {
          $tmp = $pathWork -ireplace [regex]::escape($strSearch), $strReplace
        }
        if ($tmp -ne $pathWork) {
          $flagChg *= $arrFlag[2]
          $pathWork = $tmp  ## Re-enter
        }
      }
    }

    if ($flagChg -ne 1) {
      Write-Host "Shortcut file: $pathFile"
      $pathBak = $pathFile + $extBak
      Move-Item $pathFile $pathBak  ## Rename the original before rewriting
      Copy-Item $pathBak $pathFile  ## Copy the new before rewriting

      $objLnk.TargetPath = $pathTarget  ## Make changes
      $objLnk.Arguments = $strArgs  ## Make changes
      $objLnk.WorkingDirectory = $pathWork  ## Make changes
      $objLnk.Save()  ## Save

      $strLog += "`t" + $pathTarget + "`t" + $strArgs + "`t" + $pathWork
      "$timeStampNow`t$nameFileScript`t$pathFile`t$strLog" | `
        Out-File $pathFileLog -Encoding Default -Append
      Write-Host "New target: $pathTarget"
      Write-Host "New arguments: $strArgs"
      Write-Host "New working directory: $pathWork`r`n"
#      Write-Host "Done modifying the target of a shortcut file.`r`n"
      ++$numOut
    } else {
      Write-Host "No required for modifying the shortcut file.`r`n"
    }

    $Host.UI.RawUI.WindowTitle = "$nameFileScript $numOut/$numIn/$numAll"

}
Start-Sleep -milliseconds $timePause
