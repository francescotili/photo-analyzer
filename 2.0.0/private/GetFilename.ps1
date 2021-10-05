Function GetFilename {
  <#
    .SYNOPSIS
      Extract the filename removing the extension
    
    .EXAMPLE
      $name = GetFilename($filename);
    
    .PARAMETER File
      Required. The complete name of file with extension. Do not pass a relative or absolute path
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$file
  )
  $pattern = "(.+?)(\.[^.]*$|$)"

  # Match the file with pattern
  $regMatches = [regex]::Matches($file, $pattern)

  # Return the filename
  return $regMatches.Groups[1].Value
}