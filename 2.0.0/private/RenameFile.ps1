Function RenameFile {
  <#
    .SYNOPSIS
      Rename the specified file adding a number like +000 for conflicts

    .PARAMETER Path
      Required. The complete path of the file to rename, without file name.
    
    .PARAMETER OldName
      Required. The old name of the file to rename (not the path!)
    
    .PARAMETER NewName
      Required. The new name to assign to the file (without extension)
    
    .PARAMETER Extension
      Required. The extension of the file
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$Path,

    [Parameter(Mandatory=$true)]
    [String]$OldName,

    [Parameter(Mandatory=$true)]
    [String]$NewName,

    [Parameter(Mandatory=$true)]
    [String]$Extension
  )

  [Int]$i = 0
  [String]$CopyNum = '{0:d3}' -f $i

  [String]$OldFile = "$($Path)\$($OldName).$($Extension)"
  [String]$TempName = "temp_file.bak"
  [String]$TempFile = "$($Path)\$($TempName)"
  [String]$FinalName = "$($NewName)+$($CopyNum).$($Extension)"

  # Temporary renaming of the file to avoid conflict with itself
  Rename-Item -Path $OldFile -NewName $TempName

  while (Test-Path -path $NewFile) {
    # New fileName already exist, increment CopyNum
    $i = += 1
    $CopyNum = '{0:d3}' -f $i
    $NewFile = "$($Path)\$($NewName)+$($CopyNum).$($Extension)"
    $FinalName = "$($NewName)+$($CopyNum).$($Extension)"
  }

  Rename-Item -Path $TempFile -NewName $FinalName
  Write-Host " >> File renamed: $FinalName"
}