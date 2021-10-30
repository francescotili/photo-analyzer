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
    [String]$tagName
  )

  $tagPattern = "(.*?): (.*)"
  $returnMatches = @()

  for ($i = 0; $i -lt $exifData.Count; $i++) {
    if ( $exifData[$i] -match $tagPattern ) {
      $tagName = ([regex]::Matches($exifData[$i], $tagPattern)).Groups[1].Value.trim()
      $tagValue = ([regex]::Matches($exifData[$i], $tagPattern)).Groups[2].Value.trim()

      # If the tag matches the target tag, return the value
      if ($tagName -eq $targetTag) {
        $returnMatches += $tagValue
      }
    }
  }

  return $returnMatches
}