Function PhotoAnalyzer {
  # Show script header
  Clear-Host
  OutputScriptHeader

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
  ActionRouter
}