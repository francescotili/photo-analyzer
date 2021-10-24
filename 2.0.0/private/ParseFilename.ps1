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
    # We have a match
    # Match the filename with pattern
    $regMatches = [regex]::Matches($filename, $pattern)

    # Identify the capture groups
    $year = $regMatches.Groups[1].Value
    $month = $regMatches.Groups[2].Value
    $day = $regMatches.Groups[3].Value
    $hour = $regMatches.Groups[4].Value
    $minute = $regMatches.Groups[5].Value
    $second = $regMatches.Groups[6].Value

    # Return date in format "YYYY:MM:dd HH:mm:ss"
    $returnDate = "$($year):$($month):$($day) $($hour):$($minute):$($second)"

    if ( IsValidDate $returnDate ) {
      # Valid parsed date
      return $returnDate
    }
    else {
      return ""
    }
  }
  else {
    # Parsing not possible
    return ""
  }
}