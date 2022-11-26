function Set-Path {
  <#
    .SYNOPSIS
      This function ask the user for the path to be analyzed and save it as a global variable
  #>
  
  $Path = Read-Host "Please specify the folder to analyze"
  
  if ($Path) {
    # Path has been specified
    $WorkingPath = $path -replace '["]', ''    
    if (-Not(Test-Path -Path "$WorkingPath")) {
      # Path not valid
      OutputUserError "invalidPath"
    }
    else {
      # Valid path
      return $WorkingPath
    }
  }
  else {
    # No path specified
    OutputUserError "emptyPath"
  }
}

function Set-Offset {
  <#
    .SYNOPSIS
      This function ask the user for the desired offset in UTC format and save it as a global variable
  #>

  $Offset = Read-Host "Please specify the UTC offset to use (ex. +02:34)"

  if ($Offset) {
    # Input specified
    if ( IsValidOffset($Offset)) {
      # Valid offset
      return $Offset
    }
    else {
      OutputUserError "invalidOffset"
    }
  }
  else {
    # No input specified
    OutputUserError "emptyOffset"
  }
}

function IsValidOffset($offset) {
  <#
    .SYNOPSIS
      This function matches a user input against a format like +hh:mm or -hh:mm
  #>

  $regex = "^([+-])(\d{2})(?:[_.-:])?(0[0-9]|[1-5][0-9])$"
  return $offset -match $regex
}