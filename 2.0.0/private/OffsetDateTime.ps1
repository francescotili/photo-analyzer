Function OffsetDateTime {
  <#
    .SYNOPSIS
      This private functions take a date and offsets it with the second parameter of a UTC Offset. Returns a normal date in YYYY:MM:DD hh:mm:ss format
    
    .PARAMETER inputDate
      Required. Date to offset
    
    .PARAMETER UTCOffset
      Required. Offset in UTC format of +/-hh:mm. Example: +01:30 or -02:00
  #>

  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    $inputDate,

    [Parameter(Mandatory = $true)]
    [String]$UTCOffset
  )

  # Parse offset
  $offset = @{
    direction = $UTCOffset.substring(0, $UTCOffset.length - 5)
    hour      = [int]$UTCOffset.substring(1, $UTCOffset.length - 4)
    minute    = [int]$UTCOffset.substring(4)
  }

  # Offset the date
  switch ($offset.direction) {
    '+' { $outputDate = $inputDate.AddHours($offset.hour).AddMinutes($offset.minute) }
    '-' { $outputDate = $inputDate.AddHours($offset.hour * -1).AddMinutes($offset.minute * -1) }
    Default {
      Write-Error -Message "Unhandled exception with Offset direction, offset is: $($offset.direction)" -ErrorAction Stop
    }
  }

  return $outputDate
}