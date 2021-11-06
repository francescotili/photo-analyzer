Function RestoreBackups {
  <#
    .SYNOPSIS
      Take the *.*_original files created as Backup by Exiftools and restores them
    
    .PARAMETER FolderPath
      Optional. The folder to scan and to clean. By default it uses the global path, if present, otherwise it will ask the user.
  #>

  [CmdletBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $false)]
    [String]$FolderPath
  )

  # Analyze and set the WorkingPath
  if ($workingfolder -ne "") {
    # Global working folder is set
    $UserChoice = Read-Host " >> Would you like to restore *.*_original backup files? s/n"
    switch ($UserChoice) {
      's' {
        RestoreFiles $workingFolder
      }
      'n' {
        Read-Host " >> Press enter to exit"
      }
      Default {
        # User doesn't want to restore backup files
        OutputUserError "invalidChoice"
      }
    }
  }
  else {
    # No global specified, ask the user
    $UserPath = Read-Host " >> Please specify path to analyze and restore"
    if ($UserPath -ne "") {
      $UserPath = $UserPath -replace '["]', ''
      if (Test-Path -Path "$UserPath") {
        RestoreFiles $UserPath
      }
      else {
        OutputUserError "invalidPath"
      }
    }
    else {
      OutputUserError "emptyPath"
    }
  }
}

Function RestoreFiles {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$workingPath
  )

  $i = 0
  $a = 0
  $Activity = "Restoring from backup files"
  $RestoreAnalysis = Get-ChildItem -Path $WorkingPath -Filter "*.*_original"
  $RestoreFiles = $RestoreAnalysis.Length

  if ( $RestoreFiles -gt 0 ) {
    # Restore files found from Get-ChildItem
    $RestoreAnalysis | ForEach-Object {
      # Initialize progress bar
      $i = $i + 1
      $a = 100 * ($i / ($RestoreFiles + 1))
      $Status = "{0:N0}" -f $Activity

      # Variables for the file
      $currentFile = @{
        fullFilePath = $_.FullName
        path         = Split-Path -Path $_.FullName -Parent
        name         = (GetFilename( Split-Path -Path $_.FullName -Leaf )).fileName
        extension    = (GetFilename( Split-Path -Path $_.FullName -Leaf )).extension
      }
      Write-Host $currentFile.fullFilePath -Background Yellow -Foreground Black

      # Renaming file
      Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Restoring $($currentFile.name)" -Status "$Status%"
      ChangeExtension $currentFile.fullFilePath ($currentFile.extension -replace "_original", "")
      Write-Host ""
    }
    OutputRestoreResult "completed"
  }
  else {
    # No files found from Get-ChildItem
    OutputRestoreResult "noFiles"
  }
}