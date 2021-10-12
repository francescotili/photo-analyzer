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
      exiftool -AllDates="$date" $File -F
    }
    { @("MOV", "mov") -contains $_ } {
      exiftool -CreateDate="$Date" -ModifyDate="$Date" -TrackCreateDate="$Date" -FileModifyDate="$Date" -TrackModifyDate="$Date" -MediaCreateDate="$Date" -MediaModifyDate="$Date" -CreationDate="$Date" $File -F
    }
    { @("MP4", "mp4") -contains $_ } {
      exiftool -CreateDate="$Date" -ModifyDate="$Date" -FileModifyDate="$Date" -TrackCreateDate="$Date" -TrackModifyDate="$Date" -MediaCreateDate="$Date" -MediaModifyDate="$Date" -DateTimeOriginal="$Date" -EXIF:CreateDate="$Date" $File -F
    }
    { @("PNG", "png") -contains $_ } {
      exiftool -AllDates="$Date" -CreationTime="$Date" $File -F
    }
    { @("GIF", "gif") -contains $_ }{
      exiftool -DateTimeOriginal="$Date" -CreateDate="$Date" -ModifyDate="$Date" -FileModifyDate="$Date" $File -F
    }
    Default {
      Write-Error -Message "Invalid extension specified" -ErrorAction Continue
      Break
    }
  }
}