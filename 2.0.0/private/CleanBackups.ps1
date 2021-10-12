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
    [Parameter(Mandatory=$false)]
    [String]$FolderPath,

    [Parameter(Mandatory=$false)]
    [String]$Mode
  )

  $userChoice = Read-Host " >> Are you sure to continue? y/n"

  switch ($userChoice) {
    'y' { # User wants to delete .*_original files
      # Analyze and set the WorkingPath
      if ($PSBoundParameters.ContainsKey('FolderPath')) { # FolderPath has been passed
        $WorkingPath = $FolderPath
      } else { # No FolderPath parameter passed
        if ($WorkingFolder -ne "") { # Global working folder is set
          $WorkingPath = $WorkingFolder
        } else { # No passed path and no global specified, ask the user
          $UserPath = Read-Host " >> Specify path to clean:"
          if ($UserPath -ne "" ) {
            $UserPath = $UserPath -replace '["]',''
            if (Test-Path -Path "$UserPath") {
              $WorkingPath = $UserPath
            } else {
              Write-Error -Message "Unvalid path! Exiting..." -ErrorAction Stop
            }
          } else {
            Write-Error -Message "No path specified!" -ErrorAction Stop
          }
        }
      }

      # Analyze and set the Mode
      if ($PSBoundParameters.ContainsKey('Mode')) { # Mode parameter has been passed
        $ExecutionMode = $Mode
      } else { # No Mode parameter passed
        if ($ScriptMode -ne "") { # Global mode is set
          $ExecutionMode = $ScriptMode
        } else {
          $ExecutionMode = "Simulation"
        }
      }

      $i = 0
      $a = 0
      $Activity = "Cleaning up backup files"
      $CleanupAnalisys = Get-ChildItem -Path $WorkingPath -Filter "*.*_original"
      $CleanupFiles = $CleanupAnalisys.length

      if ( $CleanupFiles -gt 0 ) {
        if( $ExecutionMode -eq "Simulation" ) {
          Write-Host "The following files would be deleted:"
        }
        
        $CleanupAnalisys | ForEach-Object {
          # Initialize progress bar
          $i = $i + 1
          $a = 100 * ($i / ($CleanupFiles + 1))
          $Status = "{0:N0}" -f $Activity
  
          # Variables for the file
          $FilePath = $_.FullName
          $FileName = GetFilename($_.Name)
  
          # Deleting file
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Deleting $($FileName)" -Status "$Status%"
          switch ($ExecutionMode) {
            'Simulation' {
              Write-Host $FilePath
            }
            'Normal' {
              Remove-Item $FilePath
            }
            'Manual' {
              Write-Host $FilePath
              $userChoice = Read-Host " >> Proceed with deletion? y/n"
              switch ($userChoice) {
                'y' {
                  Remove-Item $FilePath
                  Write-Host " >> File removed"
                  Write-Host ""
                }
                'n' {
                  Write-Host " >> File skipped"
                  Write-Host ""
                }
              }
            }
          }
        }
        Write-Host ""
        Write-Host " >> >> Cleaning complete!"
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Ring06.wav").Play()
        Read-Host "Press Enter to exit"
      } else {
        Write-Host " >> >> No temporary files found!"
        Read-Host "Press Enter to exit"
      }
    }
    Default { # User doesn't want to cleanup
      Read-Host -Prompt "Press Enter to exit"
    }
  }
}