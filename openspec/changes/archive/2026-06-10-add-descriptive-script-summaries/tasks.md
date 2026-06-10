## 1. Structured Summary Infrastructure

- [x] 1.1 Add shared helpers for deriving `.summary.json` paths from script log paths
- [x] 1.2 Add shared helpers for writing per-script structured summary JSON files
- [x] 1.3 Add shared helpers for rendering repository-relative log paths in summaries

## 2. App Summary Data

- [x] 2.1 Update `data/winget-apps.json` to support optional `manualUrl` for apps that need manual fallback links
- [x] 2.2 Update `scripts/install-apps.ps1` to record human app names under Installed, Already installed, Failed, and Manual categories
- [x] 2.3 Include `manualUrl` in failed app summary entries when available
- [x] 2.4 Ensure the visible app summary excludes Winget IDs, command output, and failure causes

## 3. Windows Configuration Summary Data

- [x] 3.1 Update Windows configuration result messages to be concise human setting names
- [x] 3.2 Update `scripts/configure-windows.ps1` to emit Applied, Already configured, Manual, and Failed structured summary categories
- [x] 3.3 Preserve detailed technical messages in the detailed log when needed

## 4. WinUtil Summary Data

- [x] 4.1 Update `scripts/run-winutil.ps1` to emit a structured summary with only completed or failed status
- [x] 4.2 Keep WinUtil transcript and raw output in the detailed WinUtil log, not the visible global summary

## 5. Global Summary Rendering

- [x] 5.1 Update `scripts/run-all.ps1` to pass expected summary paths to child scripts
- [x] 5.2 Update `scripts/run-all.ps1` to read child `.summary.json` files after each step
- [x] 5.3 Render the final summary grouped by script, then by script-specific categories
- [x] 5.4 Show one repository-relative `Details:` path per script section
- [x] 5.5 Fall back to concise top-level step results when a child summary JSON file is missing

## 6. Verification

- [x] 6.1 Verify full setup summary lists all installed, already installed, failed, manual, applied, and already configured items by script
- [x] 6.2 Verify failed apps show `manualUrl` when configured and do not show failure causes in the visible summary
- [x] 6.3 Verify individual script execution still prints a useful standalone summary
- [x] 6.4 Run OpenSpec validation and the closest available PowerShell syntax validation
