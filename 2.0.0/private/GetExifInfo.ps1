Function Get-ExifInfo {
  <#
    .SYNOPSIS
      Get the specified Exif information from the specified file based on filetype.
    
    .EXAMPLE
      Get-ExifInfo $file FileType
    
    .PARAMETER File
      Required. Complete file object to analyze.
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $File
  )

  # Initialize default variables
  $returnValues = [ExifData]::new()
  
  # Retrieve exifData
  $exifData = exiftool $File.fullFilePath -s -sort

  # Retrieve tagValues
  $returnValues.fileType = ParseTag $exifData "FileType"

  # Identify the Maker
  if ( (ParseTag $exifData "Make") -eq "Apple" ) {
    $returnValues.device = [DeviceType]::Apple
  }
  elseif ( $null -ne (ParseTag $exifData "AndroidVersion")) {
    $returnValues.device = [DeviceType]::Android
  }
  elseif ( (ParseTag $exifData "Make") -eq "Canon" ) {
    $returnValues.device = [DeviceType]::Canon
  }

  # Parse filename
  $parsedDate = ParseFilename $File.name
  $returnValues.parsedDate = $parsedDate

  # Retrieve modify date
  $modifyDate = ParseTagDateTime $exifData "FileModifyDate"
  $returnValues.modifyDate = $modifyDate

  # Retrive utcOffset
  $returnValues.utcoffset = (ParseDateTime( ParseTag $exifData "FileModifyDate")).utcoffset

  # Retrieve Createdate
  switch ($returnValues.device) {
    ([DeviceType]::Apple) {
      switch ($returnValues.fileType) {
        { @("JPEG", "HEIC") -contains $_ } {
          $createDate = ParseTagDateTime $exifData "CreateDate"
          $returnValues.createDate = $createDate
        }
        { @("MOV") -contains $_ } {
          $createDate = ParseTagDateTime $exifData "CreationDate"
          $returnValues.createDate = $createDate
        }
        Default {}
      }
    }
    ([DeviceType]::Android) {
      switch ($returnValues.fileType) {
        { @("JPEG") -contains $_ } {
          $createDate = ParseTagDateTime $exifData "CreateDate"
          $returnValues.createDate = $createDate
        }
        { @("MP4") -contains $_ } {
          $returnValues.createDate = $returnValues.parsedDate
        }
        Default {}
      }
    }
    ([DeviceType]::Canon) {
      switch ($returnValues.fileType) {
        { @("JPEG") -contains $_ } {
          $createDate = ParseTagDateTime $exifData "CreateDate"
          $returnValues.createDate = $createDate
        }
        { @("MP4") -contains $_ } {
          $createDate = ParseTagDateTime $exifData "DateTimeOriginal"
          $returnValues.createDate = $createDate
        }
        Default {}
      }
    }
    ([DeviceType]::Unknown) {
      $returnValues.createDate = $returnValues.parsedDate
    }
    Default {}
  }

  # Retrieve Alternative dates
  $alternativeTagNames = @(
    "DateTimeOriginal"
    "FileCreateDate"
    "GPSDateTime"
    "TrackCreateDate"
    "CreateDate"
    "TrackModifyDate"
    "MediaCreateDate"
    "SubSecCreateDate"
  )

  for ($i = 0; $i -lt $alternativeTagNames.Count; $i++) {
    $altDate = ParseTagDateTime $exifData $alternativeTagNames[$i]
    if ( $null -ne $altDate ) {
      if ( IsValidDate( $altDate.toString("yyyy:MM:dd HH:mm:ss") ) ) {
        $returnValues.altDates += $altDate
      }
    }
  }

  # Remove duplicate Alternative dates
  if ($returnValues.altDates.Count -gt 1 ) {
    $returnValues.altDates = $returnValues.altDates | Sort-Object | Select-Object -Unique
  }

  return $returnValues
}

enum DeviceType { Apple; Android; Canon; Unknown }
enum FileType { JPEG; HEIC; PNG; GIF; MOV; MP4; AVI; WMV; Unknown }

Class ExifData {
  [DateTime]$createDate
  [DateTime]$modifyDate
  [DateTime]$parsedDate
  [Array]$altDates
  [String]$fileType
  [DeviceType]$device
  [String]$utcoffset

  ExifData() {
    # Init method
    [DateTime]$defaultDate = Get-Date -Date "01-01-1800 00:00:00"
    
    $this.createDate = $defaultDate
    $this.modifyDate = $defaultDate
    $this.parsedDate = $defaultDate
    $this.altDates = @()
    $this.fileType = ""
    $this.device = [DeviceType]::Unknown
    $this.utcoffset = ""
  }
}