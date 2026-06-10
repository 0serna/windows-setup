## 1. Logging Infrastructure

- [x] 1.1 Update shared logging helpers to support separate console output and file-only detailed logging
- [x] 1.2 Add helper behavior for creating script-specific secondary log paths under `logs/`
- [x] 1.3 Add support for suppressing per-script summaries when a script is run as a child of `run-all.ps1`

## 2. Main Runner Logging

- [x] 2.1 Update `scripts/run-all.ps1` to create and pass a secondary log path for each child script
- [x] 2.2 Update `scripts/run-all.ps1` to log concise step start, success, and failure messages with secondary log paths
- [x] 2.3 Ensure `scripts/run-all.ps1` prints only one global summary at the end

## 3. Child Script Logging

- [x] 3.1 Update `scripts/install-apps.ps1` to write detailed output to its secondary log when run from `run-all.ps1`
- [x] 3.2 Update `scripts/configure-windows.ps1` to write detailed output to its secondary log when run from `run-all.ps1`
- [x] 3.3 Update `scripts/run-winutil.ps1` to write raw WinUtil output only to its secondary log during full setup runs
- [x] 3.4 Capture or reference the WinUtil transcript path in the WinUtil secondary log when WinUtil emits one

## 4. Verification

- [x] 4.1 Verify direct script execution still shows the individual script summary
- [x] 4.2 Verify full setup execution uses concise console output and no child summaries
- [x] 4.3 Verify failure reporting includes a brief message and the relevant secondary log path
- [x] 4.4 Run the project check command or the closest available PowerShell syntax validation
