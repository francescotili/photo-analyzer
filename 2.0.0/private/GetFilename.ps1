Function GetFilename {
  <#
    .SYNOPSIS
      Extract the filename removing the extension
    
    .EXAMPLE
      $response = GetFilename($filename);
      $name = $response.name
      $extension = $response.extension
    
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

  # Return the filename and extension
  $ReturnValue = "" | Select-Object -Property fileName, extension
  $ReturnValue.fileName = $regMatches.Groups[1].Value
  $ReturnValue.extension = ($regMatches.Groups[2].Value).replace('.','')
  return $ReturnValue
}