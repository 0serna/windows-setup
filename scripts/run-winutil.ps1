param(
    [string] $LogPath,
    [switch] $ThrowOnFailure,
    [switch] $SuppressSummary,
    [switch] $Quiet
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath -DefaultPrefix 'run-winutil' -Quiet:$Quiet
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
    $encodedWinUtilCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($winUtilCommand))
    $winUtilStdOutPath = [System.IO.Path]::GetTempFileName()
    $winUtilStdErrPath = [System.IO.Path]::GetTempFileName()
    try {
        $winUtilProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encodedWinUtilCommand) -RedirectStandardOutput $winUtilStdOutPath -RedirectStandardError $winUtilStdErrPath -WindowStyle Hidden -Wait -PassThru
        $winUtilOutput = @()
        if (Test-Path -LiteralPath $winUtilStdOutPath) {
            $winUtilOutput += Get-Content -LiteralPath $winUtilStdOutPath
        }
        if (Test-Path -LiteralPath $winUtilStdErrPath) {
            $winUtilOutput += Get-Content -LiteralPath $winUtilStdErrPath
        }
    }
    finally {
        Remove-Item -LiteralPath $winUtilStdOutPath, $winUtilStdErrPath -Force -ErrorAction SilentlyContinue
    }

    foreach ($line in $winUtilOutput) {
        Write-SetupLog "WinUtil: $line" -NoConsole
    }

    $transcriptLine = $winUtilOutput | Where-Object { $_ -match '^Transcript stopped, output file is ' } | Select-Object -Last 1
    if ($transcriptLine) {
        Write-SetupLog "WinUtil transcript: $($transcriptLine -replace '^Transcript stopped, output file is ', '')"
    }

    if ($winUtilProcess.ExitCode -eq 0 -or ($winUtilProcess.ExitCode -eq 1 -and ($winUtilOutput -match '^Done\.$'))) {
        Add-SetupResult -Category Applied -Message 'Custom WinUtil config completed'
        Write-SetupLog 'Custom WinUtil config completed.' -Level SUCCESS
    }
    else {
        $message = "Custom WinUtil config finished with exit code $($winUtilProcess.ExitCode)"
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
    if (-not $SuppressSummary) {
        Show-SetupSummary
    }
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}

if ($ThrowOnFailure) {
    Assert-NoSetupFailures 'Custom WinUtil config completed with failures.'
}
