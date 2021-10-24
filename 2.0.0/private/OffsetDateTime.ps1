Function OffsetDateTime {
  <#
    .SYNOPSIS
      This private functions take a date and offsets it with the second parameter of a UTC Offset. Returns a normal date in YYYY:MM:DD hh:mm:ss format
    
    .PARAMETER Date
      Required. Date to offset in YYYY:MM:DD hh:mm:ss format
    
    .PARAMETER UTCOffset
      Required. Offset in UTC format of +/-hh:mm. Example: +01:30 or -02:00
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Date,

    [Parameter(Mandatory = $true)]
    [String]$UTCOffset
  )

  # Parse input date
  $Year    = [int]$Date.split(":")[0]
  $Month   = [int]$Date.split(":")[1]
  $Day     = [int]$Date.split(":")[2].split(" ")[0]
  $Hour    = [int]$Date.split(":")[2].split(" ")[1]
  $Minutes = [int]$Date.split(":")[3]
  $Seconds = [int]$Date.split(":")[4]

  # Parse offset
  $OffsetDirection = $UTCOffset.substring(0, $UTCOffset.length - 5)
  $OffsetHour = [int]$UTCOffset.substring(1, $UTCOffset.length - 4)
  $OffsetMinutes = [int]$UTCOffset.substring(4)

  # Offset the date
  $PSDate = Get-Date -Date "$($Year)/$($Month)/$($Day) $($Hour):$($Minutes):$($Seconds)"
  switch ($OffsetDirection) {
    '+' {
      $PSDate += "$($OffsetHour):$($OffsetMinutes)"
    }
    '-' {
      $PSDate -= "$($OffsetHour):$($OffsetMinutes)"
    }
    Default {
      Write-Error -Message "Unhandled exception with Offset direction, offset is: $OffsetDirection" -ErrorAction Stop
    }
  }

  [String]$ReturnDate = Get-Date -Date $PSDate -Format "yyyy:MM:dd HH:mm:ss"
  return $ReturnDate
}