## Repository Structure

```text
.
├── data/                 # app lists and configuration data
├── docs/                 # script documentation
├── logs/                 # execution logs
├── openspec/             # specs and change proposals
└── scripts/              # PowerShell automation
    └── lib/              # shared PowerShell utilities
```

## Repository Commands

- `.\scripts\run-all.ps1`: run the full setup workflow (install apps → configure Windows → WinUtil).
- `.\scripts\install-apps.ps1`: install applications via winget.
- `.\scripts\configure-windows.ps1`: apply Windows system preferences.
- `.\scripts\run-winutil.ps1`: run Chris Titus WinUtil tweaks.

## Docs

- When a script changes, update its corresponding `docs/*.md` to match — behavior, order, and lists must stay in sync.

## PowerShell Validation

From WSL, invoke the installed Windows PowerShell executable with `pwsh.exe` (or `powershell.exe`). To validate any repository-relative `.ps1` file without running it, set `script` to its path:

```bash
script='scripts/configure-windows.ps1'
pwsh.exe -NoProfile -NonInteractive -Command "\$path = Join-Path \$PWD.ProviderPath '$script'; \$tokens = \$null; \$errors = \$null; [void][System.Management.Automation.Language.Parser]::ParseFile(\$path, [ref]\$tokens, [ref]\$errors); if (\$errors.Count) { \$errors | ForEach-Object ToString; exit 1 }"
```