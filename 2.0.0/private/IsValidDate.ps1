Function IsValidDate {
  <#
    .SYNOPSIS
      Check if a date has a valid format like YYYY:MM:DD hh:mm:ss.
      Returns a boolean $true or $false
    
    .PARAMETER Date
      Required. Date to check for validity
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Date
  )
  
  return $Date -match "^(19\d{2}|20\d{2})(?:[_.-:])?(0[1-9]|1[0-2])(?:[_.-:])?(0[1-9]|[1-2][0-9]|3[0-1])[ _.-:]([0-1][0-9]|2[0-3])(?:[_.-:])?([0-5][0-9])(?:[_.-:])?([0-5][0-9])([+-])?([0-1][0-9]|2[0-4])?(?:[_.-:])?([0-5][0-9])?$"
}