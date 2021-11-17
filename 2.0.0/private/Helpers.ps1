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