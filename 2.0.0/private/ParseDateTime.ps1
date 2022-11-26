Function ParseDateTime {
  <#
    .SYNOPSIS
      Parse a DateTime tag from exiftool to separate the various date and time component and then calculate the new file name and correct date in the final format.
      Returns a custom object with 'fileName' and 'date' properties
    
    .PARAMETER Tag
      Required. A single string containing the date/time to be parsed
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Tag
  )

  $datePattern = "(19\d{2}|20\d{2})(?:[_.-:])?(0[1-9]|1[0-2])(?:[_.-:])?(0[1-9]|[1-2][0-9]|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-:])?([0-5][0-9])(?:[_.-:])?([0-5][0-9])([+-])?([0-1][0-9]|2[0-4])?(?:[_.-:])?([0-5][0-9])?"

  # Check if TagValue is a validDate
  if ( $Tag -match $datePattern ) {
    # Match the tag and capture groups
    $dateMatches = [regex]::Matches($Tag, $datePattern)

    # Identify the capture groups
    $parsedDate = Get-Date `
      -year $dateMatches.Groups[1].Value `
      -month $dateMatches.Groups[2].Value `
      -day $dateMatches.Groups[3].Value `
      -hour $dateMatches.Groups[4].Value `
      -minute $dateMatches.Groups[5].Value `
      -second $dateMatches.Groups[6].Value
    
    if ($dateMatches.Groups[7].Value -ne "" -And $dateMatches.Groups[8].Value -ne "" -And $dateMatches.Groups[9].Value -ne "") {
      $utcOffset = "$($dateMatches.Groups[7].Value)$($dateMatches.Groups[8].Value):$($dateMatches.Groups[9].Value)"
    }
    else {
      $utcOffset = ""
    }

    return @{
      fileName  = $parsedDate.ToString("yyyyMMdd hhmmss")
      date      = $parsedDate
      utcoffset = $utcOffset
    }
  }
  else {
    return @{
      fileName  = ""
      date      = $defaultDate
      utcoffset = ""
    }
  }
}