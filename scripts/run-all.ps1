param(
    [string] $LogPath
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath -DefaultPrefix 'setup'
New-SetupResultState
$script:SetupError = $null
$script:ScriptSteps = [System.Collections.Generic.List[hashtable]]::new()

function Invoke-SetupStep {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $ScriptPath,
        [Parameter(Mandatory)] [string] $LogPrefix
    )

    $detailLogPath = New-SetupLogPath -Prefix $LogPrefix
    $summaryPath = Get-SetupSummaryPath -LogPath $detailLogPath
    $stepEntry = @{ Name = $Name; LogPath = $detailLogPath; Message = '' }
    Write-SetupLog "Starting step: $Name"
    try {
        & $ScriptPath -LogPath $detailLogPath -SummaryPath $summaryPath -ThrowOnFailure -SuppressSummary -Quiet
        $stepEntry.Message = 'completed'
        $script:ScriptSteps.Add($stepEntry)
        Write-SetupLog "$Name completed." -Level SUCCESS
        Add-SetupResult -Category Applied -Message "$Name completed."
    }
    catch {
        $stepEntry.Message = "failed: $($_.Exception.Message)"
        $script:ScriptSteps.Add($stepEntry)
        Write-SetupLog "$Name failed: $($_.Exception.Message)" -Level ERROR
        Add-SetupResult -Category Failed -Message "$Name failed: $($_.Exception.Message)"
    }
}

try {
    Assert-Administrator
    Assert-Windows11

    Invoke-SetupStep -Name 'Winget app installation' -ScriptPath (Join-Path $PSScriptRoot 'install-apps.ps1') -LogPrefix 'install-apps'
    Invoke-SetupStep -Name 'Windows configuration' -ScriptPath (Join-Path $PSScriptRoot 'configure-windows.ps1') -LogPrefix 'configure-windows'
    Invoke-SetupStep -Name 'Custom WinUtil' -ScriptPath (Join-Path $PSScriptRoot 'run-winutil.ps1') -LogPrefix 'run-winutil'

    Add-RestartRequired 'Review whether Windows asks for a manual restart after installers, WinUtil, drivers, or shell changes.'
}
catch {
    Add-SetupResult -Category Failed -Message $_.Exception.Message
    Write-SetupLog $_.Exception.Message -Level ERROR
    $script:SetupError = $_
}
finally {
    if ($script:ScriptSteps.Count -gt 0) {
        Show-GroupedSetupSummary -ScriptSteps $script:ScriptSteps
    }
    else {
        Show-SetupSummary
    }
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}
