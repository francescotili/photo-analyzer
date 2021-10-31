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

  $datePattern = "(19|20\d{2})(?:[_.-:])?(0[1-9]|1[0-2])(?:[_.-:])?([0-2]\d|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-:])?([0-5][0-9])(?:[_.-:])?([0-5][0-9])([+-])?([0-1][0-9]|2[0-4])?(?:[_.-:])?([0-5][0-9])?"

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
    
    if ($dateMatches.Groups[8].Value -ne "") {
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

Function ParseFilename {
  <#
    .SYNOPSIS
      Try to parse the date and time from a string (use for filenames)
    
    .EXAMPLE
      ParseFilename $filename
    
    .PARAMETER FileName
      Required. The filename string to parse (it should work also with the extension)
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$filename
  )
  $pattern = "(19|20\d{2})(?:[_.-])?(0[1-9]|1[0-2])(?:[_.-])?([0-2]\d|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-])?([0-5][0-9])(?:[_.-])?([0-5][0-9])"

  # Check if filename is parsable
  if ( $filename -match $pattern ) {
    # Match the filename with pattern
    $regMatches = [regex]::Matches($filename, $pattern)

    # Identify the capture groups
    $returnDate = Get-Date `
    -Year $regMatches.Groups[1].Value `
    -Month $regMatches.Groups[2].Value `
    -Day $regMatches.Groups[3].Value `
    -Hour $regMatches.Groups[4].Value `
    -Minute $regMatches.Groups[5].Value `
    -Second $regMatches.Groups[6].Value

    return $returnDate
  }
  else {
    # Parsing not possible
    return Get-Date -Date "01-01-1800 00:00:00"
  }
}

Function ParseTag {
  <#
    .SYNOPSIS
      Take the raw data from Exiftool and search for the correct tag, returning the string value.
      Please use exiftool standard output or `-s` short output. The output must have a line for
      every Tag, in the format "TagString : TagValue"
    
    .EXAMPLE
      ParseTag $exifData $tagName
    
    .PARAMETER exifData
      Required. Complete exiftool raw data response
    
    .PARAMETER tagName
      Required. The name of the tag that you want to retrieve, as exiftool would return it. As examples:
      - 'File Type'
      - 'Shutter Speed'
      - 'Date/Time Original'
    
    .RETURNS
      Returns an array of results.
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $exifData,

    [Parameter(Mandatory = $true)]
    [String]$targetTag
  )

  $tagPattern = "(.*?): (.*)"

  for ($i = 0; $i -lt $exifData.Count; $i++) {
    if ( $exifData[$i] -match $tagPattern ) {
      $tagName = ([regex]::Matches($exifData[$i], $tagPattern)).Groups[1].Value.trim()
      $tagValue = ([regex]::Matches($exifData[$i], $tagPattern)).Groups[2].Value.trim()

      # If the tag matches the target tag, return the value
      if ($tagName -eq $targetTag) {
        return $tagValue
      }
    }
  }
}

Function ParseTagDateTime {
  <#
    .SYNOPSIS
      Take the raw data from Exiftool and search for the correct tag, returning the string value.
      Please use exiftool standard output or `-s` short output. The output must have a line for
      every Tag, in the format "TagString : TagValue"
    
    .EXAMPLE
      ParseTagDateTime $exifData $tagName
    
    .PARAMETER exifData
      Required. Complete exiftool raw data response
    
    .PARAMETER tagName
      Required. The name of the tag that you want to retrieve, as exiftool would return it. As examples:
      - 'File Type'
      - 'Shutter Speed'
      - 'Date/Time Original'
    
    .RETURNS
      Returns an array of results.
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $exifData,

    [Parameter(Mandatory = $true)]
    [String]$targetTag
  )

  $tagPattern = "(.*?): (.*)"

  for ($i = 0; $i -lt $exifData.Count; $i++) {
    if ( $exifData[$i] -match $tagPattern ) {
      $tagName = ([regex]::Matches($exifData[$i], $tagPattern)).Groups[1].Value.trim()
      $tagValue = ([regex]::Matches($exifData[$i], $tagPattern)).Groups[2].Value.trim()

      # If the tag matches the target tag, return the value
      if ($tagName -eq $targetTag) {
        return (ParseDateTime $tagValue).date
      }
    }
  }
}