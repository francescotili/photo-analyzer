Function ParseDateTime {
  <#
    .SYNOPSIS
      Parse a DateTime tag from exiftool to separate the various date and time component and then calculate the new file name and correct date in the final format.
      Returns a custom object with 'fileName' and 'date' properties
    
    .PARAMETER Tag
      Required. The complete tag returned by a single exiftool query
    
    .PARAMETER TagType
      Required. How is the DateTime in the Tag? Following values applies:
      - 'NormalTag' if the date in the Tag is specified with this format -> YYYY:MM:DD hh:mm:ss
      - 'UTCTag' if the date in the Tag is specified with this format -> YYYY:MM:DD hh:mm:ss+hh:mm
      - 'CustomDate' if the date is specified by the user (no Tag text) in this format -> YYYY:MM:DD hh:mm:ss
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory=$true)]
    [String]$Tag,

    [Parameter(Mandatory=$true)]
    [String]$TagType
  )

  switch ($TagType) {
    'NormalTag' {
      $Year    = $Tag.split(":")[1].trim()
      $Month   = $Tag.split(":")[2].trim()
      $Day     = $Tag.split(":")[3].split(" ")[0].trim()
      $Hour    = $Tag.split(":")[3].split(" ")[1].trim()
      $Minutes = $Tag.split(":")[4].trim()
      $Seconds = $Tag.split(":")[5].trim()
    }
    'UTCTag' {
      $Year    = $Tag.split(":")[1].trim()
      $Month   = $Tag.split(":")[2].trim()
      $Day     = $Tag.split(":")[3].split(" ")[0].trim()
      $Hour    = $Tag.split(":")[3].split(" ")[1].trim()
      $Minutes = $Tag.split(":")[4].trim()
      $Seconds = $Tag.split(":")[5].trim().split("+")[0].trim()
    }
    'CustomDate' {
      $Year    = $Tag.split(":")[0].trim()
      $Month   = $Tag.split(":")[1].trim()
      $Day     = $Tag.split(":")[2].split(" ")[0].trim()
      $Hour    = $Tag.split(":")[2].split(" ")[1].trim()
      $Minutes = $Tag.split(":")[3].trim()
      $Seconds = $Tag.split(":")[4].trim()
    }
    Default {
      Write-Error -Message "Error in ParseData function, wrong type of Tag specified" -ErrorAction Stop
      exit
    }
  }

  $ReturnValue = "" | Select-Object -Property fileName, date
  $ReturnValue.fileName = "$Year$Month$Day $Hour$Minutes$Seconds"
  $ReturnValue.date = "${Year}:${Month}:${Day} ${Hour}:${Minutes}:${Seconds}"
  return $ReturnValue
}