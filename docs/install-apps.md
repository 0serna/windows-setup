# `scripts/install-apps.ps1`

Installs missing Winget packages from `data/winget-apps.json`.

## Packages

- Microsoft PowerToys (`Microsoft.PowerToys`)
- Visual Studio Code (`Microsoft.VisualStudioCode`)
- JetBrains DataGrip (`JetBrains.DataGrip`)
- Sublime Text (`SublimeHQ.SublimeText.4`)
- MSI Afterburner (`Guru3D.Afterburner`)
- OCCT (`OCBase.OCCT.Personal`)
- Logi Options+ (`Logitech.OptionsPlus`)
- Windows Terminal (`Microsoft.WindowsTerminal`)
- JetBrainsMono Nerd Font (`DEVCOM.JetBrainsMonoNerdFont`)
- Kingston SSD Manager (`Kingston.SSDManager`)

## Behavior

- Requires Administrator and Windows 11.
- Skips packages already installed.
- Logs failed installs and continues with the next package.
- Does not install anything outside `data/winget-apps.json`.
