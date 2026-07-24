## Why

The fresh-install automation should prevent Windows from automatically correcting or highlighting typed text when the user has deliberately selected the English International keyboard. This avoids unwanted interventions in compatible applications while retaining application-specific preferences.

## What Changes

- Disable Windows autocorrection for the current user.
- Disable Windows spell checking for the current user.
- Report that the changes may require signing out to take effect.
- Document these Windows writing-service preferences.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `windows-setup-automation`: Windows configuration applies the selected per-user writing-service preferences idempotently and reports any sign-out requirement.

## Impact

- `scripts/configure-windows.ps1`
- `docs/configure-windows.md`
