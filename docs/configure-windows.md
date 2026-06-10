# `scripts/configure-windows.ps1`

Applies Windows/user preferences idempotently.

## Changes

- Sets regional format to United States (`en-US`).
- Adds English International keyboard (`0409:00020409`).
- Disables toast notifications.
- Enables Storage Sense.
- Enables Storage Sense temporary file cleanup.
- Enables Storage Sense recycle bin cleanup.
- Enables Storage Sense downloads cleanup.
- Sets recycle bin cleanup retention to 30 days.
- Sets downloads cleanup retention to 60 days.
- Sets Storage Sense cadence to monthly.
- Turns Bluetooth radio off without disabling the Bluetooth adapter.
- Keeps desktop icons globally visible.
- Hides only the default Windows 11 desktop icons: Computer, User's Files, Network, Recycle Bin, and Control Panel.
- Sets visual effects to best performance.
- Keeps smooth screen font edges enabled.
- Adds Windows Terminal `shift+enter` binding to send the escape sequence for newline input.

## Behavior

- Requires Administrator and Windows 11.
- Leaves already-correct settings unchanged.
- Restarts Explorer only when Explorer-related settings changed.
- Never restarts Windows automatically.
