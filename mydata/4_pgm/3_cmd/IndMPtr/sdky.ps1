# Cited from
# https://qiita.com/nimzo6689/items/488467dbe0c4e5645745
# on 2019-08-09

Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

<#
.Synopsis
  This function sends key strokes for any running process.
.DESCRIPTION
  This won't send any commands, if you determine no parameters and no process name.
  If only key strokes, send key strokes on the present focus in the active window.
  If only a process name, move the focus into the determined process.
.EXAMPLE
   Send-Keys -KeyStroke "test.%~" -ProcessName "LINE"

  This commands does type "test." and push Enter key with Alt Key for LINE program running.
#>
function Send-Keys
{
    [CmdletBinding()]
    [Alias("sdky")]
    Param
    (
        # Key strokes
        # Determine keystrokes you want to send for application.
        # The following web site shows how to describe key strokes.
        # https://msdn.microsoft.com/ja-jp/library/cc364423.aspx
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $KeyStroke,

        # Process name
        # Determine the process name of the application. you want to send for.
        # If there are two or more, it will be sent for the lowest PID.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ProcessName,

        # Waiting time
        # Determine the waiting time in milliseconds before sending a command.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]
        $Wait = 0
    )

    Process
    {
        $Process = ps | ? {$_.Name -eq $ProcessName} | sort -Property CPU -Descending | select -First 1
        Write-Verbose $Process", KeyStroke = "$KeyStroke", Wait = "$Wait" ms."
        sleep -Milliseconds $Wait
        if ($Process -ne $null)
        {
            [Microsoft.VisualBasic.Interaction]::AppActivate($Process.ID)
        }
        [System.Windows.Forms.SendKeys]::SendWait($KeyStroke)
    }
}
