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

  for ( $i=0; $i -lt $title.Length; $i++ ) {
    Write-Host $title[$i] -NoNewline
  }
  Write-Host ""
  Write-Host ""
}

function OutputSpacer {
  for ($i=0; $i -le 10; $i++) { Write-Host "" }
}

function OutputScriptFooter {
  Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White
  Write-Host "     OPERATIONS  COMPLETED     " -BackgroundColor DarkGreen -ForegroundColor White
  Write-Host "                               " -BackgroundColor DarkGreen -ForegroundColor White

  (New-Object System.Media.SoundPlayer "$env:windir\Media\Ring06.wav").Play()
  for ( $i=0; $i -lt $completed.Length; $i++ ) {
    Write-Host $completed[$i] -NoNewline
  }
  Write-Host ""
  Write-Host ""
  Write-Host ""
  CleanBackups
}