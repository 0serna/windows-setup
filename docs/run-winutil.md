# `scripts/run-winutil.ps1`

Runs the remote WinUtil script from `https://christitus.com/win` in a separate PowerShell process using `data/winutil-custom.json` and `-Noui`.

## Configured WinUtil tweaks

- `WPFTweaksActivity`
- `WPFTweaksConsumerFeatures`
- `WPFTweaksDisableExplorerAutoDiscovery`
- `WPFTweaksWPBT`
- `WPFTweaksDVR`
- `WPFTweaksDeBloat`
- `WPFTweaksLocation`
- `WPFTweaksServices`
- `WPFTweaksTelemetry`
- `WPFTweaksDeleteTempFiles`
- `WPFTweaksEndTaskOnTaskbar`
- `WPFTweaksRestorePoint`
- `WPFTweaksPowershell7Tele`

## Behavior

- Requires Administrator and Windows 11.
- Runs WinUtil isolated from this repository's PowerShell session settings.
- Captures WinUtil output in the repository log.
- Does not include `WPFTweaksDiskCleanup`.
