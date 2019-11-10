Param( $pathImg )
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
PUSHD $dirPathScript
$result = .\WinOCR.ps1 -Path $pathImg
$result.Text | Out-File "$pathImg.txt"
