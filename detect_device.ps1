# Configuration
$DEFAULT_CONFIG = "default_config.json"
$PAYLOAD_DIR = "payloads/"
$DEFAULT_PAYLOAD = "generic_dump_payload.bin"
$DEFAULT_DA_ADDRESS = 0x200D00

$deviceFound = $false
$spinnerThread = $null
$spinnerChars = "|/-\"
$spinIdx = 0

function SpinnerAnimation {
    while (-not $deviceFound) {
        Write-Host ("Waiting for device " + $spinnerChars[$spinIdx]) -ForegroundColor Cyan -NoNewline
        $spinIdx = ($spinIdx + 1) % $spinnerChars.Length
        Start-Sleep -Milliseconds 100
        Clear-Host
    }
}

function DetectDevice {
    try {
        $configData = Get-Content "custom_config.json" | ConvertFrom-Json

        foreach ($hwCode in $configData.Keys) {
            Write-Host "Setting up configuration for device with hw_code: $hwCode"
            $configInfo = $configData[$hwCode]
            Write-Host "Config info: $configInfo"

            if (-not (Test-Path $DEFAULT_CONFIG)) {
                throw "Default config is missing"
            }

            $global:deviceFound = $false
            $spinnerThread = Start-Thread -ScriptBlock { SpinnerAnimation } -IsBackground $true

            $device = Find-Device

            if ($device) {
                $global:deviceFound = $true
                $spinnerThread.Join()

                Write-Host "Device found!" -ForegroundColor Green

                $config = Get-DeviceInfo $device $null $configInfo

                while ($device.Preloader) {
                    $device = Crash-Preloader $device $config
                    $null = Get-DeviceInfo $device $null $configInfo
                }

                Log "Disabling watchdog timer"
                $device.Write32 $config.WatchdogAddress 0x22000064

                if ($true) {  # Add your condition for further execution
                    Log "Disabling protection"
                    $payload = Prepare-Payload $config
                    $result = Exploit $device $config.WatchdogAddress $config.PayloadAddress $config.Var_0 $config.Var_1 $payload

                    if ($false) {  # Add your condition for testing
                        while (-not $result) {
                            $device.Dev.Close()
                            $config.Var_1++
                            Log ("Test mode, testing {0}..." -f $config.Var_1)
                            $device = Find-Device
                            $device.Handshake()
                            while ($device.Preloader) {
                                $device = Crash-Preloader $device $config
                                $device.Handshake()
                            }
                            $result = Exploit $device $config.WatchdogAddress $config.PayloadAddress $config.Var_0 $config.Var_1 $payload
                        }
                    }
                }
                else {
                    Log "Insecure device, sending payload using send_da"

                    if (-not $config.CustomPayload) {
                        $config.Payload = $DEFAULT_PAYLOAD
                    }

                    if (-not $config.CustomPayloadAddress) {
                        $config.PayloadAddress = $DEFAULT_DA_ADDRESS
                    }

                    $payload = Prepare-Payload $config

                    $payload += [byte[]]@(0) * 0x100

                    $device.SendDa $config.PayloadAddress $payload.Length 0x100 $payload
                    $device.JumpDa $config.PayloadAddress

                    $result = $device.Read 4
                }

                $bootromName = "bootrom_{0}.bin" -f $hwCode -replace "0x", ""

                if ($result -eq 0xA1A2A3A4) {
                    Log "Protection disabled"
                }
                elseif ($result -eq 0xC1C2C3C4) {
                    Dump-Brom $device $bootromName
                }
                elseif ($result -eq 0x0000C1C2 -and $device.Read(4) -eq 0xC1C2C3C4) {
                    Dump-Brom $device $bootromName $true
                }
                elseif ($result -ne "") {
                    throw "Unexpected result {0}" -f $result
                }
                else {
                    Log "Payload did not reply"
                }
            }
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}

function Get-DeviceInfo {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("device")]
        [Object]$Device,

        [Parameter(Mandatory = $true)]
        [Alias("arguments")]
        [Object]$Arguments,

        [Parameter(Mandatory = $true)]
        [Alias("configInfo")]
        [Object]$ConfigInfo
    )

    $hwCode = $Device.GetHwCode()
    $hwSubCode, $hwVer, $swVer = $Device.GetHwDict()
    $secureBoot, $serialLinkAuthorization, $downloadAgentAuthorization = $Device.GetTargetConfig()

    $config = Get-ConfigObject $ConfigInfo $hwCode

    if ($false) {  # Add your conditions for modification
        $config.Payload = $DEFAULT_PAYLOAD
    }

    if ($false) {  # Add your conditions for modification
        $config.Var_1 = [int]"custom_var_1"
    }

    if ($false) {  # Add your conditions for modification
        $config.WatchdogAddress = [int]"custom_watchdog"
    }

    if ($false) {  # Add your conditions for modification
        $config.UartBase = [int]"custom_uart"
    }

    if ($false) {  # Add your conditions for modification
        $config.PayloadAddress = [int]"custom_payload_address"
    }

    if ($false) {  # Add your conditions for modification
        $config.Payload = "custom_payload"
    }

    if ($false) {  # Add your conditions for modification
        $config.CrashMethod = 3  # Your custom crash method
    }

    if (-not (Test-Path "$PAYLOAD_DIR$config.Payload")) {
        throw "Payload file $($PAYLOAD_DIR + $config.Payload) doesn't exist"
    }

    Write-Host ""
    Log "Device hw code: {0}" -f ("0x{0:X}" -f $hwCode)
    Log "Device hw sub code: {0}" -f ("0x{0:X}" -f $hwSubCode)
    Log "Device hw version: {0}" -f ("0x{0:X}" -f $hwVer)
    Log "Device sw version: {0}" -f ("0x{0:X}" -f $swVer)
    Log "Device secure boot: $secureBoot"
    Log "Device serial link authorization: $serialLinkAuthorization"
    Log "Device download agent authorization: $downloadAgentAuthorization"
    Write-Host ""

    return $config, $serialLinkAuthorization, $downloadAgentAuthorization, $hwCode
}

function Crash-Preloader {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("device")]
        [Object]$Device,

        [Parameter(Mandatory = $true)]
        [Alias("config")]
        [Object]$Config
    )

    Write-Host ""
    Log "Found device in preloader mode, trying to crash..."
    Write-Host ""
    
    if ($Config.CrashMethod -eq 0) {
        try {
            $payload = [byte[]]@(0x00, 0x01, 0x9F, 0xE5, 0x10, 0xFF, 0x2F, 0xE1) + ([byte[]]@(0x00) * 0x110)
            $Device.SendDa 0 $payload.Length 0 $payload
            $Device.JumpDa 0
        }
        catch {
            Log $_.Exception.Message
            Write-Host ""
        }
    }
    elseif ($Config.CrashMethod -eq 1) {
        $payload = [byte[]]@(0x00) * 0x100
        $Device.SendDa 0 $payload.Length 0x100 $payload
        $Device.JumpDa 0
    }
    elseif ($Config.CrashMethod -eq 2) {
        $Device.Read32 0
    }

    $Device.Dev.Close()
    $device = Find-Device

    return $device
}

function Dump-Brom {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("device")]
        [Object]$Device,

        [Parameter(Mandatory = $true)]
        [Alias("bootromName")]
        [string]$BootromName,

        [Parameter(Mandatory = $false)]
        [Alias("wordMode")]
        [bool]$WordMode = $false
    )

    Log "Found send_dword, dumping bootrom to $BootromName"

    try {
        $stream = [System.IO.File]::OpenWrite($BootromName)

        if ($WordMode) {
            for ($i = 0; $i -lt (0x20000 / 4); $i++) {
                $Device.Read(4) | Out-Null  # discard garbage
                $stream.Write($Device.Read(4), 0, 4)
            }
        }
        else {
            $stream.Write($Device.Read(0x20000), 0, 0x20000)
        }
    }
    finally {
        $stream.Close()
    }
}

function Prepare-Payload {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("config")]
        [Object]$Config
    )

    $payload = [System.IO.File]::ReadAllBytes("$PAYLOAD_DIR$config.Payload")

    # replace watchdog_address and uart_base in generic payload
    $payload[-4..-1] = [BitConverter]::GetBytes($Config.WatchdogAddress)
    $payload[-8..-5] = [BitConverter]::GetBytes($Config.UartBase) + $payload[-4..-1]

    while ($payload.Length % 4 -ne 0) {
        $payload += [byte]0
    }

    return $payload
}

function Find-Device {
    # Implement device finding logic here and return the device object
    return $null
}

function Exploit {
    # Implement exploit logic here and return the result
    return $false
}

function Log {
    param(
        [Parameter(Mandatory = $true)]
        [Alias("message")]
        [string]$Message
    )

    Write-Host $Message
}

# Main script logic
DetectDevice
