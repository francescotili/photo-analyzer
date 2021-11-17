Function PhotoAnalyzer {
  # Show script header
  Clear-Host
  OutputScriptHeader

  Write-Host " >> $($Emojis["warning"]) All changes will be written to files!"

  # Ask for path
  $WorkingFolder = Set-Path

  Clear-Host
  OutputSpacer
  AutoAnalyzeFiles $WorkingFolder
  OutputScriptFooter
  CleanBackups $WorkingFolder
}