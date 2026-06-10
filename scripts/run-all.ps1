param(
    [string] $LogPath
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath
New-SetupResultState
$script:SetupError = $null

function Invoke-SetupStep {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $ScriptPath
    )

    Write-SetupLog "Starting step: $Name"
    try {
        & $ScriptPath -LogPath $script:SetupLogPath -ThrowOnFailure
        Add-SetupResult -Category Applied -Message "$Name completed"
        Write-SetupLog "Completed step: $Name" -Level SUCCESS
    }
    catch {
        Add-SetupResult -Category Failed -Message "$Name failed: $($_.Exception.Message)"
        Write-SetupLog "$Name failed: $($_.Exception.Message)" -Level ERROR
    }
}

try {
    Assert-Administrator
    Assert-Windows11

    Invoke-SetupStep -Name 'Winget app installation' -ScriptPath (Join-Path $PSScriptRoot 'install-apps.ps1')
    Invoke-SetupStep -Name 'Windows configuration' -ScriptPath (Join-Path $PSScriptRoot 'configure-windows.ps1')
    Invoke-SetupStep -Name 'Custom WinUtil' -ScriptPath (Join-Path $PSScriptRoot 'run-winutil.ps1')

    Add-RestartRequired 'Review whether Windows asks for a manual restart after installers, WinUtil, drivers, or shell changes.'
}
catch {
    Add-SetupResult -Category Failed -Message $_.Exception.Message
    Write-SetupLog $_.Exception.Message -Level ERROR
    $script:SetupError = $_
}
finally {
    Show-SetupSummary
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}
