function ConvertFile {
  <#
    .SYNOPSIS
      Convert a specified file. Used for video format through HandBrakeCLI.
      Conversion is managed in an automated manner with fixed conversion settings.
    
    .EXAMPLE
      ConvertFile $inputFile
    
    .PARAMETER inputFile
      The file object to convert
    
    .PARAMETER exifData
      The complete exifData of the input file
  #>

  [CmdletBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputFile,

    [Parameter(Mandatory = $true)]
    $exifData
  )

  # Conversion settings
  $conversionSettings = @{
    "AVI"  = @{
      converter  = "handbrake";
      parameters = "-d bob -e x264 -q 22 -B 192"
    }
    "WMV"  = @{
      converter  = "handbrake";
      parameters = "-d bob -e x264 -q 22 -B 192"
    }
    "HEIC" = @{
      converter  = "magick";
      parameters = ""
    }
  }
  $conversionFormat = @{
    "AVI"  = "mp4"
    "WMV"  = "mp4"
    "HEIC" = "jpg"
  }

  # File details
  $backupExtension = "$($inputFile.extension)_original"

  # Check if extension match and run the conversion
  if ( $conversionFormat.Contains( $exifData.fileType )) {
    # We have a match
    # Define the output file
    $outputFile = @{
      path         = $inputFile.path
      name         = $inputFile.name
      extension    = $conversionFormat[$exifData.fileType]
      fullFilePath = "$($inputFile.path)\$($inputFile.name).$($conversionFormat[$exifData.fileType])"
    }

    # Convert the file
    switch ($conversionSettings[$exifData.fileType].converter) {
      "handbrake" {
        # 2> $null is to hide HandBrakeCLI useless output
        HandBrakeCLI -i $inputFile.fullFilePath -o $outputFile.fullFilePath $conversionSettings[$exifData.fileType].parameters 2> $null
      }
      "magick" {
        magick $inputFile.fullFilePath $outputFile.fullFilePath 
      }
      Default {}
    }

    # Check if file has been created
    if ( Test-Path $outputFile.fullFilePath -PathType Leaf ) {
      OutputConversionResult "success"

      if ( $exifData.createDate -eq $defaultDate ) {
        # Creation date not detected
        OutputCheckCreationDate "undefined"

        # Parse date from filename
        if ( $exifData.parsedDate -ne $defaultDate ) {
          # Valid parsed date
          OutputParsing "parsed"

          # Update metadatas
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$Status%"
          Write-ExifInfo $outputFile ($exifData.parsedDate).toString("yyyy:MM:dd HH:mm:ss")

          # Rename item
          RenameFile $outputFile ($exifData.parsedDate).toString("yyyyMMdd HHmmss")

          # Make a backup of input file
          ChangeExtension $inputFile.fullFilePath $backupExtension
          OutputFileResult "success"
          Write-Host ""
        }
        else {
          # No parsing possible
          OutputParsing "nomatch"

          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Waiting for alternative date ..." -Status "$Status%"

          $altDate = AlternativeDatesWorkflow $inputFile $exifData

          if ( $altDate -ne $defaultDate ) {
            # Update all dates in the metadata
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$Status%"
            Write-ExifInfo $outputFile $altDate.toString("yyyy:MM:dd HH:mm:ss")

            # Rename item
            RenameFile $outputFile $altDate.toString("yyyyMMdd HHmmss")
  
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
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Writing metadata ..." -Status "$Status%"
        Write-ExifInfo $outputFile ($exifData.createDate).toString("yyyy:MM:dd HH:mm:ss")

        # Rename item
        RenameFile $outputFile ($exifData.createDate).toString("yyyyMMdd HHmmss")

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