Function CleanBackups {
  <#
    .SYNOPSIS
      Remove the file generated as backup by ExifTool
    
    .PARAMETER FolderPath
      Optional. The folder to scan and to clean. By default it uses the global path, if present, otherwise it will ask the user.
    
    .PARAMETER Mode
      Optional. Mode of execution, defaults to global mode if not passed (if global is not present, it will simulate):
      - 'Normal' -> Automatic deletion of all detected file without confirmation
      - 'Simulation' -> Automatic detection without deletion
      - 'Manual' -> Automatic detection but ask user for deletion of every file
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $false)]
    [String]$FolderPath,

    [Parameter(Mandatory = $false)]
    [String]$Mode
  )

  # Analyze and set the WorkingPath
  if ($WorkingFolder -ne "") {
    # Global working folder is set
    $UserChoice = Read-Host " >> Would you like to delete *.*_original backup files? s/n"
    switch ($UserChoice) {
      's' {
        $WorkingPath = $WorkingFolder
      }
      Default {
        # User doesn't want to delete backup files
        OutputUserError "invalidChoice"
      }
    }
  }
  else {
    # No global specified, ask the user
    $UserPath = Read-Host " >> Please specify path to clean"
    if ($UserPath -ne "" ) {
      $UserPath = $UserPath -replace '["]', ''
      if (Test-Path -Path "$UserPath") {
        $WorkingPath = $UserPath
      }
      else {
        OutputUserError "invalidPath"
      }
    }
    else {
      OutputUserError "emptyPath"
    }
  }

  $i = 0
  $a = 0
  $Activity = "Cleaning up backup files"
  $CleanupAnalisys = Get-ChildItem -Path $WorkingPath -Filter "*.*_original"
  $CleanupFiles = $CleanupAnalisys.length

  if ( $CleanupFiles -gt 0 ) {
    # Backup files found from Get-ChildItem
    $CleanupAnalisys | ForEach-Object {
      # Initialize progress bar
      $i = $i + 1
      $a = 100 * ($i / ($CleanupFiles + 1))
      $Status = "{0:N0}" -f $Activity

      # Variables for the file
      $FilePath = $_.FullName
      $GetFileName = GetFilename($_.Name)
      $FileName = $GetFileName.fileName

      # Deleting file
      Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Deleting $($FileName)" -Status "$Status%"
      Remove-Item $FilePath
    }
    OutputCleanResult "completed"
  }
  else {
    # No files found from Get-ChildItem
    OutputCleanResult "noFiles"
  }
}