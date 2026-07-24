# `scripts/run-all.ps1`

Runs the full setup workflow.

## Order

1. `scripts/install-apps.ps1`
2. `scripts/configure-windows.ps1`
3. `scripts/run-winutil.ps1`

## Behavior

- Requires Administrator and Windows 11.
- Each child script writes to its own log file; the parent log captures high-level step results and a grouped summary.
- Runs WinUtil last.
- Does not mark a child step completed if that child script reports failures.
- Continues to later steps when one child step fails.
- Reports that a manual restart or sign-out may be needed.
- Never reboots Windows automatically.
