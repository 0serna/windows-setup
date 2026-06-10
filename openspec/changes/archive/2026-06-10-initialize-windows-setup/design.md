## Context

The repository currently contains `config.md`, a manual record of the user's Windows post-install configuration. The target environment is Windows 11, executed from an administrator PowerShell session. The setup should reproduce the user's personal workflow while remaining idempotent and safe to re-run.

The workflow has three distinct classes of work: external broad Windows tweaks via a custom WinUtil config, owned automation for app installation and user preferences, and concise per-script documentation of effects.

## Goals / Non-Goals

**Goals:**

- Provide a small repository structure for Windows setup automation.
- Install applications from a JSON-defined Winget list.
- Apply Windows 11 preferences through PowerShell in an idempotent way.
- Run the custom WinUtil configuration automatically, but keep it isolated from owned scripts.
- Keep running when individual app installs fail, then report failures at the end.
- Write console output and a simple log file.
- Avoid automatic Windows reboot; only restart Explorer when needed.
- Document each top-level script's effects concisely under `docs/`.

**Non-Goals:**

- Supporting Windows 10 or multi-profile setup.
- Installing or managing Scoop, Chocolatey, or other package managers.
- Fully automating AMD/Gigabyte drivers or hardware-specific installers.
- Automatically rebooting Windows.
- Replacing full application preference files with broad templates.

## Decisions

- Use PowerShell as the primary implementation language.
  - Rationale: Windows configuration, registry edits, Winget invocation, font installation, and app config edits are all native to PowerShell.
  - Alternative considered: batch files; rejected because they are weaker for JSON, registry, and structured error handling.

- Store the app list in JSON.
  - Rationale: app data changes more often than install logic, and JSON keeps the list readable without editing script code.
  - Alternative considered: hardcoding apps in the script; rejected because it makes maintenance noisier.
  - Alternative considered: `.psd1`; rejected because JSON is simpler and more universal.

- Keep custom WinUtil execution in a dedicated script.
  - Rationale: WinUtil executes remote, mutable code and applies broad system tweaks. Isolation makes that boundary explicit.
  - Alternative considered: inlining WinUtil into the main configuration script; rejected because it obscures ownership and risk.
  - Alternative considered: reimplementing every WinUtil tweak locally; rejected for the initial setup because the user already accepts WinUtil and wants the current flow automated.

- Make the top-level runner fail early when not elevated.
  - Rationale: many actions require administrator privileges, and partial non-admin execution would create confusing states.
  - Alternative considered: auto-elevation; rejected to keep path/argument behavior simple.

- Treat app install failures as non-fatal.
  - Rationale: one unavailable Winget package should not block the rest of a fresh machine setup.
  - Alternative considered: fail-fast; rejected because it is less useful for bulk setup.

- Apply app configuration only as narrow idempotent edits.
  - Rationale: settings like the Windows Terminal `shift+enter` action can be added safely without replacing the user's whole config.
  - Alternative considered: manage complete config files; rejected because it risks overwriting future personal changes.

## Risks / Trade-offs

- WinUtil can change upstream → Keep it isolated and document that it is an external mutable dependency.
- Winget package IDs can change or installers can fail → Continue execution and report failures in the final summary.
- Some Windows settings require sign-out or reboot → Do not reboot automatically; report required manual action.
- Registry-based configuration can vary across Windows builds → Target Windows 11 only and keep tweaks focused on known preferences.
- Hardware utilities may not be available via Winget → Attempt only configured Winget installs and report failures in the summary.
