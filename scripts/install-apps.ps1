param(
    [string] $AppListPath = (Join-Path $PSScriptRoot '..\data\winget-apps.json'),
    [string] $LogPath,
    [switch] $ThrowOnFailure,
    [switch] $SuppressSummary,
    [switch] $Quiet
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath -DefaultPrefix 'install-apps' -Quiet:$Quiet
New-SetupResultState
$script:SetupError = $null

function Test-WingetAppInstalled {
    param([Parameter(Mandatory)] [string] $Id)

    $output = & winget list --id $Id --exact --source winget --disable-interactivity 2>&1
    return ($LASTEXITCODE -eq 0 -and ($output -join "`n") -match [regex]::Escape($Id))
}

function Test-WingetProgressLine {
    param([Parameter(Mandatory)] [string] $Line)

    return $Line -match '(KB|MB|GB)\s*/\s*\d+(\.\d+)?\s*(KB|MB|GB)'
}

try {
    Assert-Administrator
    Assert-Windows11

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Winget was not found. Install or enable Windows Package Manager before running app installation.'
    }

    if (-not (Test-Path $AppListPath)) {
        throw "App list not found: $AppListPath"
    }

    $config = Get-Content -Path $AppListPath -Raw | ConvertFrom-Json

    foreach ($app in $config.apps) {
        $name = $app.name
        $id = $app.wingetId

        if ([string]::IsNullOrWhiteSpace($id)) {
            throw "Winget app entry is missing wingetId: $name"
        }

        Write-SetupLog "Checking $name ($id)."

        if (Test-WingetAppInstalled -Id $id) {
            Add-SetupResult -Category Satisfied -Message "$name ($id) is already installed"
            Write-SetupLog "$name is already installed." -Level SUCCESS
            continue
        }

        Write-SetupLog "Installing $name ($id)."
        $installOutput = & winget install --id $id --exact --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity --silent 2>&1
        foreach ($line in $installOutput) {
            if (-not [string]::IsNullOrWhiteSpace($line) -and -not (Test-WingetProgressLine -Line $line)) {
                Write-SetupLog "winget: $line" -NoConsole
            }
        }

        if ($LASTEXITCODE -eq 0) {
            Add-SetupResult -Category Applied -Message "$name ($id) installed"
            Write-SetupLog "$name installed." -Level SUCCESS
        }
        else {
            $message = "$name ($id) failed with exit code $LASTEXITCODE. Install manually if needed."
            Add-SetupResult -Category Failed -Message $message
            Write-SetupLog $message -Level ERROR
        }
    }
}
catch {
    Add-SetupResult -Category Failed -Message $_.Exception.Message
    Write-SetupLog $_.Exception.Message -Level ERROR
    $script:SetupError = $_
}
finally {
    if (-not $SuppressSummary) {
        Show-SetupSummary
    }
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}

if ($ThrowOnFailure) {
    Assert-NoSetupFailures 'Winget app installation completed with failures.'
}
