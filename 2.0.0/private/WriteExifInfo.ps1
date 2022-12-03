Function Write-ExifInfo {
  <#
    .SYNOPSIS
      Write the date on the specified file
    
    .EXAMPLE
      Write-ExifInfo $filePath $date
    
    .PARAMETER inputFile
      Required. The complete file path on which the date needs to be written
    
    .PARAMETER Date
      Required. The Date in the format YYYY:MM:DD hh:mm:ss - beware no validation of input date is present here
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputFile,

    [Parameter(Mandatory = $true)]
    [String]$Date
  )

  switch ($inputFile.extension) {
    { @("HEIC", "JPEG", "heic", "jpg") -contains $_ } {
      exiftool -AllDates="$date" $inputFile.fullFilePath -F
    }
    { @("MOV", "mov") -contains $_ } {
      exiftool -CreateDate="$Date" -ModifyDate="$Date" -TrackCreateDate="$Date" -FileModifyDate="$Date" -TrackModifyDate="$Date" -MediaCreateDate="$Date" -MediaModifyDate="$Date" -CreationDate="$Date" $inputFile.fullFilePath -F
    }
    { @("MP4", "mp4") -contains $_ } {
      exiftool -CreateDate="$Date" -ModifyDate="$Date" -FileModifyDate="$Date" -TrackCreateDate="$Date" -TrackModifyDate="$Date" -MediaCreateDate="$Date" -MediaModifyDate="$Date" -DateTimeOriginal="$Date" -EXIF:CreateDate="$Date" $inputFile.fullFilePath -F
    }
    { @("PNG", "png") -contains $_ } {
      exiftool -AllDates="$Date" -CreationTime="$Date" $inputFile.fullFilePath -F
    }
    { @("GIF", "gif") -contains $_ } {
      exiftool -DateTimeOriginal="$Date" -CreateDate="$Date" -ModifyDate="$Date" -FileModifyDate="$Date" $inputFile.fullFilePath -F
    }
    Default {
      Write-Error -Message "Invalid extension specified" -ErrorAction Continue
      Break
    }
  }
}