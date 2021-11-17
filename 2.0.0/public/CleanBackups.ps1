Function CleanBackups {
  <#
    .SYNOPSIS
      Remove the file generated as backup by ExifTool
    
    .PARAMETER WorkingFolder
      Optional. The folder to scan and to clean. By default it uses the passed path, if present, otherwise it will ask the user.
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $false)]
    [String]$WorkingFolder
  )

  # Analyze and set the WorkingPath
  if ($WorkingFolder -ne "") {
    # Global working folder is set
    Write-Host " WORKING FOLDER: $(($WorkingFolder.split("\"))[-1]) " -Background Yellow -Foreground Black
    Write-Host 
    $UserChoice = Read-Host " >> Would you like to delete *.*_original backup files? s/n"
    switch ($UserChoice) {
      's' {
        CleanFiles $WorkingFolder
      }
      'n' {
        Read-Host " >> Press enter to exit"
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
        CleanFiles $UserPath
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

function CleanFiles {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$WorkingPath
  )

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