# Windows Setup

Personal Windows 11 setup automation for a fresh install.

## Usage

Open PowerShell as Administrator from the repository root and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\scripts\run-all.ps1
```

## Individual scripts

Each top-level script can also be run independently from an Administrator PowerShell session:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\scripts\install-apps.ps1
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\scripts\configure-windows.ps1
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\scripts\run-winutil.ps1
```

## Script documentation

- `scripts/run-all.ps1`: `docs/run-all.md`
- `scripts/install-apps.ps1`: `docs/install-apps.md`
- `scripts/configure-windows.ps1`: `docs/configure-windows.md`
- `scripts/run-winutil.ps1`: `docs/run-winutil.md`
