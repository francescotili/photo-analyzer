$global:WorkingFolder = ""
$global:ScriptMode = ""

# PRIVATE FUNCTIONS
. $PSScriptRoot\private\RenameFile.ps1
. $PSScriptRoot\private\ChangeExtension.ps1
. $PSScriptRoot\private\ParseDateTime.ps1
. $PSScriptRoot\private\IsValidDate.ps1
. $PSScriptRoot\private\CheckFileType.ps1
. $PSScriptRoot\private\Helpers.ps1
. $PSScriptRoot\private\Outputs.ps1

# PUBLIC FUNCTIONS
. $PSScriptRoot\public\GetExifInfo.ps1
. $PSScriptRoot\public\WriteExifInfo.ps1
. $PSScriptRoot\public\CleanBackups.ps1
. $PSScriptRoot\public\PhotoAnalyzer.ps1 # Main