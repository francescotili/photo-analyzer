$global:WorkingFolder = ""
$global:ScriptMode = ""

# PRIVATE FUNCTIONS
. $PSScriptRoot\private\AnalyzeFiles.ps1
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
. $PSScriptRoot\private\CleanBackups.ps1
. $PSScriptRoot\private\GetExifInfo.ps1
. $PSScriptRoot\private\WriteExifInfo.ps1
. $PSScriptRoot\private\ConvertFile.ps1

# PUBLIC FUNCTIONS
. $PSScriptRoot\public\PhotoAnalyzer.ps1
. $PSScriptRoot\public\PhotoAnalyzerAuto.ps1