$global:WorkingFolder = ""
$global:Emojis = @{
  "check"    = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("2705", 16))
  "error"    = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F534", 16))
  "warning"  = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F7E8", 16))
  "ban"      = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("26D4", 16))
  "calendar" = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F4C6", 16))
  "pen"      = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F4DD", 16))
  "time"     = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F551", 16))
}
[DateTime]$global:DefaultDate = Get-Date -Date "01-01-1800 00:00:00"

# PRIVATE FUNCTIONS
. $PSScriptRoot\private\AutoAnalyzeFiles.ps1
. $PSScriptRoot\private\ConvertFile.ps1
. $PSScriptRoot\private\GetExifInfo.ps1
. $PSScriptRoot\private\GetFilename.ps1
. $PSScriptRoot\private\Helpers.ps1
. $PSScriptRoot\private\Outputs.ps1
. $PSScriptRoot\private\Parsers.ps1
. $PSScriptRoot\private\WriteExifInfo.ps1

# PUBLIC FUNCTIONS
. $PSScriptRoot\public\PhotoAnalyzerAuto.ps1
. $PSScriptRoot\public\CleanBackups.ps1