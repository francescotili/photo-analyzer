Function AutoPhoto {
  # Show script header
  Clear-Host
  OutputScriptHeader

  # Set everything to be automatic
  Set-Variable -Name ScriptMode -Value "Normal" -Scope Global
  OutputModeStatus

  # Ask for path
  Set-Path

  # Show selected path
  Clear-Host
  OutputScriptHeader
  OutputModeStatus
  OutputWorkingPath
  Write-Host ""
  $userChoice = Read-Host " >> Do you want to continue? y/n"

  switch ($userChoice) {
    'y' { # Execute main actions
      Clear-Host
      OutputSpacer
      AutoAnalyzeFiles "heic"
      AutoAnalyzeFiles "jpeg"
      AutoAnalyzeFiles "jpg"
      AutoAnalyzeFiles "png"
      AutoAnalyzeFiles "mov"
      AutoAnalyzeFiles "m4v"
      AutoAnalyzeFiles "mp4"
      AutoAnalyzeFiles "gif"
      OutputScriptFooter
    }
    Default {
      Read-Host -Prompt "Press Enter to exit"}
  }
}