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
    $currentFile = @{
      fullFilePath = $_.FullName
      path         = Split-Path -Path $_.FullName -Parent
      name         = (GetFilename( Split-Path -Path $_.FullName -Leaf )).fileName
      extension    = (GetFilename( Split-Path -Path $_.FullName -Leaf )).extension
    }

    # Analyze real file type
    Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing $($currentFile.name).$($currentFile.extension) ..." -Status "$($Status)%"
    Write-Host $currentFile.fullFilePath -Background Yellow -Foreground Black

    $fileTypeCheck = CheckFileType $currentFile
    switch ( $fileTypeCheck.action ) {
      'IsValid' {
        # File type and extension coincide
        OutputCheckFileType "valid" $fileInfos.extension

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $currentFile.fullFilePath "DateCreated"

        if ( $Parsed.date -eq "") {
          # Creation date not detected
          OutputCheckCreationDate "undefined"

          # Parse date from filename
          $parsedDateTime = ParseFilename $currentFile.name
          if ( $parsedDateTime -ne "" ) {
            # Valid parsed date
            OutputParsing "parsed"

            # Parse parsedData
            $Parsed = ParseDateTime $parsedDateTime

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $currentFile ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")

            # Rename item
            RenameFile $currentFile $Parsed.fileName
            OutputFileResult "success"
            Write-Host ""
          }
          else {
            # No parsing possible
            OutputParsing "nomatch"

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

            $altWorkflow = AlternativeDatesWorkflow $currentFile.fullFilePath
            if ( $altWorkflow.action -eq "SaveMetadata" ) {
              # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $currentFile $altWorkflow.date

              # Rename item
              RenameFile $currentFile $altWorkflow.filename
              OutputFileResult "success"
            }
            else {
              # Invalid choice
              OutputFileResult "skip"
            }
          }
        }
        else {
          # Creation date valid
          OutputCheckCreationDate "valid"

          # Update all dates in the metadata
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $currentFile ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")

          # Rename file
          RenameFile $currentFile $Parsed.fileName
          OutputFileResult "success"
        }
        Write-Host ""
      }
      'Rename' {
        # Change file extension
        # Rename file changing extension
        OutputCheckFileType "mismatch" $fileInfos.extension
        ChangeExtension $currentFile.fullFilePath $fileTypeCheck.extension

        # Define the new file
        $newFile = $currentFile
        $newFile.extension = $fileTypeCheck.extension
        $newFile.fullFilePath = "$($newFile.path)\$($newFile.name).$($newFile.extension)"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
        $Parsed = Get-ExifInfo $newFile.fullFilePath "DateCreated"

        if ( $Parsed.date -eq "") {
          # Creation date not detected
          OutputCheckCreationDate "undefined"

          # Parse date from filename
          $parsedDateTime = ParseFilename $newFile.name
          if ( $parsedDateTime -ne "" ) {
            # Valid parsed date
            OutputParsing "parsed"

            # Parse parsedData
            $Parsed = ParseDateTime $parsedDateTime

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $newFile ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")

            # Rename item
            RenameFile $newFile $Parsed.fileName
            OutputFileResult "success"
          }
          else {
            # No parsing possible
            OutputParsing "nomatch"

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

            $altWorkflow = AlternativeDatesWorkflow $newFile.fullFilePath
            if ( $altWorkflow.action -eq "SaveMetadata" ) {
              # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
              Write-ExifInfo $newFile $altWorkflow.date

              # Rename item
              RenameFile $newFile $altWorkflow.fileName
              OutputFileResult "success"
            }
            else {
              # Invalid choice
              OutputFileResult "skip"
            }
          }
        }
        else {
          # Creation date valid
          OutputCheckCreationDate "valid"

          # Update all dates in the metadata
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $newFile ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")

          # Rename file
          RenameFile $newFile $Parsed.fileName
          OutputFileResult "success"
        }
        Write-Host ""
      }
      'Convert' {
        OutputCheckFileType "convert"
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Converting file ..." -Status "$($Status)%"

        # Convert file
        ConvertFile $currentFile
      }
      Default {
        # File probably not supported
        OutputCheckFileType "unsupported"
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
    [Parameter(Mandatory = $true)]
    [String]$FullFilePath
  )

  $ReturnValue = "" | Select-Object -Property action, date, filename

  $FileModifyDate = Get-ExifInfo $FullFilePath "FileModifyDate"
  $FileCreateDateAlt = Get-ExifInfo $FullFilePath "DateCreatedAlt"

  # Presents option to the user and wait for input
  (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Unlock.wav").Play()
  Write-Host ""
  Write-Host " >> >> What date would you like to use?"
  if ( $FileModifyDate.date -ne "" ) {
    Write-Host "     1 | $($Emojis["calendar"]) File Modified Date/Time: $($FileModifyDate.date)$($FileModifyDate.utcoffset)"
  }
  if ( $FileCreateDateAlt.date -ne "" ) {
    Write-Host "     2 | $($Emojis["calendar"]) Alternative Creation Date/Time: $($FileCreateDateAlt.date)"
  }
  if (( $FileCreateDateAlt.date -ne "" ) -and ( $FileModifyDate.date -ne "" )) {
    Write-Host "     3 | $($Emojis["time"]) Offset alternative Creation Date/Time with UTC from Modify Date/Time: $($FileModifyDate.utcoffset)"
  }
  Write-Host "     4 | $($Emojis["pen"]) Manually insert date"
  $UserSelection = Read-Host " >> >> Insert number"
  
  # Evaluate workflow and return what needs to be done
  switch ($UserSelection) {
    '1' {
      # User would like to use ModifyDate
      if ( $FileModifyDate.date -ne "" ) {
        $ReturnValue = @{
          action   = "SaveMetadata"
          date     = ($FileModifyDate.date).toString("yyyy:MM:dd hh:mm:ss")
          filename = $FileModifyDate.filename
        }
        return $ReturnValue
      }
      else {
        # Invalid choice
        OutputUserError "invalidChoice"
      }
    }
    '2' {
      # User would like to use CreateDate alternative
      if ( $FileCreateDateAlt.date -ne "" ) {
        $ReturnValue = @{
          action   = "SaveMetadata"
          date     = ($FileCreateDateAlt.date).toString("yyyy:MM:dd hh:mm:ss")
          filename = $FileCreateDateAlt.filename
        }
        return $ReturnValue
      }
      else {
        # Invalid choice
        OutputUserError "invalidChoice"
      }
    }
    '3' {
      # User would like to use CreateDate but with offset
      if (( $FileCreateDateAlt.date -ne "" ) -and ( $FileModifyDate.date -ne "" )) {
        # Calculate new date
        $NewDate = OffsetDateTime $FileCreateDateAlt.date $FileModifyDate.utcoffset
        $Parsed = ParseDateTime "Offset Date : $($NewDate)"

        $ReturnValue = @{
          action   = "SaveMetadata"
          date     = ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")
          filename = $Parsed.fileName
        }
        return $ReturnValue
      }
      else {
        # Invalid choice
        OutputUserError "invalidChoice"
      }
    }
    '4' {
      # User wants to specify a custom date
      $UserData = Read-Host " >> >> Insert date (YYYY:MM:DD hh:mm:ss)"
      if ( $userData -ne "" ) {
        if ( IsValidDate $UserData ) {
          # Valid date
          # Parse customData
          $Parsed = ParseDateTime "Manual Date : $($UserData)"

          $ReturnValue = @{
            action   = "SaveMetadata"
            date     = ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")
            filename = $Parsed.fileName
          }
          return $ReturnValue
        }
        else {
          # Invalid date
          OutputUserError "invalidDate"
        }
      }
      else {
        # No date specified
        OutputUserError "emptyDate"
      }
    }
    Default {
      # Invalid choice
      OutputUserError "emptyChoice"
    }
  }
}