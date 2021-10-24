$global:WorkingFolder = ""
$global:ScriptMode = ""
$global:Emojis = @{
  "check"    = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("2705", 16))
  "error"    = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F534", 16))
  "warning"  = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F7E8", 16))
  "ban"      = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("26D4", 16))
  "calendar" = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F4C6", 16))
  "pen"      = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F4DD", 16))
  "time"     = [System.Char]::ConvertFromUtf32([System.Convert]::toInt32("1F551", 16))
}

# PRIVATE FUNCTIONS
. $PSScriptRoot\private\AutoAnalyzeFiles.ps1
. $PSScriptRoot\private\ChangeExtension.ps1
. $PSScriptRoot\private\CheckFileType.ps1
. $PSScriptRoot\private\Helpers.ps1
. $PSScriptRoot\private\IsValidDate.ps1
. $PSScriptRoot\private\OffsetDateTime.ps1
. $PSScriptRoot\private\Outputs.ps1
. $PSScriptRoot\private\ParseDateTime.ps1
. $PSScriptRoot\private\RenameFile.ps1
. $PSScriptRoot\private\ParseFilename.ps1
. $PSScriptRoot\private\GetFilename.ps1
. $PSScriptRoot\private\GetExifInfo.ps1
. $PSScriptRoot\private\WriteExifInfo.ps1
. $PSScriptRoot\private\ConvertFile.ps1

# PUBLIC FUNCTIONS
. $PSScriptRoot\public\PhotoAnalyzerAuto.ps1
. $PSScriptRoot\public\CleanBackups.ps1