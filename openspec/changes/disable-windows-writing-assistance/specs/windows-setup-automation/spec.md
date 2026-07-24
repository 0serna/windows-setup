## ADDED Requirements

### Requirement: Disable Windows writing assistance
The Windows configuration script SHALL disable autocorrection and spell checking in the Windows writing services for the user who runs it, without changing spelling features managed by individual applications.

#### Scenario: Writing assistance is enabled
- **WHEN** either Windows writing-service preference is enabled or absent when the configuration script runs
- **THEN** the script SHALL set both preferences to disabled and report each changed preference as applied

#### Scenario: Writing assistance is already disabled
- **WHEN** both Windows writing-service preferences are disabled when the configuration script runs
- **THEN** the script SHALL leave them unchanged and report them as already configured

#### Scenario: A writing-service preference changes
- **WHEN** the script changes either Windows writing-service preference
- **THEN** it SHALL report that signing out may be required and SHALL NOT restart Windows automatically
