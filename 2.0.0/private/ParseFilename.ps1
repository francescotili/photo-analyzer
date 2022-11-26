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
  $pattern = "(19\d{2}|20\d{2})(?:[_.-])?(0[1-9]|1[0-2])(?:[_.-])?(0[1-9]|[1-2][0-9]|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-])?([0-5][0-9])(?:[_.-])?([0-5][0-9])"

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