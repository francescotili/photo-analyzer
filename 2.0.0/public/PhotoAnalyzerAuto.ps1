Function PhotoAnalyzerAuto {
  # Show script header
  Clear-Host
  OutputScriptHeader

  # Set everything to be automatic
  Set-Variable -Name ScriptMode -Value "Normal" -Scope Global
  OutputModeStatus

  # Ask for path
  Set-Path

  Clear-Host
  OutputSpacer
  AutoAnalyzeFiles
  OutputScriptFooter
}