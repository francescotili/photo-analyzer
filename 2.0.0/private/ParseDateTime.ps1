Function ParseDateTime {
  <#
    .SYNOPSIS
      Parse a DateTime tag from exiftool to separate the various date and time component and then calculate the new file name and correct date in the final format.
      Returns a custom object with 'fileName' and 'date' properties
    
    .PARAMETER Tag
      Required. The complete tag returned by a single exiftool query
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Tag
  )

  $Pattern = "(.*?) : (.*)"
  
  # Check if Tag is parsable
  if ( $Tag -match $Pattern ) {
    # Match the tag and capture groups
    $regMatches = [regex]::Matches($Tag, $Pattern)

    # Identify the capture groups
    $exifTag = @{
      name  = $regMatches.Groups[1].Value
      value = $regMatches.Groups[2].Value
    }

    # Parse the date and time
    $datePattern = "(19|20\d{2})(?:[_.-:])?(0[1-9]|1[0-2])(?:[_.-:])?([0-2]\d|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-:])?([0-5][0-9])(?:[_.-:])?([0-5][0-9])([+-])?([0-1][0-9]|2[0-4])?(?:[_.-:])?([0-5][0-9])?"

    # Check if TagValue is a validDate
    if ( $exifTag.value -match $datePattern ) {
      # Match the tag and capture groups
      $dateMatches = [regex]::Matches($exifTag.value, $datePattern)

      # Identify the capture groups
      $parsedDate = @{
        year      = $dateMatches.Groups[1].Value
        month     = $dateMatches.Groups[2].Value
        day       = $dateMatches.Groups[3].Value
        hour      = $dateMatches.Groups[4].Value
        minute    = $dateMatches.Groups[5].Value
        second    = $dateMatches.Groups[6].Value
        utcoffset = @{
          direction = $dateMatches.Groups[7].Value
          hour      = $dateMatches.Groups[8].Value
          minute    = $dateMatches.Groups[9].Value
        }
      }

      # TO DO: return the parsedDate object
      # TO CHANGE!
      return @{
        fileName  = "$($parsedDate.year)$($parsedDate.month)$($parsedDate.day) $($parsedDate.hour)$($parsedDate.minute)$($parsedDate.second)"
        date      = "$($parsedDate.year):$($parsedDate.month):$($parsedDate.day) $($parsedDate.hour):$($parsedDate.minute):$($parsedDate.second)"
        utcoffset = "$($parsedDate.utcoffset.direction)$($parsedDate.utcoffset.hour):$($parsedDate.utcoffset.minute)"
      }
    }
    else {  
      Write-Host "The specified tag contains no date/time information!"
    }
  }
  else {
    Write-Host "The specified tag is not a valid exifTool tag!"
  }
}