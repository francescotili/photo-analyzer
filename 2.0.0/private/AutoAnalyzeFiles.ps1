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
    $currentFile = "" | Select-Object -Property path, name, extension, fullFilePath
    $currentFile.fullFilePath = $_.FullName
    $currentFile.path = Split-Path -Path $currentFile.fullFilePath -Parent
    $fileInfos = GetFilename( Split-Path -Path $currentFile.fullFilePath -Leaf )
    $currentFile.name = $fileInfos.fileName
    $currentFile.extension = $fileInfos.extension

    # Analyze real file type
    Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing $($currentFile.name).$($currentFile.extension) ..." -Status "$($Status)%"
    Write-Host $currentFile.fullFilePath -Background Yellow -Foreground Black

    $fileTypeCheck = CheckFileType $currentFile
    switch ( $fileTypeCheck.action ) {
      'IsValid' { # File type and extension coincide
        Write-Host " >> Real .$($fileInfos.extension) file detected"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $currentFile.fullFilePath "DateCreated"

        if ( $Parsed -eq "") { # Creation date not detected
          Write-Host " >> Creation date not detected! Reading alternative dates..."

          # Parse date from filename
          $parsedDateTime = ParseFilename $currentFile.name
          if ( $parsedDateTime -ne "" ) { # Valid parsed date
            # Parse parsedData
            $Parsed = ParseDateTime $parsedDateTime "CustomDate"

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $currentFile $Parsed.date

            # Rename item
            RenameFile $currentFile $Parsed.fileName
            Write-Host ""
          } else { # No parsing possible
            Write-Host " >> Parsing unsuccessfull (no match)! Trying other dates..."

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

            $altWorkflow = AlternativeDatesWorkflow $currentFile.fullFilePath
            if ( $altWorkflow.action -eq "SaveMetadata" ) { # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $currentFile $altWorkflow.date

              # Rename item
              RenameFile $currentFile $altWorkflow.filename
            } else { # Invalid choice
              Write-Host " >> File skipped"
            }
          }
        } else { # Creation date valid
          # Update all dates in the metadata
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $currentFile $Parsed.date

          # Rename file
          RenameFile $currentFile $Parsed.fileName
        }
        Write-Host ""
      }
      'Rename'   { # Change file extension
        # Rename file changing extension
        Write-Host " >> Not a real .$($Extension) file ..."
        ChangeExtension $currentFile.fullFilePath $fileTypeCheck.extension

        # Define the new file
        $newFile = "" | Select-Object -Property path, name, extension, fullFilePath
        $newFile = $currentFile
        $newFile.extension = $fileTypeCheck.extension
        $newFile.fullFilePath = "$($newFile.path)\$($newFile.name).$($newFile.extension)"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $newFile.fullFilePath "DateCreated"

        if ( $Parsed -eq "") { # Creation date not detected
          Write-Host " >> Creation date not detected! Reading alternative dates..."

          # Parse date from filename
          $parsedDateTime = ParseFilename $newFile.name
          if ( $parsedDateTime -ne "" ) { # Valid parsed date
            # Parse parsedData
            $Parsed = ParseDateTime $parsedDateTime "CustomDate"

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $newFile $Parsed.date

            # Rename item
            RenameFile $newFile $Parsed.fileName
            Write-Host ""
          } else { # No parsing possible
            Write-Host " >> Parsing unsuccessfull (no match)! Trying other dates..."

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

            $altWorkflow = AlternativeDatesWorkflow $newFile.fullFilePath
            if ( $altWorkflow.action -eq "SaveMetadata" ) { # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $newFile $altWorkflow.date

              # Rename item
              RenameFile $newFile $FileModifyDate.fileName
              Write-Host ""
            } else { # Invalid choice
              Write-Host " >> File skipped"
              Write-Host ""
            }
          }
        } else { # Creation date valid
          # Update all dates in the metadata
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $newFile $Parsed.date

          # Rename file
          RenameFile $newFile $Parsed.fileName
        }
        Write-Host ""
      }
      'Convert' {
        Write-Host " >> The file will be converted..."
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Converting file ..." -Status "$($Status)%"

        # Convert file
        ConvertFile $currentFile
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
    
    .PARAMETER FullFilePath
      The file path to be processed
    
    .RETURNS
      The action to be done and date selected
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$FullFilePath
  )

  $ReturnValue = "" | Select-Object -Property action, date, filename

  $FileModifyDate = Get-ExifInfo $FullFilePath "FileModifyDate"
  $FileCreateDateAlt = Get-ExifInfo $FullFilePath "DateCreatedAlt"

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