Function OffsetDateTime {
  <#
    .SYNOPSIS
      This function offset date and time of specified files with specified offset
    
    .PARAMETER WorkingFolder
      The folder to scan and to elaborate
    
    .PARAMETER UTCOffset
      Required. Offset in UTC format of +/-hh:mm. Example: +01:30 or -02:00
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$WorkingFolder,

    [Parameter(Mandatory = $true)]
    [String]$UTCOffset
  )

  $i = 0
  $a = 0
  $Activity = "   ANALYZING FOLDER: $(($WorkingFolder.split("\"))[-1])"
  $FileList = Get-ChildItem -Path $WorkingFolder -File
  $FileNumber = $FileList.Count
  $etaStartTime = Get-Date

  $FileList | ForEach-Object {
    # ETA Calculations
    $etaOutput = ""
    $etaNow = Get-Date
    if ($i -gt 0) {
      $etaElapsed = $etaNow - $etaStartTime
      $etaAverage = $etaElapsed.TotalSeconds / $i
      $etaSecondsLeft = ($FileNumber - $i) * $etaAverage
      $etaSpan = New-TimeSpan -Seconds $etaSecondsLeft
      if ($etaSpan.Days -gt 0) {
        $etaOutput += "$($etaSpan.Days) days "
      }
      if ($etaSpan.Hours -gt 0) {
        $etaOutput += "$($etaSpan.Hours) hours "
      }
      if ($etaSpan.Minutes -gt 0) {
        $etaOutput += "$($etaSpan.Minutes) minutes "
      }
      if ($etaSpan.Seconds -gt 0) {
        $etaOutput += "$($etaSpan.Seconds) seconds "
      }
    }

    # Initialize progress bar
    $i = $i + 1
    $a = 100 * (($i - 1) / ($FileNumber))
    $barStatus = "{0:N1}% - Time remaining: {1}" -f $a, $etaOutput
    $Status = "{0:N1}%" -f $a

    # Variables for the file
    $currentFile = @{
      fullFilePath = $_.FullName
      path         = Split-Path -Path $_.FullName -Parent
      name         = (GetFilename( Split-Path -Path $_.FullName -Leaf )).fileName
      extension    = (GetFilename( Split-Path -Path $_.FullName -Leaf )).extension
    }

    # Analyze File metadatas
    Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing $($currentFile.name).$($currentFile.extension) ..." -Status "$($barStatus)"
    Write-Host " $($i)/$($FileNumber) | $($Status) | $($currentFile.name).$($currentFile.extension) " -Background Yellow -Foreground Black
    $exifData = Get-ExifInfo $currentFile

    $fileTypeCheck = CheckFileType $currentFile $exifData
    switch ( $fileTypeCheck.action ) {
      'IsValid' {
        # File type and extension coincide
        OutputCheckFileType "valid" $currentFile.extension

        # Creation date workflow
        if ( $exifData.createDate -eq $defaultDate ) {
          # Creation date not detected
          OutputCheckCreationDate "undefined"

          # Parsed data workflow
          if ( $exifData.parsedDate -ne $defaultDate ) {
            # Valid parsed date
            OutputParsing "parsed"

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$($barStatus)"
            Write-ExifInfo $currentFile (OffsetInput($exifData.parsedDate)).toString("yyyy:MM:dd HH:mm:ss")

            # Rename item
            RenameFile $currentFile (OffsetInput($exifData.parsedDate)).toString("yyyyMMdd HHmmss")
            OutputFileResult "success"
            Write-Host ""
          }
          else {
            # No parsing possible
            OutputParsing "nomatch"

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Waiting for alternative date ..." -Status "$($barStatus)"

            $altDate = AlternativeDatesWorkflow $currentFile $exifData

            if ( $altDate -ne $defaultDate ) {
              # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$($barStatus)"
              Write-ExifInfo $currentFile $altDate.toString("yyyy:MM:dd HH:mm:ss")

              # Rename item
              RenameFile $currentFile $altDate.toString("yyyyMMdd HHmmss")
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
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$($barStatus)"
          Write-ExifInfo $currentFile (OffsetInput($exifData.createDate)).toString("yyyy:MM:dd HH:mm:ss")

          # Rename file
          RenameFile $currentFile (OffsetInput($exifData.createDate)).toString("yyyyMMdd HHmmss")
          OutputFileResult "success"
        }
        Write-Host ""
      }
      'Rename' {
        # Change file extension
        # Rename file changing extension
        OutputCheckFileType "mismatch" $currentFile.extension
        ChangeExtension $currentFile.fullFilePath $fileTypeCheck.extension

        # Define the new file
        $newFile = $currentFile
        $newFile.extension = $fileTypeCheck.extension
        $newFile.fullFilePath = "$($newFile.path)\$($newFile.name).$($newFile.extension)"

        # Searching for creation date
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading metadata from renamed file ..." -Status "$($barStatus)"
        $newExifData = Get-ExifInfo $newFile

        if ( $newExifData.createDate -eq $defaultDate) {
          # Creation date not detected
          OutputCheckCreationDate "undefined"

          # Parse date from filename
          if ( $newExifData.parsedDate -ne $defaultDate ) {
            # Valid parsed date
            OutputParsing "parsed"

            # Update metadatas
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$($barStatus)"
            Write-ExifInfo $newFile (OffsetInput($newExifData.parsedDate)).toString("yyyy:MM:dd HH:mm:ss")

            # Rename item
            RenameFile $newFile (OffsetInput($newExifData.parsedDate)).toString("yyyyMMdd HHmmss")
            OutputFileResult "success"
          }
          else {
            # No parsing possible
            OutputParsing "nomatch"

            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Waiting for alternative date ..." -Status "$($barStatus)"

            $altDate = AlternativeDatesWorkflow $newFile $exifData
            if ( $altDate -ne $defaultDate ) {
              # Update all dates in the metadata
              Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$($barStatus)"
              Write-ExifInfo $newFile $altDate.toString("yyyy:MM:dd HH:mm:ss")

              # Rename item
              RenameFile $newFile $altDate.toString("yyyyMMdd HHmmss")
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
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$($barStatus)"
          Write-ExifInfo $newFile (OffsetInput($newExifData.createDate)).toString("yyyy:MM:dd HH:mm:ss")

          # Rename file
          RenameFile $newFile (OffsetInput($newExifData.createDate)).toString("yyyyMMdd HHmmss")
          OutputFileResult "success"
        }
        Write-Host ""
      }
      'Convert' {
        OutputCheckFileType "convert"
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Converting file ..." -Status "$($barStatus)"

        ConvertFile $currentFile $exifData
      }
      Default {
        # File probably not supported
        OutputCheckFileType "unsupported"
        Write-Host ""
      }
    }
  }

  
}

function OffsetInput($inputDate) {
  # Parse offset
  $offset = @{
    direction = $UTCOffset.substring(0, $UTCOffset.length - 5)
    hour      = [int]$UTCOffset.substring(1, $UTCOffset.length - 4)
    minute    = [int]$UTCOffset.substring(4)
  }

  # Offset the date
  switch ($offset.direction) {
    '+' { $outputDate = $inputDate.AddHours($offset.hour).AddMinutes($offset.minute) }
    '-' { $outputDate = $inputDate.AddHours($offset.hour * -1).AddMinutes($offset.minute * -1) }
    Default {
      Write-Error -Message "Unhandled exception with Offset direction, offset is: $($offset.direction)" -ErrorAction Stop
    }
  }

  return $outputDate
}