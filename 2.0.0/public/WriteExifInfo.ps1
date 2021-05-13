Function Write-ExifInfo {
  <#
    .SYNOPSIS
      Write the date on the specified file
    
    .EXAMPLE
      Write-ExifInfo $filePath $date $fileType
    
    .PARAMETER File
      Required. The complete file path on which the date needs to be written
    
    .PARAMETER Date
      Required. The Date in the format YYYY:MM:DD hh:mm:ss - beware no validation of input date is present here
    
    .PARAMETER FileType
      Required. The FileType or file extension
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$File,

    [Parameter(Mandatory=$true)]
    [String]$Date,

    [Parameter(Mandatory=$true)]
    [String]$FileType
  )

  switch ($FileType) {
    { @("HEIC", "JPEG", "heic", "jpg") -contains $_ } {
      .\exiftool.exe -AllDates="$date" $File
    }
    { @("MOV", "mov") -contains $_ } {
      .\exiftool.exe -CreateDate="$Date" -ModifyDate="$Date" -TrackCreateDate="$Date" -FileModifyDate="$Date" -TrackModifyDate="$Date" -MediaCreateDate="$Date" -MediaModifyDate="$Date" -CreationDate="$Date" $File
    }
    { @("MP4", "mp4") -contains $_ } {
      .\exiftool.exe -CreateDate="$Date" -ModifyDate="$Date" -FileModifyDate="$Date" -TrackCreateDate="$Date" -TrackModifyDate="$Date" -MediaCreateDate="$Date" -MediaModifyDate="$Date" -DateTimeOriginal="$Date" $File
    }
    { @("PNG", "png") -contains $_ } {
      .\exiftool.exe -AllDates="$Date" -CreationTime="$Date" $File
    }
    { @("GIF", "gif") -contains $_ }{
      .\exiftool.exe -DateTimeOriginal="$Date" -CreateDate="$Date" -ModifyDate="$Date" -FileModifyDate="$Date" $File
    }
    Default {
      Write-Error -Message "Invalid extension specified"
      exit
    }
  }
}