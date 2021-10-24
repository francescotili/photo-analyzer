Function ChangeExtension {
  <#
    .SYNOPSIS
      Change the extension of the specified file
    
    .PARAMETER Path
      Complete file path of the file
    
    .PARAMETER Extension
      The new extension
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$Path,

    [Parameter(Mandatory=$true)]
    [String]$Extension
  )

  # Remove extension from original file Path
  [String]$PathNoExtension = $Path.Substring(0, $Path.LastIndexOf('.'))

  # Rename the item
  # TO DO: Check if file already exist!
  Move-Item -Path "$($Path)" -Destination "$($PathNoExtension).$($Extension)"
  OutputRenameResult "extensionChanged" $Extension
}