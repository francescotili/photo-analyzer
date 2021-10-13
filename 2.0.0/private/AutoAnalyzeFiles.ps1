Function AutoAnalyzeFiles {
  <#
    .SYNOPSIS
      Completely automated AnalyzeFiles
  #>

  $i = 0
  $a = 0
  $Activity = "   ANALYSIS IN PROGRESS ..."
  $FileList = Get-ChildItem -Path $WorkingFolder
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
    $Extension = $GetFileName.extension

    # Analyze real file type
    Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing $($FileName) ..." -Status "$($Status)%"
    Write-Host $FilePath

    $fileTypeCheck = CheckFileType $FilePath $Extension
    switch ( $fileTypeCheck.action ) {
      'IsValid' { # File type and extension coincide
        Write-Host " >> Real .$($Extension) file detected"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $FilePath "DateCreated"

        if ( $Parsed -eq "") { # Creation date not detected
          Write-Host " >> Creation date not detected! Reading alternative dates..."

          # Parse date from filename
          $parsedDateTime = ParseFilename $FileName
          if ( $parsedDateTime -ne "" ) { # Valid parsed date
            # Parse parsedData
            $Parsed = ParseDateTime $parsedDateTime "CustomDate"

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $FilePath $Parsed.date $Extension

            # Rename item
            RenameFile $WorkingFolder $FileName $Parsed.fileName $Extension
            Write-Host ""
          } else { # No parsing possible
            Write-Host " >> Parsing unsuccessfull (no match)! Trying other dates..."

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

            $altWorkflow = AlternativeDatesWorkflow $FilePath
            if ( $altWorkflow.action -eq "SaveMetadata" ) { # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $FilePath $altWorkflow.date $Extension

              # Rename item
              RenameFile $WorkingFolder $FileName $altWorkflow.filename $Extension
            } else { # Invalid choice
              Write-Host " >> File skipped"
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

        $newFilePath = "$($WorkingFolder)\$($FileName).$($fileTypeCheck.extension)"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $newFilePath "DateCreated"

        if ( $Parsed -eq "") { # Creation date not detected
          Write-Host " >> Creation date not detected! Reading alternative dates..."

          # Parse date from filename
          $parsedDateTime = ParseFilename $FileName
          if ( $parsedDateTime -ne "" ) { # Valid parsed date
            # Parse parsedData
            $Parsed = ParseDateTime $parsedDateTime "CustomDate"

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $newFilePath $Parsed.date $Extension

            # Rename item
            RenameFile $WorkingFolder $FileName $Parsed.fileName $fileTypeCheck.extension
            Write-Host ""
          } else { # No parsing possible
            Write-Host " >> Parsing unsuccessfull (no match)! Trying other dates..."

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

            $altWorkflow = AlternativeDatesWorkflow $newFilePath
            if ( $altWorkflow.action -eq "SaveMetadata" ) { # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $newFilePath $altWorkflow.date $Extension

              # Rename item
              RenameFile $WorkingFolder $FileName $FileModifyDate.fileName $fileTypeCheck.extension
              Write-Host ""
            } else { # Invalid choice
              Write-Host " >> File skipped"
              Write-Host ""
            }
          }
        } else { # Creation date valid
          # Update all dates in the metadata
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $newFilePath $Parsed.date $Extension

          # Rename file
          RenameFile $WorkingFolder $FileName $Parsed.fileName $fileTypeCheck.extension
        }
        Write-Host ""
      }
      'Convert' {
        # Convert file
        # Reanalyze
      }
      Default { # File probably not supported
        Write-Host " >> File extension not supported, skipping..."
        Write-Host ""
      }
    }
  }
}

function AlternativeDatesWorkflow {
  <#
    .SYNOPSIS
      Manage the workflow when the file need alternative dates searching
    
    .PARAMETER FilePath
      The file path to be processed
    
    .RETURNS
      The action to be done and date selected
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$FilePath
  )

  $ReturnValue = "" | Select-Object -Property action, date, filename

  $FileModifyDate = Get-ExifInfo $FilePath "FileModifyDate"
  $FileCreateDateAlt = Get-ExifInfo $FilePath "DateCreatedAlt"

  # Presents option to the user and wait for input
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
  
  # Evaluate workflow and return what needs to be done
  switch ($UserSelection) {
    '1' { # User would like to use ModifyDate
      if (-Not ([string]::IsNullOrEmpty($FileModifyDate.date))) {
        $ReturnValue.action = "SaveMetadata"
        $ReturnValue.date = $FileModifyDate.date
        $ReturnValue.filename = $FileModifyDate.filename
        return $ReturnValue
      } else { # Invalid choice
        Write-Host "Invalid choice!"
      }
    }
    '2' { # User would like to use CreateDate alternative
      if ( -Not ([string]::IsNullOrEmpty($FileCreateDateAlt.date))) {
        $ReturnValue.action = "SaveMetadata"
        $ReturnValue.date = $FileCreateDateAlt.date
        $ReturnValue.filename = $FileCreateDateAlt.filename
        return $ReturnValue
      } else { # Invalid choice
        Write-Host "Invalid choice!"
      }
    }
    '3' { # User would like to use CreateDate but with offset
      if (( -Not ([string]::IsNullOrEmpty($FileCreateDateAlt.date))) -and ( -Not ([string]::IsNullOrEmpty($FileModifyDate.date)))) {
        # Calculate new date
        $NewDate = OffsetDateTime $FileCreateDateAlt.date $FileModifyDate.utcoffset
        $Parsed = ParseDateTime $NewDate "CustomDate"

        $ReturnValue.action = "SaveMetadata"
        $ReturnValue.date = $Parsed.date
        $ReturnValue.filename = $Parsed.fileName
        return $ReturnValue
      } else { # Invalid choice
        Write-Host "Invalid choice!"
      }
    }
    '4' { # User wants to specify a custom date
      $UserData = Read-Host " >> >> Insert date (YYYY:MM:DD hh:mm:ss)"
      if ( $userData -ne "" ) {
        if ( IsValidDate $UserData ) { # Valid date
          # Parse customData
          $Parsed = ParseDateTime $UserData "CustomDate"

          $ReturnValue.action = "SaveMetadata"
          $ReturnValue.date = $Parsed.date
          $ReturnValue.filename = $Parsed.fileName
          return $ReturnValue
        } else { # Invalid date
          Write-Host "Invalid date!"
        }
      } else { # No date specified
        Write-Host "No date specified!"
      }
    }
    Default { # Invalid choice
      Write-Host "Invalid choice!"
    }
  }
}