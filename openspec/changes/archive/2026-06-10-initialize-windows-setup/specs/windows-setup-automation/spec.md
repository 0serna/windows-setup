## ADDED Requirements

### Requirement: Administrator-only setup execution
The setup automation SHALL require an administrator PowerShell session before applying system changes.

#### Scenario: Setup is run without administrator privileges
- **WHEN** the setup runner starts in a non-administrator session
- **THEN** it SHALL stop before applying changes and print a clear administrator requirement message

#### Scenario: Setup is run with administrator privileges
- **WHEN** the setup runner starts in an administrator session
- **THEN** it SHALL continue to the configured automation steps

### Requirement: Winget app installation from JSON
The setup automation SHALL install applications from a JSON-defined Winget app list.

#### Scenario: App is already installed
- **WHEN** an app from the JSON list is already installed
- **THEN** the installer SHALL treat the app as already satisfied without failing the run

#### Scenario: App installation succeeds
- **WHEN** Winget installs an app from the JSON list successfully
- **THEN** the installer SHALL record the app as installed in the run summary

#### Scenario: App installation fails
- **WHEN** Winget fails to install an app from the JSON list
- **THEN** the installer SHALL record the app as failed and continue processing remaining apps

### Requirement: Isolated custom WinUtil execution
The setup automation SHALL provide a dedicated script for running WinUtil with the custom configuration in `data/winutil-custom.json`.

#### Scenario: Custom WinUtil script runs
- **WHEN** the WinUtil script is executed
- **THEN** it SHALL invoke WinUtil using the custom config file and no UI

#### Scenario: Main setup includes WinUtil
- **WHEN** the top-level setup runner executes all automatic setup steps
- **THEN** it SHALL run WinUtil through the dedicated WinUtil script rather than embedding the remote command inline

### Requirement: Windows 11 preference configuration
The setup automation SHALL apply the user's Windows 11 preferences through idempotent PowerShell configuration.

#### Scenario: Preference is not applied
- **WHEN** a supported Windows preference differs from the desired value
- **THEN** the configuration script SHALL apply the desired value

#### Scenario: Preference is already applied
- **WHEN** a supported Windows preference already has the desired value
- **THEN** the configuration script SHALL leave it satisfied without duplicating or failing the change

### Requirement: Narrow application configuration edits
The setup automation SHALL modify application settings only through specific idempotent edits.

#### Scenario: Windows Terminal action is missing
- **WHEN** Windows Terminal settings exist and do not contain the desired `shift+enter` action
- **THEN** the configuration script SHALL add the action without replacing the full settings file

#### Scenario: Windows Terminal action already exists
- **WHEN** Windows Terminal settings already contain the desired `shift+enter` action
- **THEN** the configuration script SHALL not add a duplicate action

### Requirement: No automatic Windows reboot
The setup automation SHALL NOT restart Windows automatically.

#### Scenario: A change requires Windows restart or sign-out
- **WHEN** an applied change requires a Windows restart or sign-out
- **THEN** the setup automation SHALL report the requirement for the user to perform later

#### Scenario: Explorer restart is needed
- **WHEN** an applied visual or shell change requires Explorer to restart
- **THEN** the setup automation MAY restart Explorer without rebooting Windows

### Requirement: Run logging and summary
The setup automation SHALL produce console progress, a simple log file, and a final summary.

#### Scenario: Setup completes with mixed results
- **WHEN** setup completes after successful, skipped, failed, manual, or reboot-required items
- **THEN** it SHALL print a final summary grouping items by outcome

#### Scenario: Setup writes logs
- **WHEN** setup runs
- **THEN** it SHALL write a simple log file containing meaningful progress and failure details

### Requirement: Per-script effect documentation
The repository SHALL document the effects of each top-level setup script in a dedicated file under `docs/`.

#### Scenario: User reviews script effects before execution
- **WHEN** the user wants to understand what a top-level setup script changes
- **THEN** the repository SHALL provide a concise matching document under `docs/`

#### Scenario: App install fallback is required
- **WHEN** a Winget application fails to install
- **THEN** it SHALL appear in the run summary as a failed item
