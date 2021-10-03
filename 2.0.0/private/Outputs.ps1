Function OutputScriptHeader {
  Write-Host "=============================================="
  Write-Host "Script for image and video sorting"
  Write-Host ""
}

function OutputSpacer {
  for ($i=0; $i -le 10; $i++) { Write-Host "" }
}

function OutputModeStatus {
  switch ($ScriptMode) {
    'Normal' {
      Write-Host ">> Simulation DISABLED - Changes will be applied to files!"
    }
    'Simulation' {
      Write-Host ">> Simulation ENABLED"
    }
    'Manual' {
      Write-Host ">> Manual mode ENABLED"
    }
    Default {
      Write-Host ">> Global script mode not set!"
    }
  }
  Write-Host ""
}

function OutputWorkingPath {
  if ($WorkingFolder -ne "") {
    Write-Host ">> Selected path: $WorkingFolder"
  } else {
    Write-Host ">> No global path set!"
  }
}

function OutputScriptFooter {
  (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Unlock.wav").Play()
  Write-Host ""
  Write-Host "=============================================="
  Write-Host "Operation completed"
  Write-Host ""
  if ( $ScriptMode -eq "Normal" ) {
    $UserChoice = Read-Host "Would you like to delete *.*_original backup files? y/n"
    switch ($UserChoice) {
      'y' { # User wants to delete backup files from exiftool
        CleanBackups
       }
      Default { # User doesn't want to delete backup files
      (New-Object System.Media.SoundPlayer "$env:windir\Media\Ring06.wav").Play()
       Read-Host "Press enter to exit"
      }    
    }
  }
}