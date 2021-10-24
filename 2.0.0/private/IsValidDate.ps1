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

  
  if ($Date -match "^(19|20)\d\d[:](0[1-9]|1[012])[:](0[1-9]|[12][0-9]|3[01])[ ]([0-1][0-9]|2[0-3])[:]([0-5][0-9])[:]([0-5][0-9])$") {
    return $true
  }
  else {
    return $false
  }
}