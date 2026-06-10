## Why

The current setup logging mixes global progress, child-script summaries, and verbose third-party output in the same visible stream. WinUtil output is especially noisy and makes the main run log difficult to read when `scripts/run-all.ps1` executes the full setup.

## What Changes

- Make normal console output concise by default: step start, step result, important errors, and one global summary.
- Keep the main setup log ordered and readable with global progress, brief results, and paths to per-script detailed logs.
- Add a detailed secondary log for each top-level script execution.
- Prevent child-script summaries from appearing inside `scripts/run-all.ps1`; keep summaries when scripts run individually.
- Keep WinUtil raw output out of the console and main setup log, recording it in the WinUtil secondary log and referencing any WinUtil transcript path.
- Report failures in the console and main setup log as a brief message plus the relevant secondary log path.

## Capabilities

### New Capabilities

### Modified Capabilities
- `windows-setup-automation`: Refine run logging and summary behavior to support concise visible output, ordered main logs, per-script detailed logs, and isolated WinUtil verbosity.

## Impact

- Affects `scripts/lib/common.ps1` logging helpers.
- Affects top-level scripts under `scripts/`, especially `scripts/run-all.ps1` and `scripts/run-winutil.ps1`.
- Affects generated files under `logs/`.
- No new runtime dependencies are expected.
