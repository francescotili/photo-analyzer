Function AutoAnalyzeFiles {
  <#
    .SYNOPSIS
      Completely automated AnalyzeFiles
    
    .PARAMETER WorkingFolder
      The folder to scan and to elaborate.
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$WorkingFolder
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
    $barStatus = "{0:N1}% - Time remaining: {1}" -f $a,$etaOutput
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
            Write-ExifInfo $currentFile ($exifData.parsedDate).toString("yyyy:MM:dd HH:mm:ss")

            # Rename item
            RenameFile $currentFile ($exifData.parsedDate).toString("yyyyMMdd HHmmss")
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
          Write-ExifInfo $currentFile ($exifData.createDate).toString("yyyy:MM:dd HH:mm:ss")

          # Rename file
          RenameFile $currentFile ($exifData.createDate).toString("yyyyMMdd HHmmss")
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
            Write-ExifInfo $newFile ($newExifData.parsedDate).toString("yyyy:MM:dd HH:mm:ss")

            # Rename item
            RenameFile $newFile ($newExifData.parsedDate).toString("yyyyMMdd HHmmss")
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
          Write-ExifInfo $newFile ($newExifData.createDate).toString("yyyy:MM:dd HH:mm:ss")

          # Rename file
          RenameFile $newFile ($newExifData.createDate).toString("yyyyMMdd HHmmss")
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

function AlternativeDatesWorkflow {
  <#
    .SYNOPSIS
      Manage the workflow when the file need alternative dates searching
    
    .PARAMETER File
      The file object to be processed
    
    .PARAMETER ExifData
      The complete exifData response
    
    .RETURNS
      The action to be done and date selected
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $File,

    [Parameter(Mandatory = $true)]
    $exifData
  )

  $ReturnValue = $defaultDate
  $menu = @{}

  # Presents option to the user and wait for input
  (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Unlock.wav").Play()
  OutputAskForInput

  if (($exifData.altDates).Count -gt 0) {
    # We have at least one Alternative Date
    for ($i = 1; $i -lt ($exifData.altDates).Count; $i++) {
      Write-Host "  $($i) | $($Emojis["calendar"]) Alternative date/time     : $($exifData.altDates[$i].toString("yyyy:MM:dd HH:mm:ss"))"
      $menu.Add($i, $exifData.altDates[$i])
    }
  }
  if ( $exifData.modifyDate -ne $defaultDate ) {
      Write-Host "  $($menu.Count + 1) | $($Emojis["calendar"]) File Modified Date/Time   : $($exifData.modifyDate.toString("yyyy:MM:dd HH:mm:ss"))"
    $menu.Add(($menu.Count + 1), $exifData.modifyDate)
  }
  # TO DO: Add functionality for UTC Offset?
  Write-Host "  $($menu.Count + 1) | $($Emojis["pen"]) Manually insert date"
  $menu.Add(($menu.Count + 1), $defaultDate)

  $userSelection = Read-Host "   Insert number"
  
  # Validate input
  if ( $userSelection -match '^\d+$' ) {
    [int]$choice = $userSelection
    if ($choice -le $menu.Count ) {
      # Evaluate workflow and return what needs to be done
      if ($menu.Item($choice) -ne $defaultDate ) {
        $ReturnValue = $menu.Item($choice)
      }
      else {
        $UserData = Read-Host "   Insert date (year, month, day, hour, minute, second)"
        if ( $userData -ne "" ) {
          if ( IsValidDate $UserData ) {
            # Valid date, parse customData
            $Parsed = ParseDateTime $UserData
            $ReturnValue = $Parsed.date
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
    }
    else {
      OutputUserError "invalidChoice"
    }
  }
  else {
    OutputUserError "invalidChoice"
  }

  return $ReturnValue
}