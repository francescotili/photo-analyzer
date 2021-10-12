Function AutoAnalyzeFiles {
  <#
    .SYNOPSIS
      Completely automated AnalyzeFiles
    
    .PARAMETER Extension
      File extension to analyze.
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
    $GetFileName = GetFilename($_.Name)
    $FileName = $GetFileName.fileName

    # Analyze real file type
    Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing .$($Extension) files ..." -Status "$($Status)%"
    Write-Host $FilePath

    $fileTypeCheck = CheckFileType $FilePath $Extension
    switch ( $fileTypeCheck.action ) {
      'IsValid'  { # File type and extension coincide
        Write-Host " >> Real .$($Extension) file detected"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $FilePath "DateCreated"

        if ( $Parsed -eq "") { # Creation date not detected
          Write-Host " >> Creation date not detected! Reading alternative dates..."

          # Check if filename is parsable
          if ( $FileName -match "(19|20\d{2})(?:[_.-])?(0[1-9]|1[0-2])(?:[_.-])?([0-2]\d|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-])?([0-5][0-9])(?:[_.-])?([0-5][0-9])" ) { # We have a match
            $parsedDateTime = ParseFilename $FileName
            if ( IsValidDate $parsedDateTime ) { # Valid parsed date
              # Parse parsedData
              $Parsed = ParseDateTime $parsedDateTime "CustomDate"

              #Update metadatas
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $FilePath $Parsed.date $Extension

              # Rename item
              RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
              Write-Host ""
            } else { # Parsed date is invalid
              Write-Host "Parsing unsuccessfull (invalid date)! Trying other dates..."
              Write-Host " >> File skipped, try manual mode"
              Write-Host ""
            }
          } else { # No parsing possibile
            Write-Host "Parsing unsuccessfull (no match)! Trying other dates..."
          
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading modify date ..." -Status "$Status%"
            $FileModifyDate = Get-ExifInfo $FilePath "FileModifyDate"
            $FileCreateDateAlt = Get-ExifInfo $FilePath "DateCreatedAlt"

            (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Unlock.wav").Play()
            Write-Host ""
            Write-Host " >> >> What date would you like to use?"
            if (-Not ([string]::IsNullOrEmpty($FileModifyDate.date))) {
              Write-Host "     1 | File Modified Date/Time: $($FileModifyDate.date)$($FileModifyDate.utcoffset)"
            }
            if ( -Not ([string]::IsNullOrEmpty($FileCreateDateAlt.date))) {
              Write-Host "     2 | Alternative Creation Date/Time: $($FileCreateDateAlt.date)"
            }
            if (( -Not ([string]::IsNullOrEmpty($FileCreateDateAlt.date))) -and ( -Not ([string]::IsNullOrEmpty($FileModifyDate.date)))) {
              Write-Host "     3 | Offset alternative Creation Date/Time with UTC from Modify Date/Time: $($FileModifyDate.utcoffset)"
            }
            Write-Host "     4 | Manually insert date"
            $UserSelection = Read-Host " >> >> Insert number"
            switch ($UserSelection) {
              '1' { # User would like to use ModifyDate
                if (-Not ([string]::IsNullOrEmpty($FileModifyDate.date))) {
                  # Update all dates in the metadata
                  Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                  Write-ExifInfo $FilePath $FileModifyDate.date $Extension

                  # Rename item
                  RenameFile $WorkingFolder $FileName $FileModifyDate.fileName $Extension
                  Write-Host ""
                } else { # Invalid choice
                  Write-Host "Invalid choice!"
                  Write-Host " >> File skipped"
                  Write-Host ""
                }
              }
              '2' { # User would like to use CreateDate alternative
                if ( -Not ([string]::IsNullOrEmpty($FileCreateDateAlt.date))) {
                  # Update all dates in the metadata
                  Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                  Write-ExifInfo $FilePath $FileCreateDateAlt.date $Extension

                  # Rename item
                  RenameFile $WorkingFolder $FileName $FileCreateDateAlt.fileName $Extension
                  Write-Host ""
                } else { # Invalid choice
                  Write-Host "Invalid choice!"
                  Write-Host " >> File skipped"
                  Write-Host ""
                }
              }
              '3' { # User would like to use CreateDate but with offset
                if (( -Not ([string]::IsNullOrEmpty($FileCreateDateAlt.date))) -and ( -Not ([string]::IsNullOrEmpty($FileModifyDate.date)))) {
                  # Calculate new date
                  $NewDate = OffsetDateTime $FileCreateDateAlt.date $FileModifyDate.utcoffset
                  $Parsed = ParseDateTime $NewDate "CustomDate"

                  #Update all dates in the metadata
                  Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
                  Write-ExifInfo $FilePath $Parsed.date $Extension

                  # Rename item
                  RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
                  Write-Host ""
                } else { # Invalid choice
                  Write-Host "Invalid choice!"
                  Write-Host " >> File skipped"
                  Write-Host ""
                }
              }
              '4' { # User wants to specify a custom date
                $UserData = Read-Host " >> >> Insert date (YYYY:MM:DD hh:mm:ss)"
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
              Default { # Invalid choice
                Write-Host "Invalid choice!"
                Write-Host " >> File skipped"
                Write-Host ""
              }
            }
          }
        } else { # Creation date valid
          # Update all dates in the metadata
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $FilePath $Parsed.date $Extension

          # Rename file
          RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
        }
        Write-Host ""
      }
      'Rename'   { # Change file extension
        # Rename file changing extension
        Write-Host " >> Not a real .$($Extension) file ..."
        ChangeExtension $FilePath $fileTypeCheck.extension
      }
      Default    { # File type not handled or unexpected errors
        Write-Host "  >> Something strange with the file, please check manually"
        Write-Error -Message "File type is $($fileTypeCheck.extension)"
        Write-Host ""
      }
    }
  }
}