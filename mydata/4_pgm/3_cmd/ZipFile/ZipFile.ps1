# Set-PSDebug -Trace 1
$Host.UI.RawUI.ForeGroundColor = "Green"

"############# ZipFile.ps1 ##############"
"# ZIP compressing each files           #"
"#                                      #"
"#   1st release: 2019-07-15            #"
"#   Last update: 2019-07-15            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"
"# PS compressing and shell objects"
"# http://qshino.hatenablog.com/entry/2017/03/16/210106"
"#   Quoted on  : 2019-07-14"
"########################################"

$nameFileScript = (Get-ChildItem $MyInvocation.MyCommand.Path).BaseName
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
$extZip = ".zip"
$extLog = ".log"
$Host.UI.RawUI.WindowTitle = $nameFileScript
$flagCont = 1
$pathFileLog = $dirPathScript + "\" + $nameFileScript + $extLog

$iArg = 0
$numIn = 0
$numOut = 0

# Set option to determine output directory
if (($Args[0] -like "-out*") -And (Test-Path $Args[1].Replace('"', ''))) {
  $pathDirZip = $Args[1]
  $iArg = 2
} else {
  $pathDirZip = (Convert-Path .)
}
Write-Host "`r`nDirectory path to output zip files:`r`n$pathDirZip"

# Set no-continue
if ($Args[$iArg] -ne "nul") {
  $flagCont = 0
}

do {
  $arg = $Args[$iArg]
  if ($arg -eq "nul") {
    # Input src dir and output file
    Write-Host "`r`nEnter the directory path to zip."
    Write-Host "To exit, hit the Enter key w/o any characters."
    $arg = Read-Host
    if (($arg -eq $null) -Or ($arg -eq "")) {
      Write-Host "`r`nTerminated by user.`r`n"
      $strResult = "Terminate(user)"
      break
    }
    if ((Test-Path $arg.Replace('"', '')) -ne $true) {
      Write-Host "`r`nFile not exists.`r`n"
      continue
    }
  } else {
    Write-Host "`r`nThe file/directory to be archived:`r`n$arg`r`n"
  }

  # Set path variables
  $pathDirSrc = $arg.Replace('"', '')
  $nameDirSrc = [System.IO.Path]::GetFileName($pathDirSrc)
  $pathFileZip = $pathDirZip + "\" + $nameDirSrc + $extZip
  ++$numIn

  while ($true) {
    if ((Test-Path $pathDirSrc) -ne $true) {
      Write-Host "The files to be archived not exists.`r`n"
      $strResult = "Failure(source)"
      break
    }

    if ((Test-Path $pathFileZip) -eq $true) {
      Write-Host "The file to output already exists.`r`n"
      $strResult = "Failure(output)"
      break
    }

    # Set ZIP header an empty ZIP file
    "PK"+ [char]5 + [char]6  + ("$([char]0)"*18) | `
    New-Item -Path $pathFileZip -Type File | Out-Null

    # Create a shell object
    $objSh = New-Object -Com Shell.Application

    # Get an empty ZIP file
    $objZip = $objSh.NameSpace($pathFileZip)

    # hash
    $hash = @{}
    $numCnt=0
    foreach($eleDir in ($pathDirSrc | %{Get-Item $_})){
      if ( $hash.ContainsKey($eleDir) ){continue}
      $hash[$eleDir] = $true
      $numCnt++
      $objZip.CopyHere($eleDir.FullName)
    }

    # Wait until all items are archived
    while($true){
      Start-Sleep -milliseconds 400
      if ($numCnt -le $objZip.Items().Count) {
        break
      }
    }

    $strResult = "Success($numCnt)"
    Write-Host "Done archiving.`r`n"

    # Destroy shell application
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($objSh) | Out-Null
    Remove-Variable objSh
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
} while (($($Args[$iArg]) -ne "nul") -Or ($flagCont -eq 1))
