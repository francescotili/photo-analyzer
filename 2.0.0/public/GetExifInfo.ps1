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
      [String]$TagType = "NormalTag"

      switch ($Extension) {
        { @("PNG") -contains $_ } {
          $Response = exiftool -CreationTime $File
        }
        { @("MP4") -contains $_ } {
          $Response = exiftool -CreateDate $File
          # $Response = exiftool -DateTimeOriginal $File
        }
        { @("MOV") -contains $_ } {
          $Response = exiftool -CreationDate $File
          $TagType = "UTCTag"
          # $Response = exiftool -CreateDate $File
        }
        { @("JPEG", "HEIC", "GIF") -contains $_ } {
          $Response = exiftool -DateTimeOriginal $File
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
  }
}