function Set-Path {
  <#
    .SYNOPSIS
      This function ask the user for the path to be analyzed and save it as a global variable
  #>
  
  $Path = Read-Host "Please specify the folder to analyze (i.e.: D:\user\Pictures)"
  
  if ($Path) {
    # Path has been specified
    $WorkingPath = $path -replace '["]', ''    
    if (-Not(Test-Path -Path "$WorkingPath")) {
      # Path not valid
      OutputUserError "invalidPath"
    }
    else {
      # Valid path
      Set-Variable -Name WorkingFolder -Value $WorkingPath -Scope Global
      return $WorkingPath
    }
  }
  else {
    # No path specified
    OutputUserError "emptyPath"
  }
}

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
    [Parameter(Mandatory = $true)]
    [String]$Path,

    [Parameter(Mandatory = $true)]
    [String]$Extension
  )

  # Remove extension from original file Path
  [String]$PathNoExtension = $Path.Substring(0, $Path.LastIndexOf('.'))

  # Rename the item
  # TO DO: Check if file already exist!
  Move-Item -Path "$($Path)" -Destination "$($PathNoExtension).$($Extension)"
  OutputRenameResult "extensionChanged" $Extension
}

Function CheckFileType {
  <#
    .SYNOPSIS
      Analyze the file type with ExifTool and return the correct operation to make for the PhotoAnalyzer main function
      - 'IsValid' -> Means that the extension and FileType corresponds, so the analyzer can continue the operations
      - 'Rename' -> Means that the extension doesn't match the fileType, so the file extension need to be changed before the analyzer can continue the operations
      - '' -> Means that something is strange with the file or the case is not handled
    
    .PARAMETER inputFile
      Required. A "FILE" object
    
    .PARAMETER exifData
      Required. The complete exifData object
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputFile,

    [Parameter(Mandatory = $true)]
    $exifData
  )
  
  $ReturnValue = "" | Select-Object -Property action, extension

  # Define an array of supported extensions
  $SupportedExtensions = @("jpg", "JPG", "jpeg", "JPEG", "heic", "HEIC", "png", "PNG", "gif", "GIF", "mp4", "MP4", "m4v", "M4V", "mov", "MOV", "gif", "GIF", "avi", "AVI", "wmv", "WMV")

  # Define expected extensions based on detected file type
  $extensions = @{
    "JPEG" = "jpg"
    "PNG"  = "png"
    "GIF"  = "gif"
    "MOV"  = "mov"
    "MP4"  = "mp4"
    "HEIC" = "heic"
  }

  # File Types that will be converted
  $conversions = @("AVI", "WMV")

  # Check if extension match and return value
  if ( $SupportedExtensions.Contains( $inputFile.extension ) ) {
    # Check if the extension is the expected based on the FileType
    if ( $extensions[$exifData.fileType] -ceq $inputFile.extension ) {
      $ReturnValue.action = "IsValid"
    }
    elseif ( $conversions.Contains($exifData.fileType)) {
      $ReturnValue.action = "Convert"
    }
    else {
      $ReturnValue.action = "Rename"
      $ReturnValue.extension = $extensions[$exifData.fileType]
    }
  }

  return $ReturnValue
}

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
  
  return $Date -match "(19|20\d{2})(?:[_.-:])?(0[1-9]|1[0-2])(?:[_.-:])?([0-2]\d|3[0-1]).*([0-1][0-9]|2[0-3])(?:[_.-:])?([0-5][0-9])(?:[_.-:])?([0-5][0-9])([+-])?([0-1][0-9]|2[0-4])?(?:[_.-:])?([0-5][0-9])?"
}

Function OffsetDateTime {
  <#
    .SYNOPSIS
      This private functions take a date and offsets it with the second parameter of a UTC Offset. Returns a normal date in YYYY:MM:DD hh:mm:ss format
    
    .PARAMETER inputDate
      Required. Date to offset
    
    .PARAMETER UTCOffset
      Required. Offset in UTC format of +/-hh:mm. Example: +01:30 or -02:00
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputDate,

    [Parameter(Mandatory = $true)]
    [String]$UTCOffset
  )

  # Parse offset
  $offset = @{
    direction = $UTCOffset.substring(0, $UTCOffset.length - 5)
    hour      = [int]$UTCOffset.substring(1, $UTCOffset.length - 4)
    minute    = [int]$UTCOffset.substring(4)
  }

  # Offset the date
  switch ($offset.direction) {
    '+' { $outputDate = $inputDate.AddHours($offset.hour).AddMinutes($offset.minute) }
    '-' { $outputDate = $inputDate.AddHours($offset.hour * -1).AddMinutes($offset.minute * -1) }
    Default {
      Write-Error -Message "Unhandled exception with Offset direction, offset is: $($offset.direction)" -ErrorAction Stop
    }
  }

  return $outputDate
}

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
    [Parameter(Mandatory = $true)]
    [String]$file
  )
  $pattern = "(.+?)(\.[^.]*$|$)"

  # Match the file with pattern
  $regMatches = [regex]::Matches($file, $pattern)

  # Return the filename and extension
  return @{
    fileName  = $regMatches.Groups[1].Value
    extension = ($regMatches.Groups[2].Value).replace('.', '')
  }
}