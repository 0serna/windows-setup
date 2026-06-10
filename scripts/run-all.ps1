param(
    [string] $LogPath
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath -DefaultPrefix 'setup'
New-SetupResultState
$script:SetupError = $null

function Join-SetupStepMessage {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [Parameter(Mandatory)] [string] $DetailLogPath
    )

    return "$($Message.TrimEnd('.')). Details: $DetailLogPath"
}

function Invoke-SetupStep {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $ScriptPath,
        [Parameter(Mandatory)] [string] $LogPrefix
    )

    $detailLogPath = New-SetupLogPath -Prefix $LogPrefix
    Write-SetupLog (Join-SetupStepMessage -Message "Starting step: $Name" -DetailLogPath $detailLogPath)
    try {
        & $ScriptPath -LogPath $detailLogPath -ThrowOnFailure -SuppressSummary -Quiet
        $message = Join-SetupStepMessage -Message "$Name completed" -DetailLogPath $detailLogPath
        Add-SetupResult -Category Applied -Message $message
        Write-SetupLog $message -Level SUCCESS
    }
    catch {
        $message = Join-SetupStepMessage -Message "$Name failed: $($_.Exception.Message)" -DetailLogPath $detailLogPath
        Add-SetupResult -Category Failed -Message $message
        Write-SetupLog $message -Level ERROR
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
    Show-SetupSummary
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}
