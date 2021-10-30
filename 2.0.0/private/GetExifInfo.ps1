Function Get-ExifInfo {
  <#
    .SYNOPSIS
      Get the specified Exif information from the specified file based on filetype.
    
    .EXAMPLE
      Get-ExifInfo $file FileType
    
    .PARAMETER File
      Required. Complete file object to analyze.
    
    .PARAMETER InfoType
      Required. What type of information do you want to retrieve:
      - 'FileType' -> Returns the exiftool detected fileType
      - 'DateCreated' -> Returns the correct Tag for DateTime created
      - 'FileModifyDate' -> Returns the modifyDateTime for the file
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $File,

    [Parameter(Mandatory = $true)]
    [String]$InfoType
  )

  # OPTIMIZATION WORKFLOW
  # [ ] Analyze the file with Exiftool
  # [ ] Parse the tags and search for the correct tag
  # [ ] For every function call, return the cached value

  switch ($InfoType) {
    'FileType' {
      $Response = exiftool -FileType $File.fullFilePath
      return $Response.split(":")[1].Trim()
    }
    'DateCreated' {
      $FileType = exiftool -FileType $File.fullFilePath
      [String]$Extension = $FileType.split(":")[1].Trim()

      switch ($Extension) {
        { @("PNG") -contains $_ } {
          $Response = exiftool -CreationTime $File.fullFilePath
        }
        { @("MP4") -contains $_ } {
          # Canon use -EXIF:CreateDate as correct date and time
          $Response = exiftool -EXIF:CreateDate $File.fullFilePath
        }
        { @("MOV") -contains $_ } {
          $Response = exiftool -CreationDate $File.fullFilePath
        }
        { @("WMV") -contains $_ } {
          $Response = exiftool -CreationDate $File.fullFilePath
        }
        { @("JPEG", "HEIC", "GIF", "AVI") -contains $_ } {
          $Response = exiftool -DateTimeOriginal $File.fullFilePath
        }
        Default {
          Write-Error -Message "File type not supported" -ErrorAction Continue
          Break
        }
      }

      # Parse data and return value
      if (( $Response.Length -eq 53 ) -Or ( $Response.Length -eq 59)) {
        # Tag exists
        $Parsed = ParseDateTime $Response
        if ( IsValidDate ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss") ) {
          return $Parsed
        }
        else {
          return @{
            fileName  = ""
            date      = ""
            utcoffset = ""
          }
        }        
      }
      else {
        return @{
          fileName  = ""
          date      = ""
          utcoffset = ""
        }
      }
    }
    'FileModifyDate' {
      # PNG, MOV, MP4, JPG
      $Response = exiftool -FileModifyDate $File.fullFilePath
      
      # Parse data and return value
      return ParseDateTime $Response
    }
    'DateCreatedAlt' {
      $FileType = exiftool -FileType $File.fullFilePath
      [String]$Extension = $FileType.split(":")[1].Trim()

      switch ($Extension) {
        { @("MP4") -contains $_ } {
          $Response = exiftool -CreateDate $File.fullFilePath
        }
        { @("JPEG", "HEIC", "GIF", "PNG", "MOV", "WMV") -contains $_ } {
          $Response = ""
        }
        Default {
          Write-Error -Message "File type not supported" -ErrorAction Continue
          Break
        }
      }

      # Parse data and return value
      if (( $Response.Length -eq 53 ) -Or ( $Response.Length -eq 59)) {
        # Tag exists
        $Parsed = ParseDateTime $Response
        if ( IsValidDate ($Parsed.date).toString("yyyy:MM:dd hh:mm:ss") ) {
          return $Parsed
        }
        else {
          return @{
            fileName  = ""
            date      = ""
            utcoffset = ""
          }
        }        
      }
      else {
        return @{
          fileName  = ""
          date      = ""
          utcoffset = ""
        }
      }
    }
    Default {
      Write-Error -Message "Invalid InfoType specified" -ErrorAction Continue
      Break
    }
  }
}