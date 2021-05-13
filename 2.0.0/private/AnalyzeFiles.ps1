Function AnalyzeFiles {
  <#
    .SYNOPSIS
      Core function of the analysis process
    
    .PARAMETER Extension
      File extension to analyze. Suggested order:
      1. HEIC
      2. JPEG
      3. JPG
      4. PNG
      5. MOV
      6. MP4
      7. GIF
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$Extension
  )

  $i = 0
  $a = 0
  $Activity = "   ANALYSIS | .$($Extension) files"
  $FileList = Get-ChildItem -Path $WorkingFolder -Filter "*.$($Extension)"
  $FileNumber = $FileList.Length

  $FileList | ForEach-Object {
    # Initialize progress bar
    $i = $i + 1
    $a = 100 * ($i / ($FileNumber + 1))
    $Status = "{0:N0}" -f $a

    # Variables for the file
    $FilePath = $_.FullName
    $FileName = $_.Name.split('\.')[-2]

    # Analyze real file type
    Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing .$($Extension) files ..." -Status "$($Status)%"
    Write-Host $FilePath

    switch (CheckFileType $FilePath $Extension) {
      'IsValid'  { # File type and extension coincide
        Write-Host " >> Real .$($Extension) file detected"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $FilePath "DateCreated"

        if ( $Parsed -eq "") { # Creation date not detected
          if ( $ScriptMode -eq "Simulation" ) { # Simulate update
            Write-Host " >> Creation date not detected! Should use modify date ..."
            Write-Host ""
          } elseif( $ScriptMode -eq "Manual" ) { # Ask and save manual data
            Write-Host " >> Creation date not detected ..."

            # Getting modify Date
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading modify date ..." -Status "$Status%"
            $Parsed = Get-ExifInfo $FilePath "FileModifyDate"
            Write-Host " >> Modify date is: $($Parsed.date)"
            Write-Host ""

            # Gettin the new manual date
            $UserData = Read-Host " >> Please enter a new date (YYYY:MM:DD hh:mm:ss)"
            if ( $userData -ne "" ) {
              if ( IsValidDate $UserData ) { # Valid date
                # Parse customData
                $Parsed = ParseDateTime $UserData "CustomDate"

                # Update metadatas
                Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                Write-ExifInfo $FilePath $Parsed.date $Extension

                # Rename item
                RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
                Write-Host ""
              } else { # Invalid date
                Write-Host "Invalid date!"
                Write-Host " >> File skipped"
                Write-Host ""
              }
            } else { # No date specified
              Write-Host "No date specified!"
              Write-Host " >> File skipped"
              Write-Host ""
            }
          } else { # Automatic update
            Write-Host " >> Creation date not detected! Reading modify date..."
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading modify date ..." -Status "$Status%"
            $Parsed = Get-ExifInfo $FilePath "FileModifyDate"
            Write-Host " >> Detected date: $($Parsed.date)"
            $UserSelection = Read-Host " >> >> Would you like to use this date? Y/N"
            switch ($UserSelection) {
              'y' { # User would like to use ModifyDate
                # Update all dates in the metadata
                Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                Write-ExifInfo $FilePath $Parsed.date $Extension
    
                # Rename item
                RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
                Write-Host ""
              }
              Default {  # User doesn't want to use ModifyDate
                $UserManualData = Read-Host "Got it, would you like to specify a custom date to apply? y/n"
                switch ($UserManualData) {
                  'y' { # User will specify a new date
                    Write-Host ""
                    $UserData = Read-Host "Insert date (YYYY:MM:DD hh:mm:ss)"
                    if ( $userData -ne "" ) {
                      if ( IsValidDate $UserData ) { # Valid date
                        # Parse customData
                        $Parsed = ParseDateTime $UserData "CustomDate"
    
                        # Update metadatas
                        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                        Write-ExifInfo $FilePath $Parsed.date $Extension
    
                        # Rename item
                        RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
                        Write-Host ""
                      } else { # Invalid date
                        Write-Host "Invalid date!"
                        Write-Host " >> File skipped"
                        Write-Host ""
                      }
                    } else { # No date specified
                      Write-Host "No date specified!"
                      Write-Host " >> File skipped"
                      Write-Host ""
                    }
                  }
                  Default { # No user-specified date
                    Write-Host " >> File skipped"
                    Write-Host ""
                  }
                }
              }
            }
          }          
        } else { # Creation date valid
          if ( $ScriptMode -eq "Simulation" ) { # Simulate update
            Write-Host " >> File should be renamed in $($Parsed.fileName)+000.$($Extension)"
          } elseif ( $ScriptMode -eq "Manual" ) { # Ask and save manual data
            Write-Host " >> Creation date is: $($Parsed.date)"
            Write-Host ""
            $UserData = Read-Host " >> Please enter a new date (YYYY:MM:DD hh:mm:ss)"
            if ( $userData -ne "" ) {
              if ( IsValidDate $UserData ) { # Valid date
                # Parse customData
                $Parsed = ParseDateTime $UserData "CustomDate"

                # Update metadatas
                Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                Write-ExifInfo $FilePath $Parsed.date $Extension

                # Rename item
                RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
              } else { # Invalid date
                Write-Host "Invalid date!"
                Write-Host " >> File skipped"
              }
            } else { # No date specified
              Write-Host "No date specified!"
              Write-Host " >> File skipped"
              Write-Host ""
            }
          } else { # Automatic update
            # Update all dates in the metadata
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $FilePath $Parsed.date $Extension
  
            # Rename file
            RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
          }
          Write-Host ""
        }        
      }
      'Rename'   { # Change file extension
        # Determine right extension
        [string] $FinalExtension = ""
        switch ($Extension) {
          'jpeg' { $FinalExtension = "jpg" }
          'heic' { $FinalExtension = "jpg" }
          'mov' { $FinalExtension = "mp4" }
          Default {
            Write-Error -Message "Unhandled exception occurred" -ErrorAction Continue
            Break
          }
        }

        # Rename file changing extension
        if ( $ScriptMode -eq "Simulation" ) {
          Write-Host " >> Not a real .$($Extension) file! Extension should be changed ..."
          Write-Host ""
        } elseif ( $ScriptMode -eq "Manual" ) {
          Write-Host " >> Not a real .$($Extension) file!"
          $UserSelection = Read-Host " >> Would you like to correct it? y/n"
          switch ($UserSelection) {
            'y' {
              ChangeExtension $FilePath $FinalExtension
            }
            Default {
              Write-Host " >> Skipping file ..."
              Write-Host ""
            }
          }
        } else {
          Write-Host " >> Not a real .$($Extension) file ..."
          ChangeExtension $FilePath $FinalExtension
        }
      }
      Default    { # File type not handled or unexpected errors
        Write-Host "  >> Something strange with the file, please check manually"
        Write-Error -Message "File type is $( Get-ExifInfo $FilePath "FileType" )"
        Write-Host ""
      }
    }
  }
}