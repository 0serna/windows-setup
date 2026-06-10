## Why

The current Windows setup process started as a manual checklist in `config.md`, which made a fresh install repetitive and easy to miss steps. This change turns the automatable parts into an idempotent Windows 11 setup workflow while leaving risky or hardware-specific work outside automation.

## What Changes

- Add a repository structure for Windows setup automation.
- Add an automatic app installation workflow driven by a JSON app list and Winget.
- Add an automatic Windows configuration workflow for personal OS preferences.
- Add an isolated custom WinUtil runner using a repository-owned config file.
- Add logging and end-of-run summaries for installed, skipped, failed, manual, and reboot-required items.
- Add concise per-script documentation under `docs/` describing each script's effects.
- Add a top-level runner that executes the automatic setup without rebooting Windows.

## Capabilities

### New Capabilities
- `windows-setup-automation`: Covers automatic, idempotent Windows 11 setup, including Winget app installation, custom WinUtil execution, OS preference configuration, app configuration, logging, failure reporting, and per-script documentation.

### Modified Capabilities

## Impact

- Adds PowerShell scripts under the repository for setup execution.
- Adds JSON data files for app installation inputs.
- Adds concise documentation for the effects of each top-level setup script.
- Depends on Windows 11, administrator PowerShell, Winget, and the external WinUtil automation endpoint.
- Does not add support for Windows 10, Scoop, Chocolatey, automatic driver installation, or automatic Windows rebooting.
