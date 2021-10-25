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
  $inputDate = @{
    year   = [int]$Date.split(":")[0]
    month  = [int]$Date.split(":")[1]
    day    = [int]$Date.split(":")[2].split(" ")[0]
    hour   = [int]$Date.split(" ")[2].split(":")[1]
    minute = [int]$Date.split(":")[3]
    second = [int]$Date.split(":")[4]
  }

  # Parse offset
  $offset = @{
    direction = $UTCOffset.substring(0, $UTCOffset.length - 5)
    hour      = [int]$UTCOffset.substring(1, $UTCOffset.length - 4)
    minute    = [int]$UTCOffset.substring(4)
  }

  # Offset the date
  $PSDate = Get-Date -Date "$($inputDate.year)/$($inputDate.month)/$($inputDate.day) $($inputDate.hour):$($inputDate.minute):$($inputDate.second)"
  switch ($offset.direction) {
    '+' {
      $PSDate += "$($offset.hour):$($offset.minute)"
    }
    '-' {
      $PSDate -= "$($offset.hour):$($offset.minute)"
    }
    Default {
      Write-Error -Message "Unhandled exception with Offset direction, offset is: $($offset.direction)" -ErrorAction Stop
    }
  }

  return Get-Date -Date $PSDate -Format "yyyy:MM:dd HH:mm:ss"
}