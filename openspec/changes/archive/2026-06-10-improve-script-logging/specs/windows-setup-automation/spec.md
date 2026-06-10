## MODIFIED Requirements

### Requirement: Run logging and summary
The setup automation SHALL produce concise console progress, an ordered main setup log, detailed secondary logs for top-level scripts, and a final summary.

#### Scenario: Setup completes with mixed results
- **WHEN** setup completes after successful, skipped, failed, manual, or reboot-required items
- **THEN** it SHALL print one final summary grouping items by outcome

#### Scenario: Full setup writes a main log
- **WHEN** the top-level setup runner executes all automatic setup steps
- **THEN** it SHALL write a main setup log containing global progress, brief step results, failure messages, and paths to per-script detailed logs

#### Scenario: Top-level script writes a secondary log
- **WHEN** a top-level script is executed as part of the full setup runner
- **THEN** it SHALL write detailed script output to a script-specific secondary log file

#### Scenario: Child script summary is suppressed in full setup
- **WHEN** a top-level script is executed as a child of the full setup runner
- **THEN** it SHALL NOT print its own summary to the console or main setup log

#### Scenario: Individual script summary is shown
- **WHEN** a top-level script is executed directly by the user
- **THEN** it SHALL print its own final summary

#### Scenario: WinUtil output is isolated
- **WHEN** the WinUtil script is executed as part of the full setup runner
- **THEN** raw WinUtil output SHALL be written to the WinUtil secondary log and SHALL NOT be printed to the console or main setup log

#### Scenario: Script failure is reported concisely
- **WHEN** a top-level script fails as part of the full setup runner
- **THEN** the console and main setup log SHALL report a brief failure message with the path to the relevant secondary log
