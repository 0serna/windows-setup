# `scripts/configure-windows.ps1`

Applies Windows/user preferences idempotently.

## Changes

- Sets regional format to United States (`en-US`).
- Configures only English International keyboard (`0409:00020409`).
- Disables Windows autocorrection for the current user.
- Disables Windows spell checking for the current user.
- Disables toast notifications.
- Enables Storage Sense.
- Enables Storage Sense temporary file cleanup.
- Enables Storage Sense recycle bin cleanup.
- Enables Storage Sense downloads cleanup.
- Sets recycle bin cleanup retention to 30 days.
- Sets downloads cleanup retention to 60 days.
- Sets Storage Sense cadence to monthly.
- Turns Bluetooth radio off without disabling the Bluetooth adapter.
- Hides the Recycle Bin desktop icon.
- Sets Windows visual effects to best appearance (animations, shadows, Aero Peek, and related effects enabled).
- Adds Windows Terminal `shift+enter` binding to send the escape sequence for newline input.

## Behavior

- Requires Administrator and Windows 11.
- Leaves already-correct settings unchanged.
- Restarts Explorer when Explorer-related or visual-effect settings changed.
- Never restarts Windows automatically.
- Windows writing-service changes can require signing out; they do not change spelling features managed by individual applications.
