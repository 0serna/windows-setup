## Context

`scripts/configure-windows.ps1` already applies per-user settings idempotently through `Set-RegistryValueIfNeeded`. Windows stores the global writing-service preferences for the current user under `HKCU:\Software\Microsoft\TabletTip\1.7`.

## Goals / Non-Goals

**Goals:**

- Disable Windows autocorrection and spell checking for the user running the script.
- Preserve idempotent result reporting.
- Record that a sign-out can be necessary without initiating one.

**Non-Goals:**

- Change spelling or autocorrection settings owned by individual applications.
- Apply the settings to other local user profiles.
- Restart Windows or Explorer.

## Decisions

- Set `EnableAutocorrection` and `EnableSpellchecking` to `0` as `DWORD` values under the existing per-user `TabletTip\1.7` key. This maps directly to the two Windows writing services and uses the established registry helper; application-specific configuration and profile enumeration are out of scope.
- Call `Add-RestartRequired` only if either registry value changed. The setting is idempotent, while the session warning is relevant only when this run actually alters it.

## Risks / Trade-offs

- [Compatible applications retain a cached writing-service state] → Inform the user that signing out may be required; do not disrupt the setup by restarting automatically.
- [Some applications implement their own spelling features] → Document that those features are intentionally unchanged.
