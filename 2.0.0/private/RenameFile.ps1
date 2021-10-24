Function RenameFile {
  <#
    .SYNOPSIS
      Rename the specified file adding a number like +000 for conflicts

    .PARAMETER inputFile
      Required. The file object to rename
    
    .PARAMETER NewName
      Required. The new name to assign to the file (without extension)
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputFile,

    [Parameter(Mandatory = $true)]
    [String]$NewName
  )

  [Int]$i = 0
  [String]$CopyNum = '{0:d3}' -f $i

  # Variables for the file
  [String]$oldFile = $inputFile.fullFilePath
  [String]$TempName = "temp_file.bak"
  [String]$TempFile = "$($inputFile.path)\$($TempName)"
  [String]$FinalName = "$($NewName)+$($CopyNum).$($inputFile.extension)"
  [String]$NewFile = "$($inputFile.path)\$($FinalName)"

  # Temporary renaming of the file to avoid conflict with itself
  Rename-Item -Path $OldFile -NewName $TempName

  while (Test-Path -path $NewFile) {
    # New fileName already exist, increment CopyNum
    $i += 1
    $CopyNum = '{0:d3}' -f $i
    $FinalName = "$($NewName)+$($CopyNum).$($inputFile.extension)"
    $NewFile = "$($inputFile.path)\$($FinalName)"
  }

  Rename-Item -Path $TempFile -NewName $FinalName
  OutputRenameResult "fileRenamed" $FinalName
}