## 1. Repository Structure

- [x] 1.1 Create the initial automation directories for scripts, data, logs, and script documentation
- [x] 1.2 Add a README with administrator execution guidance and the intended setup flow
- [x] 1.3 Remove the temporary `config.md` source file after migrating automated setup inputs

## 2. Shared PowerShell Utilities

- [x] 2.1 Add a shared helper script for administrator checks, logging, result tracking, and summary printing
- [x] 2.2 Add reusable helpers for idempotent registry/property updates and restart-required reporting
- [x] 2.3 Add validation that setup scripts are running on Windows 11

## 3. App Installation

- [x] 3.1 Create the JSON app list with Winget package IDs for the agreed applications where available
- [x] 3.2 Implement the Winget app installer that reads the JSON app list
- [x] 3.3 Detect already-installed apps and report them as satisfied
- [x] 3.4 Continue after individual install failures and include failed apps in the final summary

## 4. WinUtil Integration

- [x] 4.1 Add a dedicated WinUtil script that invokes the custom WinUtil config without UI
- [x] 4.2 Wire the top-level setup runner to call the dedicated WinUtil script instead of embedding the command inline
- [x] 4.3 Log WinUtil execution and report its result in the final summary

## 5. Windows Configuration

- [x] 5.1 Implement idempotent Windows preference configuration for region, keyboard, notifications, Storage Sense, Bluetooth, desktop icons, and visual performance items that can be safely automated
- [x] 5.2 Implement no-automatic-reboot behavior with restart/sign-out messages for changes that need them
- [x] 5.3 Restart Explorer only where required for shell or visual changes

## 6. Application Configuration

- [x] 6.1 Implement an idempotent Windows Terminal settings edit for the `shift+enter` action
- [x] 6.2 Ensure Windows Terminal configuration is skipped or reported clearly if settings are unavailable
- [x] 6.3 Implement JetBrains Mono Nerd Font installation through Winget or PowerShell-native download/install without adding another package manager

## 7. Script Documentation

- [x] 7.1 Add a dedicated documentation file for each top-level setup script
- [x] 7.2 Document Winget-installed applications and failure behavior for `install-apps.ps1`
- [x] 7.3 Document Windows preferences, custom WinUtil tweaks, and run order concisely

## 8. Verification

- [x] 8.1 Run repository checks available for PowerShell syntax or formatting if configured
- [x] 8.2 Verify OpenSpec status shows the change artifacts are complete
- [x] 8.3 Review the final script behavior against the requirements for idempotency, logging, failure continuation, and no automatic Windows reboot
