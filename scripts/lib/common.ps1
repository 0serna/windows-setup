Set-StrictMode -Version Latest

function New-SetupLogPath {
    param(
        [string] $Prefix = 'setup'
    )

    $repoRoot = Convert-Path (Join-Path $PSScriptRoot '..\..')
    $logDirectory = Join-Path $repoRoot 'logs'
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'
    return Join-Path $logDirectory "$Prefix-$timestamp.log"
}

function Get-SetupSummaryPath {
    param(
        [Parameter(Mandatory)] [string] $LogPath
    )

    return $LogPath -replace '\.log$', '.summary.json'
}

function Get-RepoRelativePath {
    param(
        [Parameter(Mandatory)] [string] $Path
    )

    $repoRoot = Convert-Path (Join-Path $PSScriptRoot '..\..')
    if ($Path.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($repoRoot.Length + 1)
    }

    return $Path
}

function Write-SetupSummaryJson {
    param(
        [Parameter(Mandatory)] [string] $SummaryPath,
        [Parameter(Mandatory)] [hashtable] $Data
    )

    $parent = Split-Path -Parent $SummaryPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $Data | ConvertTo-Json -Depth 10 | Out-File -FilePath $SummaryPath -Encoding utf8
}

function Initialize-SetupLog {
    param(
        [string] $LogPath,
        [string] $DefaultPrefix = 'setup',
        [switch] $Quiet
    )

    if ([string]::IsNullOrWhiteSpace($LogPath)) {
        $LogPath = New-SetupLogPath -Prefix $DefaultPrefix
    }

    $script:SetupLogPath = $LogPath
    $script:SetupQuiet = $Quiet.IsPresent
    $parent = Split-Path -Parent $script:SetupLogPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    "[$(Get-Date -Format o)] Log started" | Out-File -FilePath $script:SetupLogPath -Encoding utf8 -Append
}

function Write-SetupLog {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')] [string] $Level = 'INFO',
        [switch] $NoConsole
    )

    $line = "[$(Get-Date -Format o)] [$Level] $Message"
    $quiet = (Get-Variable -Name SetupQuiet -Scope Script -ErrorAction SilentlyContinue) -and $script:SetupQuiet
    if (-not $NoConsole -and -not $quiet) {
        Write-Host $line
    }

    if (Get-Variable -Name SetupLogPath -Scope Script -ErrorAction SilentlyContinue) {
        $line | Out-File -FilePath $script:SetupLogPath -Encoding utf8 -Append
    }
}

function New-SetupResultState {
    $script:SetupResults = [ordered]@{
        Applied = New-Object System.Collections.Generic.List[string]
        Satisfied = New-Object System.Collections.Generic.List[string]
        Failed = New-Object System.Collections.Generic.List[string]
        Manual = New-Object System.Collections.Generic.List[string]
        RestartRequired = New-Object System.Collections.Generic.List[string]
    }
}

function Add-SetupResult {
    param(
        [ValidateSet('Applied', 'Satisfied', 'Failed', 'Manual', 'RestartRequired')] [string] $Category,
        [Parameter(Mandatory)] [string] $Message
    )

    if (-not (Get-Variable -Name SetupResults -Scope Script -ErrorAction SilentlyContinue)) {
        New-SetupResultState
    }

    $script:SetupResults[$Category].Add($Message)
}

function Show-SetupSummary {
    if (-not (Get-Variable -Name SetupResults -Scope Script -ErrorAction SilentlyContinue)) {
        return
    }

    Write-SetupLog 'Setup summary:'
    foreach ($category in $script:SetupResults.Keys) {
        Write-SetupLog "${category}: $($script:SetupResults[$category].Count)"
        foreach ($item in $script:SetupResults[$category]) {
            Write-SetupLog "  - $item"
        }
    }
}

function Test-SetupHasFailures {
    if (-not (Get-Variable -Name SetupResults -Scope Script -ErrorAction SilentlyContinue)) {
        return $false
    }

    return $script:SetupResults['Failed'].Count -gt 0
}

function Assert-NoSetupFailures {
    param([Parameter(Mandatory)] [string] $Message)

    if (Test-SetupHasFailures) {
        throw $Message
    }
}

function Test-RunningOnWindows {
    return $env:OS -eq 'Windows_NT'
}

function Test-IsAdministrator {
    if (-not (Test-RunningOnWindows)) {
        return $false
    }

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Administrator {
    if (-not (Test-IsAdministrator)) {
        throw 'This setup must be run from an Administrator PowerShell session.'
    }
}

function Assert-Windows11 {
    if (-not (Test-RunningOnWindows)) {
        throw 'This setup targets Windows 11 and must be run on Windows.'
    }

    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $buildNumber = [int]$os.BuildNumber
    if ($buildNumber -lt 22000) {
        throw "This setup targets Windows 11. Detected: $($os.Caption) build $buildNumber."
    }
}

function Set-RegistryValueIfNeeded {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] $Value,
        [ValidateSet('String', 'DWord', 'QWord', 'Binary')] [string] $Type = 'DWord',
        [Parameter(Mandatory)] [string] $Description
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $current -and $current.$Name -eq $Value) {
        Add-SetupResult -Category Satisfied -Message $Description
        Write-SetupLog "Already configured: $Description"
        return $false
    }

    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
    Add-SetupResult -Category Applied -Message $Description
    Write-SetupLog "Configured: $Description" -Level SUCCESS
    return $true
}

function Add-RestartRequired {
    param([Parameter(Mandatory)] [string] $Message)
    Add-SetupResult -Category RestartRequired -Message $Message
    Write-SetupLog "Restart or sign-out required later: $Message" -Level WARN
}

function Show-GroupedSetupSummary {
    param(
        [Parameter(Mandatory)] [array] $ScriptSteps
    )

    Write-SetupLog 'Summary:'
    foreach ($step in $ScriptSteps) {
        $summaryFilePath = Get-SetupSummaryPath -LogPath $step.LogPath
        $sectionName = $step.Name
        $relativePath = Get-RepoRelativePath -Path $step.LogPath

        Write-SetupLog ' '
        Write-SetupLog "  $sectionName"
        Write-SetupLog "    Details: $relativePath"

        $useFallback = $true
        if (Test-Path -LiteralPath $summaryFilePath) {
            $summaryData = Get-Content -LiteralPath $summaryFilePath -Raw | ConvertFrom-Json
            if ($null -ne $summaryData -and (@($summaryData.PSObject.Properties.Name).Count -gt 0)) {
                $useFallback = $false
                foreach ($prop in $summaryData.PSObject.Properties) {
                    $category = $prop.Name
                    $items = @($prop.Value)
                    $count = $items.Count
                    if ($category -eq 'Status' -and $count -eq 1) {
                        Write-SetupLog "    ${category}: $($items[0])"
                        continue
                    }

                    Write-SetupLog "    ${category}: $count"
                    foreach ($item in $items) {
                        Write-SetupLog "      - $item"
                    }
                }
            }
        }

        if ($useFallback -and -not [string]::IsNullOrWhiteSpace($step.Message)) {
            Write-SetupLog "    Status: $($step.Message)"
        }
    }

}

function Restart-ExplorerShell {
    Write-SetupLog 'Restarting Explorer to apply shell changes. Windows should restart the shell automatically.' -Level WARN
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
}
