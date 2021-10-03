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

  $FileType = Get-ExifInfo $FilePath "FileType"

  switch ($Extension) {
    'heic' {
      switch ($FileType) {
        'HEIC'  { return "IsValid" }
        'JPEG'  { return "Rename" }
        Default { return "" }
      }
    }
    'jpeg' {
      switch ($FileType) {
        'JPEG'  { return "Rename" }
        Default { return "" }
      }
    }
    'jpg' {
      switch ($FileType) {
        'JPEG'  { return "IsValid" }
        Default { return "" }
      }
    }
    'png' {
      switch ($FileType) {
        'PNG'   { return "IsValid" }
        Default { return ""}
      }
    }
    'mov' {
      switch ($FileType) {
        'MOV'   { return "IsValid" }
        'MP4'   { return "Rename" }
        Default { return "" }
      }
    }
    'm4v' {
      switch ($FileType) {
        'MP4'   { return "Rename" }
        Default { return "" }
      }
    }
    'mp4' {
      switch ($FileType) {
        'MP4'   { return "IsValid" }
        Default { return "" }
      }
    }
    'gif' {
      switch ($FileType) {
        'GIF'   { return "IsValid" }
        Default { return ""}
      }
    }
    Default { return "" }
  }
}