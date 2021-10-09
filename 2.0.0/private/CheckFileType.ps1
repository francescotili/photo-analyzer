Function CheckFileType {
  <#
    .SYNOPSIS
      Analyze the file type with ExifTool and return the correct operation to make for the PhotoAnalyzer main function
      - 'IsValid' -> Means that the extension and FileType corresponds, so the analyzer can continue the operations
      - 'Rename' -> Means that the extension doesn't match the fileType, so the file extension need to be changed before the analyzer can continue the operations
      - '' -> Means that something is strange with the file or the case is not handled
    
    .PARAMETER FilePath
      Required. The complete filepath to analyze
    
    .PARAMETER Extension
      Required. The file actual extension against which the file will be analyzed
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$FilePath,

    [Parameter(Mandatory=$true)]
    [String]$Extension
  )

  
  $ReturnValue = "" | Select-Object -Property action, extension

  # Define an array of supported extensions
  $SupportedExtensions = @("jpg", "jpeg", "heic", "png", "gif", "mp4", "m4v", "mov", "gif")

  # Define expected extensions based on detected file type
  $extensions = @{
    "JPEG" = "jpg"
    "PNG" = "png"
    "GIF" = "gif"
    "MOV" = "mov"
    "MP4" = "mp4"
    "HEIC" = "heic"
  }

  # Check if extension match and return value
  if ($SupportedExtensions.Contains($Extension)) {
    # Check if the extension is the expected based on the FileType
    $FileType = Get-ExifInfo $FilePath "FileType"
    if ($extensions[$FileType] -eq $Extension) {
      $ReturnValue.action = "IsValid"
    } else {
      $ReturnValue.action = "Rename"
      $ReturnValue.extension = $extensions[$FileType]
    }
  } else {
    Write-Error -Message "Unhandled file extension" -ErrorAction Continue
  }

  return $ReturnValue
}