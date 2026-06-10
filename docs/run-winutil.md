# `scripts/run-winutil.ps1`

Runs the remote WinUtil script from `https://christitus.com/win` in a separate PowerShell process using `data/winutil-custom.json` and `-Noui`.

## Configured WinUtil tweaks

- `WPFTweaksRestorePoint`: Creates a system restore point before changes.
- `WPFTweaksActivity`: Clears and disables Windows activity history.
- `WPFTweaksConsumerFeatures`: Blocks automatic consumer app suggestions and installs.
- `WPFTweaksDisableExplorerAutoDiscovery`: Stops Explorer from guessing folder types.
- `WPFTweaksWPBT`: Blocks vendor-provided boot-time executables.
- `WPFTweaksDVR`: Disables Game DVR/background recording.
- `WPFTweaksDeBloat`: Removes unwanted preinstalled Windows apps.
- `WPFTweaksLocation`: Disables Windows location tracking.
- `WPFTweaksServices`: Sets selected services to lighter startup modes.
- `WPFTweaksTelemetry`: Disables Microsoft telemetry and related services.
- `WPFTweaksDeleteTempFiles`: Deletes user and system temporary files.
- `WPFTweaksHiber`: Disables hibernation and removes hiberfil.sys usage.
- `WPFTweaksDeliveryOptimization`: Stops Windows update peer sharing.
- `WPFTweaksDisableBGapps`: Prevents Store apps from running in the background.
- `WPFTweaksDisplay`: Reduces visual effects for better responsiveness.
- `WPFTweaksWidget`: Removes Windows Widgets/Web Experience components.
- `WPFTweaksDisableStoreSearch`: Hides Microsoft Store recommendations in search.
- `WPFTweaksRemoveHomeAndGallery`: Removes Explorer Home/Gallery and opens This PC.
- `WPFTweaksWindowsAI`: Disables/removes Windows AI, Copilot, and Recall components.
- `WPFTweaksEndTaskOnTaskbar`: Adds End Task to taskbar right-click menus.
- `WPFTweaksPowershell7Tele`: Disables PowerShell 7 telemetry.

## Behavior

- Requires Administrator and Windows 11.
- Runs WinUtil isolated from this repository's PowerShell session settings.
- Captures WinUtil output in the repository log.
