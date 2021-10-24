@{
  RootModule        = "ps-photoutils.psm1"
  ModuleVersion     = "2.0.0"
  GUID              = "1ba78313-86bd-45ca-b103-83a23cbabec2"
  Author            = "Francesco Tili"
  Description       = "Analyze, correct and rename your photos and videos"
  PowerShellVersion = "3.0"
  FunctionsToExport = @(
    'PhotoAnalyzer',
    'CleanBackups'
  )
}