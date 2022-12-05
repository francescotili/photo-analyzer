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
  $SupportedExtensions = @("jpg", "JPG", "jpeg", "JPEG", "heic", "HEIC", "png", "PNG", "gif", "GIF", "mp4", "MP4", "m4v", "M4V", "mov", "MOV", "gif", "GIF", "avi", "AVI", "wmv", "WMV", "flv", "FLV")

  # Define expected extensions based on detected file type
  $extensions = @{
    "JPEG" = "jpg"
    "PNG"  = "png"
    "GIF"  = "gif"
    "MP4"  = "mp4"
  }

  # File Types that will be converted
  $conversions = @("AVI", "WMV", "HEIC", "MP4", "M4A", "MOV")

  # Check if extension match and return value
  if ( $SupportedExtensions.Contains( $inputFile.extension ) ) {
    # Check if the extension is the expected based on the FileType
    if ( $extensions[$exifData.fileType] -ceq $inputFile.extension ) {
      <# For mp4 video, I found that it is better to always reencode to solve all
       # the container issues of various device. It will generate a standard H264
       # video in .mp4 format that usually works everytime, with every player.
       # Clearly it is more "energy intensive", but it ensures repeatability
       #
       # As example: H264 4K videos from Realme devices, do not play well on PC
       #             even if it normal H264 video. If reencoded, all good though #>
      if ( $extensions[$exifData.fileType] -ceq "mp4" ) {
        $ReturnValue.action = "Convert"
      }
      else { $ReturnValue.action = "IsValid" }
    }
    elseif ( $conversions.Contains($exifData.fileType)) {
      $ReturnValue.action = "Convert"
    }
    else {
      if ( $null -ne $extensions[$exifData.fileType] ) {
        $ReturnValue.action = "Rename"
        $ReturnValue.extension = $extensions[$exifData.fileType]
      } 
    }
  }

  return $ReturnValue
}