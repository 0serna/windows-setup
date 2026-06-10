## MODIFIED Requirements

### Requirement: Run logging and summary
The setup automation SHALL produce concise console progress, an ordered main setup log, detailed secondary logs for top-level scripts, structured per-script summary files, and a final descriptive summary grouped by script.

#### Scenario: Setup completes with mixed results
- **WHEN** setup completes after successful, skipped, failed, manual, or reboot-required items
- **THEN** it SHALL print one final summary grouped by script and then by script-specific outcome category

#### Scenario: Full setup writes a main log
- **WHEN** the top-level setup runner executes all automatic setup steps
- **THEN** it SHALL write a main setup log containing global progress, brief step results, failure messages, and paths to per-script detailed logs

#### Scenario: Top-level script writes a secondary log
- **WHEN** a top-level script is executed as part of the full setup runner
- **THEN** it SHALL write detailed script output to a script-specific secondary log file

#### Scenario: Top-level script writes a structured summary
- **WHEN** a top-level script is executed as part of the full setup runner
- **THEN** it SHALL write a matching `.summary.json` file next to its secondary log file

#### Scenario: Full setup renders script-grouped summaries
- **WHEN** the full setup runner prints the final summary
- **THEN** it SHALL show one section per child script with one repository-relative details path for that script

#### Scenario: App summary is descriptive
- **WHEN** the app installation script contributes to the final summary
- **THEN** the summary SHALL list human app names under Installed, Already installed, Failed, and Manual categories when those categories contain items

#### Scenario: Failed app has manual fallback URL
- **WHEN** a Winget app fails and its app data contains `manualUrl`
- **THEN** the visible summary SHALL show the manual URL with that failed app

#### Scenario: App summary excludes technical detail
- **WHEN** the visible app summary is printed
- **THEN** it SHALL NOT include Winget IDs, command output, or failure causes

#### Scenario: Windows settings summary is descriptive
- **WHEN** the Windows configuration script contributes to the final summary
- **THEN** the summary SHALL list human setting names under Applied, Already configured, Manual, and Failed categories when those categories contain items

#### Scenario: WinUtil summary is concise
- **WHEN** the WinUtil script contributes to the final summary
- **THEN** the summary SHALL show only the WinUtil status and the script details path

#### Scenario: Child script summary is suppressed in full setup
- **WHEN** a top-level script is executed as a child of the full setup runner
- **THEN** it SHALL NOT print its own standalone summary to the console or main setup log

#### Scenario: Individual script summary is shown
- **WHEN** a top-level script is executed directly by the user
- **THEN** it SHALL print its own final summary

#### Scenario: WinUtil output is isolated
- **WHEN** the WinUtil script is executed as part of the full setup runner
- **THEN** raw WinUtil output SHALL be written to the WinUtil secondary log and SHALL NOT be printed to the console or main setup log

#### Scenario: Script failure is reported concisely
- **WHEN** a top-level script fails as part of the full setup runner
- **THEN** the console and main setup log SHALL report a brief failure message with the path to the relevant secondary log
