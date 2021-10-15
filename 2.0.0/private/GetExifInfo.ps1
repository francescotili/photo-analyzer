Function Get-ExifInfo {
  <#
    .SYNOPSIS
      Get the specified Exif information from the specified file based on filetype.
    
    .EXAMPLE
      Get-ExifInfo $filePath FileType
    
    .PARAMETER File
      Required. Complete file path for the file to analyze.
    
    .PARAMETER InfoType
      Required. What type of information do you want to retrieve:
      - 'FileType' -> Returns the exiftool detected fileType
      - 'DateCreated' -> Returns the correct Tag for DateTime created
      - 'FileModifyDate' -> Returns the modifyDateTime for the file
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$File,

    [Parameter(Mandatory=$true)]
    [String]$InfoType
  )

  switch ($InfoType) {
    'FileType' {
      $Response = exiftool -FileType $File
      return $Response.split(":")[1].Trim()
    }
    'DateCreated' {    
      $FileType = exiftool -FileType $File
      [String]$Extension = $FileType.split(":")[1].Trim()

      switch ($Extension) {
        { @("PNG") -contains $_ } {
          $Response = exiftool -CreationTime $File
          $TagType = "NormalTag"
        }
        { @("MP4") -contains $_ } {
          # Canon use -EXIF:CreateDate as correct date and time
          $Response = exiftool -EXIF:CreateDate $File
          $TagType = "NormalTag"
        }
        { @("MOV") -contains $_ } {
          $Response = exiftool -CreationDate $File
          $TagType = "UTCTag"
        }
        { @("JPEG", "HEIC", "GIF", "AVI") -contains $_ } {
          $Response = exiftool -DateTimeOriginal $File
          $TagType = "NormalTag"
        }
        Default {
          Write-Error -Message "File type not supported" -ErrorAction Continue
          Break
        }
      }

      # Parse data and return value
      if(( $Response.Length -eq 53 ) -Or ( $Response.Length -eq 59)) { # Tag exists
        $Parsed = ParseDateTime $Response $TagType
        if( IsValidDate $Parsed.date ) {
          return $Parsed
        } else {
          return ""
        }        
      } else {
        return ""
      }
    }
    'FileModifyDate' {
      # PNG, MOV, MP4, JPG
      $Response = exiftool -FileModifyDate $File
      
      # Parse data and return value
      return ParseDateTime $Response "UTCTag"
    }
    Default {
      Write-Error -Message "Invalid InfoType specified" -ErrorAction Continue
      Break
    }
    'DateCreatedAlt' {    
      $FileType = exiftool -FileType $File
      [String]$Extension = $FileType.split(":")[1].Trim()

      switch ($Extension) {
        { @("MP4") -contains $_ } {
          $Response = exiftool -CreateDate $File
          $TagType = "NormalTag"
        }
        { @("JPEG", "HEIC", "GIF", "PNG", "MOV") -contains $_ } {
          $Response = ""
          $TagType = "NormalTag"
        }
        Default {
          Write-Error -Message "File type not supported" -ErrorAction Continue
          Break
        }
      }

      # Parse data and return value
      if(( $Response.Length -eq 53 ) -Or ( $Response.Length -eq 59)) { # Tag exists
        $Parsed = ParseDateTime $Response $TagType
        if( IsValidDate $Parsed.date ) {
          return $Parsed
        } else {
          return ""
        }        
      } else {
        return ""
      }
    }
  }
}