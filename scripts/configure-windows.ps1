param(
    [string] $LogPath,
    [string] $SummaryPath,
    [switch] $ThrowOnFailure,
    [switch] $SuppressSummary,
    [switch] $Quiet
)

. (Join-Path $PSScriptRoot 'lib\common.ps1')

Initialize-SetupLog -LogPath $LogPath -DefaultPrefix 'configure-windows' -Quiet:$Quiet
New-SetupResultState
$script:SetupError = $null

function Set-CultureIfNeeded {
    $desired = 'en-US'
    $current = (Get-Culture).Name
    if ($current -eq $desired) {
        Add-SetupResult -Category Satisfied -Message 'Regional format is United States'
        Write-SetupLog 'Regional format is already United States.'
        return
    }

    Set-Culture -CultureInfo $desired
    Add-SetupResult -Category Applied -Message 'Regional format set to United States'
    Add-RestartRequired 'Regional format changes may require sign-out or restart.'
}

function Set-InternationalKeyboardIfNeeded {
    $languageTag = 'en-US'
    $inputTip = '0409:00020409'
    $list = Get-WinUserLanguageList
    $entry = $list | Where-Object { $_.LanguageTag -eq $languageTag } | Select-Object -First 1

    if ($null -eq $entry) {
        $list.Add($languageTag)
        $entry = $list | Where-Object { $_.LanguageTag -eq $languageTag } | Select-Object -First 1
    }

    if ($entry.InputMethodTips -contains $inputTip) {
        Add-SetupResult -Category Satisfied -Message 'English International keyboard is configured'
        Write-SetupLog 'English International keyboard is already configured.'
        return
    }

    $entry.InputMethodTips.Add($inputTip)
    Set-WinUserLanguageList -LanguageList $list -Force
    Add-SetupResult -Category Applied -Message 'English International keyboard configured'
    Add-RestartRequired 'Keyboard/input changes may require sign-out.'
}

function Invoke-WinRtAsyncOperation {
    param(
        [Parameter(Mandatory)] $Operation,
        [Parameter(Mandatory)] [Type] $ResultType
    )

    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
        $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
    })[0]
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($Operation))
    $netTask.Wait(-1) | Out-Null
    return $netTask.Result
}

function Get-BluetoothRadios {
    [Windows.Devices.Radios.Radio,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    [Windows.Devices.Radios.RadioAccessStatus,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
    [Windows.Devices.Radios.RadioState,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null

    $access = Invoke-WinRtAsyncOperation -Operation ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) -ResultType ([Windows.Devices.Radios.RadioAccessStatus])
    if ($access -ne [Windows.Devices.Radios.RadioAccessStatus]::Allowed) {
        throw "Bluetooth radio access was not allowed: $access"
    }

    $radios = Invoke-WinRtAsyncOperation -Operation ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) -ResultType ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
    return @($radios | Where-Object { $_.Kind -eq 'Bluetooth' })
}

function Enable-BluetoothDeviceIfNeeded {
    $devices = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue | Where-Object { $_.Status -ne 'OK' }
    foreach ($device in $devices) {
        try {
            Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
            Write-SetupLog "Bluetooth adapter enabled before turning radio off: $($device.FriendlyName)" -Level WARN
        }
        catch {
            Write-SetupLog "Could not enable Bluetooth adapter $($device.FriendlyName): $($_.Exception.Message)" -Level WARN
        }
    }
}

function Set-BluetoothRadioOff {
    if ((Get-Service bthserv -ErrorAction SilentlyContinue).Status -eq 'Stopped') {
        Start-Service bthserv
    }

    $bluetoothRadios = Get-BluetoothRadios
    if (-not $bluetoothRadios) {
        Enable-BluetoothDeviceIfNeeded
        Start-Sleep -Seconds 2
        $bluetoothRadios = Get-BluetoothRadios
    }

    if (-not $bluetoothRadios) {
        Add-SetupResult -Category Manual -Message 'Bluetooth radio was not found; turn Bluetooth off manually in Windows Settings.'
        Write-SetupLog 'Bluetooth radio was not found; turn Bluetooth off manually in Windows Settings.' -Level WARN
        return
    }

    foreach ($radio in $bluetoothRadios) {
        if ($radio.State -eq [Windows.Devices.Radios.RadioState]::Off) {
            Add-SetupResult -Category Satisfied -Message "Bluetooth radio is already off: $($radio.Name)"
            Write-SetupLog "Bluetooth radio is already off: $($radio.Name)"
            continue
        }

        $status = Invoke-WinRtAsyncOperation -Operation ($radio.SetStateAsync([Windows.Devices.Radios.RadioState]::Off)) -ResultType ([Windows.Devices.Radios.RadioAccessStatus])
        if ($status -eq [Windows.Devices.Radios.RadioAccessStatus]::Allowed) {
            Add-SetupResult -Category Applied -Message "Bluetooth radio turned off: $($radio.Name)"
            Write-SetupLog "Bluetooth radio turned off: $($radio.Name)" -Level SUCCESS
        }
        else {
            Add-SetupResult -Category Failed -Message "Could not turn Bluetooth radio off: $($radio.Name) returned $status"
            Write-SetupLog "Could not turn Bluetooth radio off: $($radio.Name) returned $status" -Level ERROR
        }
    }
}

function Set-WindowsTerminalShiftEnter {
    $escapeSequence = ([char]0x1b).ToString() + '13;2u'
    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
    )

    $settingsPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ([string]::IsNullOrWhiteSpace($settingsPath)) {
        Add-SetupResult -Category Manual -Message 'Windows Terminal settings.json was not found; configure shift+enter after Terminal is installed and opened once.'
        Write-SetupLog 'Windows Terminal settings.json was not found.' -Level WARN
        return
    }

    try {
        $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
    }
    catch {
        Add-SetupResult -Category Failed -Message "Could not parse Windows Terminal settings: $settingsPath"
        Write-SetupLog "Could not parse Windows Terminal settings: $settingsPath" -Level ERROR
        return
    }

    if (-not ($settings.PSObject.Properties.Name -contains 'actions') -or $null -eq $settings.actions) {
        $settings | Add-Member -NotePropertyName actions -NotePropertyValue @()
    }

    $exists = @($settings.actions) | Where-Object {
        $actionItem = $_
        $hasKeys = $actionItem.PSObject.Properties.Name -contains 'keys'
        $hasCommand = $actionItem.PSObject.Properties.Name -contains 'command'

        if ($hasKeys -and $hasCommand) {
            $command = $actionItem.command
            $hasAction = $command.PSObject.Properties.Name -contains 'action'
            $hasInput = $command.PSObject.Properties.Name -contains 'input'

            $actionItem.keys -eq 'shift+enter' -and $hasAction -and $hasInput -and $command.action -eq 'sendInput' -and $command.input -eq $escapeSequence
        }
        else {
            $false
        }
    }

    if ($exists) {
        Add-SetupResult -Category Satisfied -Message 'Windows Terminal shift+enter action already exists'
        Write-SetupLog 'Windows Terminal shift+enter action already exists.'
        return
    }

    $action = [pscustomobject]@{
        command = [pscustomobject]@{
            action = 'sendInput'
            input = $escapeSequence
        }
        keys = 'shift+enter'
    }

    $settings.actions = @($settings.actions) + $action
    $settings | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath -Encoding utf8
    Add-SetupResult -Category Applied -Message 'Windows Terminal shift+enter action added'
    Write-SetupLog 'Windows Terminal shift+enter action added.' -Level SUCCESS
}

try {
    Assert-Administrator
    Assert-Windows11

    $explorerRestartNeeded = $false
    $desktopIconSettingsChanged = $false

    Set-CultureIfNeeded
    Set-InternationalKeyboardIfNeeded

    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'ToastEnabled' -Value 0 -Type DWord -Description 'Notifications disabled' | Out-Null

    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '01' -Value 1 -Type DWord -Description 'Storage Sense enabled' | Out-Null
    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '04' -Value 1 -Type DWord -Description 'Storage Sense temporary file cleanup enabled' | Out-Null
    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '08' -Value 1 -Type DWord -Description 'Storage Sense recycle bin cleanup enabled' | Out-Null
    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '32' -Value 1 -Type DWord -Description 'Storage Sense downloads cleanup enabled' | Out-Null
    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '256' -Value 30 -Type DWord -Description 'Storage Sense recycle bin retention set to 30 days' | Out-Null
    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '512' -Value 60 -Type DWord -Description 'Storage Sense downloads retention set to 60 days' | Out-Null
    Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '2048' -Value 30 -Type DWord -Description 'Storage Sense cadence set to monthly' | Out-Null

    Set-BluetoothRadioOff

    # Hide Recycle Bin desktop icon (other default icons are already hidden in Windows 11).
    $defaultDesktopIconPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
    $defaultDesktopIcons = @(
        @{ Name = '{645FF040-5081-101B-9F08-00AA002F954E}'; Description = 'Default desktop icon hidden: Recycle Bin' }
    )

    foreach ($icon in $defaultDesktopIcons) {
        if (Set-RegistryValueIfNeeded -Path $defaultDesktopIconPath -Name $icon.Name -Value 1 -Type DWord -Description $icon.Description) {
            $explorerRestartNeeded = $true
            $desktopIconSettingsChanged = $true
        }
    }

    if (Set-RegistryValueIfNeeded -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Value 2 -Type DWord -Description 'Visual effects set to best performance') {
        $explorerRestartNeeded = $true
    }

    Set-RegistryValueIfNeeded -Path 'HKCU:\Control Panel\Desktop' -Name 'FontSmoothing' -Value '2' -Type String -Description 'Smooth edges of screen fonts enabled' | Out-Null

    Set-WindowsTerminalShiftEnter

    if ($explorerRestartNeeded) {
        Restart-ExplorerShell

        if ($desktopIconSettingsChanged) {
            New-Item -Path $defaultDesktopIconPath -Force | Out-Null
            foreach ($icon in $defaultDesktopIcons) {
                New-ItemProperty -Path $defaultDesktopIconPath -Name $icon.Name -Value 1 -PropertyType DWord -Force | Out-Null
            }
            Write-SetupLog 'Desktop icon settings re-applied after Explorer restart.'
        }
    }
}
catch {
    Add-SetupResult -Category Failed -Message $_.Exception.Message
    Write-SetupLog $_.Exception.Message -Level ERROR
    $script:SetupError = $_
}
finally {
    $summaryData = [ordered]@{}
    if ((Get-Variable -Name SetupResults -Scope Script -ErrorAction SilentlyContinue)) {
        $applied = @($script:SetupResults['Applied'])
        $satisfied = @($script:SetupResults['Satisfied'])
        $manual = @($script:SetupResults['Manual'])
        $failed = @($script:SetupResults['Failed'])
        if ($applied.Count -gt 0) { $summaryData['Applied'] = $applied }
        if ($satisfied.Count -gt 0) { $summaryData['Already configured'] = $satisfied }
        if ($manual.Count -gt 0) { $summaryData['Manual'] = $manual }
        if ($failed.Count -gt 0) { $summaryData['Failed'] = $failed }
    }

    $effectiveSummaryPath = $SummaryPath
    if ([string]::IsNullOrWhiteSpace($effectiveSummaryPath) -and (Get-Variable -Name SetupLogPath -Scope Script -ErrorAction SilentlyContinue)) {
        $effectiveSummaryPath = Get-SetupSummaryPath -LogPath $script:SetupLogPath
    }

    if ($summaryData.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($effectiveSummaryPath)) {
        Write-SetupSummaryJson -SummaryPath $effectiveSummaryPath -Data $summaryData
    }

    if (-not $SuppressSummary) {
        Show-SetupSummary
    }
}

if ($null -ne $script:SetupError) {
    throw $script:SetupError
}

if ($ThrowOnFailure) {
    Assert-NoSetupFailures 'Windows configuration completed with failures.'
}
