$Host.UI.RawUI.ForeGroundColor = "Green"
$dirPathScript = Split-Path $MyInvocation.MyCommand.Path -Parent
. "$dirPathScript\sdky.ps1"

"############# IndMPtr.ps1 ##############"
"# Change the setting in Control Panel  #"
"#         to show the location         #"
"#                 of the mouse pointer #"
"#                                      #"
"#   1st release: 2019-08-10            #"
"#   Last update: 2019-08-19            #"
"#   Author: Y. Kosaka                  #"
"#   See the web for more information   #"
"#   https://qiita.com/x-ia             #"
"########################################"

if ((Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
  -Name UserPreferencesMask).UserPreferencesMask[1] -lt 64) {
  control -name Microsoft.Mouse
  sleep -Milliseconds 200
  Send-Keys "+{TAB}" -ProcessName "RunDLL32" -Wait 50
  Send-Keys "$("{LEFT}" * 6)" -ProcessName "RunDLL32" -Wait 50
  Send-Keys "$("{RIGHT}" * 2)" -ProcessName "RunDLL32" -Wait 50
  Send-Keys "%s" -ProcessName "RunDLL32" -Wait 50
  Send-Keys "{Enter}" -ProcessName "RunDLL32" -Wait 50
  Write-Host "`r`nChanging the setting has done."
} else {
  Write-Host "`r`nNo need to change the settings."
}

Start-Sleep -Milliseconds 200
for ($i=0; $i -lt 3; $i++) {
  Send-Keys "^" -Wait 50
}
Start-Sleep -Milliseconds 1000
