Function PhotoAnalyzerOffset {
  # Show script header
  Clear-Host
  OutputScriptHeader

  Write-Host " >> $($Emojis["warning"]) All changes will be written to files!"

  # Ask for path
  $WorkingFolder = Set-Path

  # Ask for offset
  $Offset = Set-Offset
  
  Clear-Host
  OutputSpacer
  OffsetDateTime $WorkingFolder $Offset
  OutputScriptFooter
  CleanBackups $WorkingFolder  
}