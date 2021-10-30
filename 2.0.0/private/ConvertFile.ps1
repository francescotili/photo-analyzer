function ConvertFile {
  <#
    .SYNOPSIS
      Convert a specified file. Used for video format through HandBrakeCLI.
      Conversion is managed in an automated manner with fixed conversion settings.
    
    .EXAMPLE
      ConvertFile $inputFile
    
    .PARAMETER inputFile
      The file object to convert
  #>

  [CmdletBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputFile
  )

  # Conversion settings
  $conversionSettings = @{
    "AVI" = @{
      decomb       = "bob";
      encoder      = "x264";
      videoQuality = "22";
      audioBitrate = "192";
    }
    "WMV" = @{
      decomb       = "bob";
      encoder      = "x264";
      videoQuality = "22";
      audioBitrate = "192";
    }
  }
  $conversionFormat = @{
    "AVI" = "mp4"
    "WMV" = "mp4"
  }

  # File details
  $fileType = Get-ExifInfo $inputFile "FileType"
  $backupExtension = "$($inputFile.extension)_original"

  # Check if extension match and run the conversion
  if ( $conversionFormat.Contains( $fileType )) {
    # We have a match
    # Define the output file
    $outputFile = @{
      path = $inputFile.path
      name = $inputFile.name
      extension = $conversionFormat[$fileType]
      fullFilePath = "$($inputFile.path)\$($inputFile.name).$($conversionFormat[$fileType])"
    }

    # Convert the file  
    # 2> $null is to hide HandBrakeCLI useless output
    HandBrakeCLI -i $inputFile.fullFilePath -o $outputFile.fullFilePath -d $conversionSettings[$fileType].decomb -e $conversionSettings[$fileType].encoder -q $conversionSettings[$fileType].videoQuality -B $conversionSettings[$fileType].audioBitrate 2> $null

    # Check if file has been created
    if ( Test-Path $outputFile.fullFilePath -PathType Leaf ) {
      OutputConversionResult "success"

      # Read metadata from input file
      OutputCheckCreationDate "analyzing"
      Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
      $Parsed = Get-ExifInfo $inputFile "DateCreated"

      if ( $Parsed -eq "") {
        # Creation date not detected
        OutputCheckCreationDate "undefined"

        # Parse date from filename
        $parsedDateTime = ParseFilename $inputFile.name
        if ( $parsedDateTime -ne "" ) {
          # Valid parsed date
          OutputParsing "parsed"
          # Parse parsedData
          $Parsed = ParseDateTime $parsedDateTime

          # Update metadatas
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $outputFile ($Parsed.date).ToString("yyyy:MM:dd hh:mm:ss")

          # Rename item
          RenameFile $outputFile $Parsed.fileName

          # Make a backup of input file
          ChangeExtension $inputFile.fullFilePath $backupExtension
          OutputFileResult "success"
          Write-Host ""
        }
        else {
          # No parsing possible
          OutputParsing "nomatch"

          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

          $altWorkflow = AlternativeDatesWorkflow $inputFile
          if ( $altWorkflow.action -eq "SaveMetadata" ) {
            # Update all dates in the metadata
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $outputFile $altWorkflow.date

            # Rename item
            RenameFile $outputFile $altWorkflow.fileName
  
            # Make a backup of input file
            ChangeExtension $inputFile.fullFilePath $backupExtension
            OutputFileResult "success"
            Write-Host ""
          }
          else {
            # Invalid choice
            OutputFileResult "skip"
            Write-Host ""
          }
        }
      }
      else {
        # Creation date valid
        OutputCheckCreationDate "valid"

        # Update all dates in the metadata
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
        Write-ExifInfo $outputFile ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss")

        # Rename item
        RenameFile $outputFile $Parsed.fileName

        # Make a backup of input file
        ChangeExtension $inputFile.fullFilePath $backupExtension
        OutputFileResult "success"
        Write-Host ""
      }
    }
    else {
      OutputConversionResult "error"
      OutputFileResult "skip"
      Write-Host ""
    }

  }
  else {
    # Unsupported extension
      OutputConversionResult "unsupported"
      OutputFileResult "skip"
      Write-Host ""
  }
}