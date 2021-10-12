Function AutoPhoto {
  # Show script header
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
  $userChoice = Read-Host " >> Do you want to continue? y/n"

  switch ($userChoice) {
    'y' { # Execute main actions
      Clear-Host
      OutputSpacer
      AnalyzeFiles "heic"
      AnalyzeFiles "jpeg"
      AnalyzeFiles "jpg"
      AnalyzeFiles "png"
      AnalyzeFiles "mov"
      AnalyzeFiles "m4v"
      AnalyzeFiles "mp4"
      AnalyzeFiles "gif"
      OutputScriptFooter
    }
    Default {
      Read-Host -Prompt "Press Enter to exit"}
  }
}