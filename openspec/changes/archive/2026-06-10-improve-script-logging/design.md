## Context

The repository currently uses shared PowerShell helpers for logging, result tracking, and summaries. `scripts/run-all.ps1` passes one log path into child scripts, so child progress, child summaries, and verbose external output all land in the same visible stream. WinUtil is an external mutable script that produces noisy output and its own transcript, making it the clearest source of log readability issues.

## Goals / Non-Goals

**Goals:**
- Keep default console output concise during full setup runs.
- Keep the main setup log readable as a global execution record.
- Create one detailed secondary log for each top-level script execution.
- Preserve useful detail for troubleshooting without showing it in the normal console path.
- Keep individual script execution useful by retaining individual summaries outside `run-all.ps1`.

**Non-Goals:**
- Replacing WinUtil behavior or reimplementing WinUtil tweaks.
- Adding a new logging framework or dependency.
- Adding configurable verbosity modes unless needed by the smallest correct implementation.
- Changing the setup order or the documented system preferences.

## Decisions

- Separate visible output from detailed logging.
  - Rationale: console output should answer "what is happening now?" while detailed logs answer "what exactly happened?".
  - Alternative considered: keep one stream and filter lines. Rejected because WinUtil and Winget output are external and can change shape over time.

- Give each top-level script its own secondary detail log when run from `run-all.ps1`.
  - Rationale: failures can point to one focused file, and verbose output does not disrupt global progress.
  - Alternative considered: put detailed child sections inside the main setup log. Rejected because the main log would still become hard to scan.

- Suppress child summaries during `run-all.ps1` and keep one global summary.
  - Rationale: nested summaries make the run look fragmented and can be mistaken for the final result.
  - Alternative considered: mini-summaries per child. Rejected to keep the default output concise.

- Treat WinUtil output as detail-only.
  - Rationale: WinUtil emits banners, tables, registry operations, and transcript lines that are useful for debugging but not for normal progress.
  - Alternative considered: selectively forwarding important WinUtil lines. Rejected for the initial change because upstream output is mutable and filtering risks missing or misclassifying messages.

## Risks / Trade-offs

- Main log contains less immediate diagnostic detail → Include the secondary log path in every child result and failure message.
- Per-script secondary logs add more files under `logs/` → Use clear script-based names and timestamps.
- Global summary may not include every per-item child result unless results are propagated → Preserve enough global status to show each top-level step result, with detailed per-item results in the secondary logs.
- WinUtil transcript path may not always be emitted → Capture it when present, but rely on the run-winutil secondary log as the stable detail location.
