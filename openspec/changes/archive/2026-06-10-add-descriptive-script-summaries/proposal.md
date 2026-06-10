## Why

The current full-run summary reports top-level script outcomes but does not explain which apps or settings were installed, already satisfied, failed, or require manual action. A more descriptive summary will make the setup result understandable without opening detailed logs for normal review.

## What Changes

- Add script-specific structured summary output next to each detailed script log as `.summary.json`.
- Update `scripts/run-all.ps1` to read child summary JSON files and print a complete but concise summary grouped by script.
- Show one details path per script section using a repository-relative path.
- For Winget apps, show human app names grouped as installed, already installed, failed, and manual when applicable.
- Add optional `manualUrl` support in `data/winget-apps.json`, displayed only when a failed app has a manual fallback URL.
- For Windows settings, show human setting names grouped as applied, already configured, manual, and failed.
- For WinUtil, show only a simple status in the global summary.
- Keep failure causes and technical IDs in detailed logs or JSON, not in the visible summary.

## Capabilities

### New Capabilities

### Modified Capabilities
- `windows-setup-automation`: Refine run summary behavior to include script-grouped descriptive item summaries sourced from per-script structured summary files.

## Impact

- Affects `scripts/lib/common.ps1` result and summary helpers.
- Affects `scripts/run-all.ps1` summary rendering.
- Affects top-level scripts under `scripts/` to emit `.summary.json` files.
- Affects `data/winget-apps.json` by allowing optional `manualUrl` fields.
- Affects generated files under `logs/`.
