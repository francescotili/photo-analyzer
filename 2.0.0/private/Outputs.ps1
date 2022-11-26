Function OutputScriptHeader {
  $title = @"
 _____________________________________________________
|                                                     |
|             _____  _           _                    |
|            |  __ \| |         | |                   |
|            | |__) | |__   ___ | |_ ___              |
|            |  ___/| '_ \ / _ \| __/ _ \             |
|            | |    | | | | (_) | |_ (_) |            |
|            |_|    |_| |_|\___/ \__\___/             |
|                           _                         |
|         /\               | |                        |
|        /  \   _ __   __ _| |_   _ _______ _ __      |
|       / /\ \ | '_ \ / _' | | | | |_  / _ \ '__|     |
|      / ____ \| | | | (_| | | |_| |/ /  __/ |        |
|     /_/    \_\_| |_|\__,_|_|\__, /___\___|_|        |
|                              __/ |                  |
|                             |___/                   |
|                                                     |
|                                                     |
|           ~~ Welcome to Photo Analzyer ~~           |
|         A script for image and video sorting        |
|                                                     |
|                                                     |
|  Author: Francesco Tili                             |
|_____________________________________________________|
"@

  for ( $i = 0; $i -lt $title.Length; $i++ ) {
    Write-Host $title[$i] -NoNewline
  }
  Write-Host ""
  Write-Host ""
}

function OutputSpacer {
  for ($i = 0; $i -le 10; $i++) { Write-Host "" }
}

function OutputAskForInput {
  Write-Host ""
  Write-Host " $($Emojis["question"]) What date would you like to use?"
}

function OutputScriptFooter {
  Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White
  Write-Host "     OPERATIONS  COMPLETED     " -BackgroundColor DarkGreen -ForegroundColor White
  Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White

  (New-Object System.Media.SoundPlayer "$env:windir\Media\Ring06.wav").Play()
  for ( $i = 0; $i -lt $completed.Length; $i++ ) {
    Write-Host $completed[$i] -NoNewline
  }
  Write-Host ""
  Write-Host ""
  Write-Host ""
}

function OutputFileResult {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'success' { Write-Host "   FILE SUCCESSFULLY UPDATED   " -BackgroundColor DarkGreen -ForegroundColor White }
    'skip' { Write-Host "         FILE  SKIPPED         " -BackgroundColor DarkRed -ForegroundColor White }
    Default {}
  }
}

function OutputCleanResult {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'completed' {
      Write-Host ""
      Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White
      Write-Host "      CLEANING  COMPLETED      " -BackgroundColor DarkGreen -ForegroundColor White
      Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White
      (New-Object System.Media.SoundPlayer "$env:windir\Media\Ring06.wav").Play()
      Write-Host ""
    }
    'noFiles' {
      Write-Host ""
      Write-Host "        NO FILES FOUND         " -BackgroundColor DarkRed -ForegroundColor White
      Write-Host ""
    }
    Default {}
  }
}

function OutputRestoreResult {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'completed' {
      Write-Host ""
      Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White
      Write-Host "       RESTORE COMPLETED       " -BackgroundColor DarkGreen -ForegroundColor White
      Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White
      (New-Object System.Media.SoundPlayer "$env:windir\Media\Ring06.wav").Play()
      Write-Host ""
    }
    'noFiles' {
      Write-Host ""
      Write-Host "   FOUND NO FILES TO RESTORE   " -BackgroundColor DarkRed -ForegroundColor White
      Write-Host ""
    }
    Default {}
  }
}

function OutputCheckCreationDate {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'valid' { Write-Host " $($Emojis["check"]) Creation date valid" }
    'undefined' { Write-Host " $($Emojis["warning"]) Creation date not detected! Try parsing from filename..." }
    Default {}
  }
}

function OutputCheckFileType {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value,
    
    [Parameter(Mandatory = $false)]
    [String]$Extension
  )

  switch ($Value) {
    'valid' { Write-Host " $($Emojis["check"]) Real .$($Extension) file detected" }
    'mismatch' { Write-Host " $($Emojis["warning"]) Extension mismatch detected ..." }
    'convert' { Write-Host " $($Emojis["warning"]) The file must be converted..." }
    'unsupported' { Write-Host " $($Emojis["ban"]) File extension or container not supported" }
    Default {}
  }
}

function OutputParsing {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'parsed' { Write-Host " $($Emojis["check"]) Valid date successfully parsed" }
    'nomatch' { Write-Host " $($Emojis["warning"]) Parsing unsuccessfull! Trying other dates..." }
    Default {}
  }
}

function OutputUserError {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'invalidChoice' { Write-Host " $($Emojis["error"]) Invalid choice!" }
    'emptyChoice' { Write-Host " $($Emojis["error"]) No action specified!" }
    'invalidDate' { Write-Host " $($Emojis["error"]) Invalid date!" }
    'emptyDate' { Write-Host " $($Emojis["error"]) No date specified!" }
    'invalidPath' { Write-Error -Message " $($Emojis["error"]) Specified path is not valid! Exiting..." -ErrorAction Stop }
    'emptyPath' { Write-Error -Message " $($Emojis["error"]) You have not specified a path. Exiting..." -ErrorAction Stop }
    'invalidOffset' { Write-Error -Message " $($Emojis["error"]) Specified offset is not valid! Exiting..." -ErrorAction Stop }
    'emptyOffset' { Write-Error -Message " $($Emojis["error"]) You have not specified an offset. Exiting..." -ErrorAction Stop }
    Default {}
  }
}

function OutputDevice {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$deviceName
  )

  Write-Host " $($Emojis["device"]) $($deviceName) detected"
}

function OutputRenameResult {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value,
    
    [Parameter(Mandatory = $false)]
    [String]$String
  )

  switch ($Value) {
    'extensionChanged' { Write-Host " $($Emojis["check"]) File extension changed to .$($String)" }
    'fileRenamed' { Write-Host " $($Emojis["check"]) File renamed: $($String)" }
    Default {}
  }
}

function OutputConversionResult {
  [CmdLetBinding(DefaultParameterSetName)]
  Param (
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  switch ($Value) {
    'success' { Write-Host " $($Emojis["check"]) Conversion completed" }
    'error' { Write-Host " $($Emojis["error"]) Unhandled error during conversion" }
    'unsupported' { Write-Host " $($Emojis["ban"]) Unsupported video type" }
    Default {}
  }
}