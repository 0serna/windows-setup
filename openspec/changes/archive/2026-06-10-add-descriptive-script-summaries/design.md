## Context

The setup runner now separates concise global output from detailed per-script logs. However, the final summary still reports mostly top-level script outcomes, so the user must open secondary logs to understand which apps or settings were installed, already satisfied, failed, or require manual action.

## Goals / Non-Goals

**Goals:**
- Print a complete but concise final summary grouped by script.
- Show human-readable item names in the visible summary.
- Keep technical IDs, command output, and failure causes in detailed logs or structured data.
- Generate per-script `.summary.json` files next to each script log so `run-all` can render a reliable global summary without parsing text logs.
- Support optional manual fallback URLs for failed Winget apps.

**Non-Goals:**
- Adding a database or persistent history system.
- Parsing WinUtil output into individual tweak results.
- Showing Winget failure causes in the visible summary.
- Showing technical IDs in the visible summary.
- Changing setup behavior, app selection, or Windows preference choices.

## Decisions

- Use per-script `.summary.json` files as the data source for the global summary.
  - Rationale: structured files avoid fragile parsing of human log text and keep each script responsible for its own domain-specific categories.
  - Alternative considered: parse child log files. Rejected because logs are formatted for humans and external tool output is noisy.

- Store `.summary.json` files in `logs/` next to each matching detailed log.
  - Rationale: the files are generated run artifacts, and colocating them makes log/summary pairs easy to find.
  - Alternative considered: create a folder per run. Rejected for this change because it would reorganize the current log layout more broadly.

- Render the global summary by script first, then domain-specific categories.
  - Rationale: the user wants to know what happened in each script: apps, settings, and WinUtil status.
  - Alternative considered: group by generic outcome first. Rejected because it mixes apps and settings and makes the summary less scannable.

- Use domain-specific visible labels.
  - Rationale: `Installed` / `Already installed` is clearer for apps, while `Applied` / `Already configured` is clearer for settings.
  - Alternative considered: reuse generic result labels everywhere. Rejected because they are less descriptive.

- Show one details path per script section, using a repository-relative path.
  - Rationale: avoids repeating long paths per item while still pointing to the detailed log.
  - Alternative considered: show full UNC paths. Rejected because the summary becomes too wide and noisy.

- Keep WinUtil summary minimal.
  - Rationale: WinUtil is external and mutable; the visible summary should only report whether the custom config completed or failed.
  - Alternative considered: list WinUtil tweaks. Rejected because it would depend on unstable external output.

## Risks / Trade-offs

- Summary JSON can become stale if a script crashes before writing it → `run-all` should fall back to the top-level step result and details log path.
- Full summaries can be long when many items are already satisfied → This is accepted because complete traceability is desired.
- Optional `manualUrl` adds schema flexibility to app data → Keep the field optional and only display it for failed apps.
- Human names may omit technical identifiers useful for debugging → Keep technical IDs in detailed logs and JSON for diagnosis.
