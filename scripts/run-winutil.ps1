param(
    [string] $LogPath,
    [switch] $ThrowOnFailure
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath
New-SetupResultState
$script:SetupError = $null

try {
    Assert-Administrator
    Assert-Windows11

    $winUtilConfigPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'data\winutil-custom.json'
    if (-not (Test-Path -LiteralPath $winUtilConfigPath)) {
        throw "WinUtil config not found: $winUtilConfigPath"
    }

    Write-SetupLog 'Running custom WinUtil config. This executes remote mutable code from https://christitus.com/win.' -Level WARN

    $escapedConfigPath = $winUtilConfigPath.Replace("'", "''")
    $winUtilCommand = "& ([ScriptBlock]::Create((Invoke-RestMethod 'https://christitus.com/win'))) -Config '$escapedConfigPath' -Noui"
    $winUtilOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $winUtilCommand 2>&1
    foreach ($line in $winUtilOutput) {
        Write-SetupLog "WinUtil: $line"
    }

    if ($LASTEXITCODE -eq 0 -or ($LASTEXITCODE -eq 1 -and ($winUtilOutput -match '^Done\.$'))) {
        Add-SetupResult -Category Applied -Message 'Custom WinUtil config completed'
        Write-SetupLog 'Custom WinUtil config completed.' -Level SUCCESS
    }
    else {
        $message = "Custom WinUtil config finished with exit code $LASTEXITCODE"
        Add-SetupResult -Category Failed -Message $message
        Write-SetupLog $message -Level ERROR
    }
}
catch {
    Add-SetupResult -Category Failed -Message "Custom WinUtil config failed: $($_.Exception.Message)"
    Write-SetupLog "Custom WinUtil config failed: $($_.Exception.Message)" -Level ERROR
    $script:SetupError = $_
}
finally {
    Show-SetupSummary
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}

if ($ThrowOnFailure) {
    Assert-NoSetupFailures 'Custom WinUtil config completed with failures.'
}
