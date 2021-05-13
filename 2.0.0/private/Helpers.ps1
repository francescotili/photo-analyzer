function Set-Path {
  <#
    .SYNOPSIS
      This function ask the user for the path to be analyzed and save it as a global variable
  #>
  
  $Path = Read-Host "Please specify the folder to analyze (i.e.: D:\user\Pictures)"
  
  if ($Path) { # Path has been specified
    $WorkingPath = $path -replace '["]',''    
    if (-Not(Test-Path -Path "$WorkingPath")) { # Path not valid
      Write-Host "Unvalid path! Exiting..."
      exit
    } else { # Valid path
      Set-Variable -Name WorkingFolder -Value $WorkingPath -Scope Global
      return $WorkingPath
    }
  } else { # No path specified
    Write-Host "You have not specified a path. Exiting..."
    exit
  }
}

function Set-Mode {
  <#
    .SYNOPSIS
      This function ask the user for the mode the script must be executed
  #>
  
  Write-Host "=============================================="
  Write-Host "Chose analysis mode:"
  Write-Host "1 - Automatic analysis and correction (will apply changes)"
  Write-Host "2 - Simulate an automatic analysis (no changes to files)"
  Write-Host "3 - Analize but ask informations manually"
  Write-Host "=============================================="
  Write-Host ""
  $UserSelection = Read-Host "Insert number"
  switch ($UserSelection) {
    '1' {
      Set-Variable -Name ScriptMode -Value "Normal" -Scope Global
    }
    '2' {
      Set-Variable -Name ScriptMode -Value "Simulation" -Scope Global
    }
    '3' {
      Set-Variable -Name ScriptMode -Value "Manual" -Scope Global
    }
    Default {
      Write-Host "Invalid choice!"
      exit
    }
  }
}

function ActionRouter {
  <#
    .SYNOPSIS
      This function is called after all the global variables has been set. It serves to route the script toward the main final action of photo analyzer and reordering
  #>

  Write-Host ""
  Write-Host "=============================================="
  Write-Host "Choose want you want to do:"
  Write-Host "1 - Analyze and rename every media files"
  Write-Host "2 - Analize and rename JPEG files"
  Write-Host "3 - Analize and rename HEIC files"
  Write-Host "4 - Analize and rename JPG files"
  Write-Host "5 - Analize and rename MP4 files"
  Write-Host "6 - Analize and rename MOV files"
  Write-Host "7 - Analize and rename PNG files"
  Write-Host "8 - Analize and rename GIF files"
  Write-Host "9 - Cleanup backup files"
  Write-Host "=============================================="
  Write-Host ""
  $userSelection = Read-Host "Insert number"

  switch ($userSelection) {
    '1' { # All media files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "heic"
      AnalyzeFiles "jpeg"
      AnalyzeFiles "jpg"
      AnalyzeFiles "png"
      AnalyzeFiles "mov"
      AnalyzeFiles "mp4"
      AnalyzeFiles "gif"
      OutputScriptFooter
    }
    '2' { # JPEG Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "jpeg"
      OutputScriptFooter
    }
    '3' { # HEIC Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "heic"
      OutputScriptFooter
    }
    '4' { # JPG Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "jpg"
      OutputScriptFooter
    }
    '5' { # MP4 Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "mp4"
      OutputScriptFooter
    }
    '6' { # MOV Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "mov"
      OutputScriptFooter
    }
    '7' { # PNG Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "png"
      OutputScriptFooter
    }
    '8' { # GIF Files
      Clear-Host
      OutputSpacer
      AnalyzeFiles "gif"
      OutputScriptFooter
    }
    '8' { # Only cleanup file backups
      Clear-Host
      CleanBackups
    }
    Default { # Invalid choice
      Write-Host "Invalid choice - exiting..."
      exit
    }
  }
}