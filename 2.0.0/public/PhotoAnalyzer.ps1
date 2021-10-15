Function PhotoAnalyzer {
  # Show script header
  Clear-Host
  Write-Host "WARNING! This function is deprecated"
  Write-Host "Use PhotoAnalyzerAuto instead"
  <# OutputScriptHeader

  # Ask for script mode
  Set-Mode

  # Show selected mode
  Clear-Host
  OutputScriptHeader
  OutputModeStatus

  # Ask for path
  Set-Path

  # Show selected path
  Clear-Host
  OutputScriptHeader
  OutputModeStatus
  OutputWorkingPath

  # Ask main action
  ActionRouter #>
}