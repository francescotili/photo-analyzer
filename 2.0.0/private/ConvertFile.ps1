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
      "decomb" = "bob";
      "encoder" = "x264";
      "videoQuality" = "22";
      "audioBitrate" = "192";
    }
    "WMV" = @{
      "decomb" = "bob";
      "encoder" = "x264";
      "videoQuality" = "22";
      "audioBitrate" = "192";
    }
  }
  $conversionFormat = @{
    "AVI" = "mp4"
    "WMV" = "mp4"
  }

  # File details
  $fileType = Get-ExifInfo $inputFile.fullFilePath "FileType"
  $backupExtension = "$($inputFile.extension)_original"

  # Check if extension match and run the conversion
  if ( $conversionFormat.Contains( $fileType )) { # We have a match
    # Define the output file
    $outputFile = "" | Select-Object -Property path, name, extension, fullFilePath
    $outputFile.path = $inputFile.path
    $outputFile.name = $inputFile.name
    $outputFile.extension = $conversionFormat[$fileType]
    $outputFile.fullFilePath = "$($outputFile.path)\$($outputFile.name).$($outputFile.extension)"

    # Convert the file  
    # 2> $null is to hide HandBrakeCLI useless output
    HandBrakeCLI -i $inputFile.fullFilePath -o $outputFile.fullFilePath -d $conversionSettings[$fileType]["decomb"] -e $conversionSettings[$fileType]["encoder"] -q $conversionSettings[$fileType]["videoQuality"] -B $conversionSettings[$fileType]["audioBitrate"] 2> $null

    # Check if file has been created
    if ( Test-Path $outputFile.fullFilePath -PathType Leaf ) {
      Write-Host " >> $($Emojis["check"]) Conversion completed"

      # Read metadata from input file
      Write-Host " >> Analyzing original file metadatas..."
      Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Reading creation date ..." -Status "$($Status)%"
      $Parsed = Get-ExifInfo $inputFile.fullFilePath "DateCreated"

      if ( $Parsed -eq "") { # Creation date not detected
        Write-Host " >> $($Emojis["warning"]) Creation date not detected! Try parsing from filename..."

        # Parse date from filename
        $parsedDateTime = ParseFilename $inputFile.name
        if ( $parsedDateTime -ne "" ) { # Valid parsed date
          Write-Host " >> $($Emojis["check"]) Valid date successfully parsed"
          # Parse parsedData
          $Parsed = ParseDateTime $parsedDateTime "CustomDate"

          # Update metadatas
          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
          Write-ExifInfo $outputFile $Parsed.date

          # Rename item
          RenameFile $outputFile $Parsed.fileName

          # Make a backup of input file
          ChangeExtension $inputFile.fullFilePath $backupExtension
          Write-Host "   FILE SUCCESSFULLY UPDATED   " -BackgroundColor DarkGreen -ForegroundColor White
          Write-Host ""
        } else { # No parsing possible
          Write-Host " >> $($Emojis["warning"]) Parsing unsuccessfull! Trying other dates..."

          Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Analyzing modify date ..." -Status "$Status%"

          $altWorkflow = AlternativeDatesWorkflow $inputFile.fullFilePath
          if ( $altWorkflow.action -eq "SaveMetadata" ) { # Update all dates in the metadata
            Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
            Write-ExifInfo $outputFile $altWorkflow.date

            # Rename item
            RenameFile $outputFile $altWorkflow.fileName
  
            # Make a backup of input file
            ChangeExtension $inputFile.fullFilePath $backupExtension
            Write-Host "   FILE SUCCESSFULLY UPDATED   " -BackgroundColor DarkGreen -ForegroundColor White
            Write-Host ""
          } else { # Invalid choice
            Write-Host "         FILE  SKIPPED         " -BackgroundColor DarkRed -ForegroundColor White
            Write-Host ""
          }
        }
      } else { # Creation date valid
        Write-Host " >> $($Emojis["check"]) Creation date valid"

        # Update all dates in the metadata
        Write-Progress -Activity $Activity -PercentComplete $a -CurrentOperation "Updating metadata ..." -Status "$Status%"
        Write-ExifInfo $outputFile $Parsed.date

        # Rename item
        RenameFile $outputFile $Parsed.fileName

        # Make a backup of input file
        ChangeExtension $inputFile.fullFilePath $backupExtension
        Write-Host "   FILE SUCCESSFULLY UPDATED   " -BackgroundColor DarkGreen -ForegroundColor White
        Write-Host ""
      }
    } else {
      Write-Host " >> $($Emojis["error"]) Unhandled error during conversion"
      Write-Host "         FILE  SKIPPED         " -BackgroundColor DarkRed -ForegroundColor White
      Write-Host ""
    }

  } else { # Unsupported extension
    Write-Host " >> $($Emojis["error"]) Unsupported video type"
    Write-Host "         FILE  SKIPPED         " -BackgroundColor DarkRed -ForegroundColor White
    Write-Host ""
  }
}