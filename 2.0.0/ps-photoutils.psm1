$global:WorkingFolder = ""
$global:ScriptMode = ""

# PRIVATE FUNCTIONS
. $PSScriptRoot\private\AnalyzeFiles.ps1
. $PSScriptRoot\private\ChangeExtension.ps1
. $PSScriptRoot\private\CheckFileType.ps1
. $PSScriptRoot\private\Helpers.ps1
. $PSScriptRoot\private\IsValidDate.ps1
. $PSScriptRoot\private\OffsetDateTime.ps1
. $PSScriptRoot\private\Outputs.ps1
. $PSScriptRoot\private\ParseDateTime.ps1
. $PSScriptRoot\private\RenameFile.ps1

# PUBLIC FUNCTIONS
. $PSScriptRoot\public\CleanBackups.ps1
. $PSScriptRoot\public\GetExifInfo.ps1
. $PSScriptRoot\public\PhotoAnalyzer.ps1 # Main
. $PSScriptRoot\public\WriteExifInfo.ps1