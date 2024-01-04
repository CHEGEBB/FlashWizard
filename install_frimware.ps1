# Global vars
$unpackDir = "updater_unpacked"
$zipUpdaterScript = "META-INF/com/google/android/updater-script"
$firmwarePartitionMap = @{}

function Cleanup {
    Write-Host "Cleaning up."
    Remove-Item -Path $unpackDir -Recurse -ErrorAction SilentlyContinue
}

function ProcessUpdater($updaterZip) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (-not (Test-Path $updaterZip) -or -not (Test-Path $updaterZip)) {
        Write-Host "This does not appear to be an android updater file."
        Cleanup
        exit 1
    }

    New-Item -ItemType Directory -Path $unpackDir -Force | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($updaterZip, $unpackDir)
}

function ParseFirmwarePartitionMapping {
    $scriptFile = Get-Content -Path (Join-Path $unpackDir $zipUpdaterScript)
    $lines = $scriptFile | Where-Object { $_ -match 'package_extract_file' -and ($_ -match 'firmware-update' -or $_ -match 'RADIO') -and ($_ -notmatch 'bak') }
    
    foreach ($line in $lines) {
        $filename, $partition = $line.Replace('package_extract_file', '') -replace '[",();]', '' -split ','
        $firmwarePartitionMap[$filename] = $partition
    }
}

function SanityCheck($firmwareBaseDir) {
    $totalNumFiles = 0

    foreach ($dirName in @('firmware-update', 'RADIO')) {
        $dirPath = Join-Path $firmwareBaseDir $dirName
        $numFiles = (Get-ChildItem $dirPath -File).Count
        $totalNumFiles += $numFiles
    }

    if ($totalNumFiles -le 0) {
        Write-Host "No firmware update files found."
        Cleanup
        exit 1
    }

    if ($totalNumFiles -ne $firmwarePartitionMap.Count) {
        Write-Host "The number of firmware files found ($totalNumFiles) differs from what was found in the flashing script ($($firmwarePartitionMap.Count))."
        Write-Host "Aborting."
        Cleanup
        exit 1
    }

    foreach ($filename in $firmwarePartitionMap.Keys) {
        if (-not (Test-Path (Join-Path $firmwareBaseDir $filename))) {
            Write-Host "Failed to find firmware file $filename."
            Cleanup
            exit 1
        }
    }
}

function DownloadFirmwarePage($url) {
    Write-Host "Redirecting to the download page: $url"
    Start-Process $url
}

function CreateFirmwareDirectory($model) {
    $modelDirectory = Join-Path (Get-Location) $model
    New-Item -ItemType Directory -Path $modelDirectory -Force | Out-Null
    return $modelDirectory
}

function DownloadFirmware($url, $outputDir, $outputFilename) {
    Write-Host "Downloading firmware from $url"
    Write-Host "IMPORTANT: Please download the firmware from the opened webpage."
    Write-Host "Once downloaded, unzip the firmware in the project directory: $outputDir"
    Read-Host "Press Enter when you have completed the download and unzip, then you can proceed with flashing."
    $firmwarePath = Join-Path $outputDir $outputFilename
    if (Test-Path $firmwarePath) {
        return $firmwarePath
    } else {
        Write-Host "No firmware detected in $outputDir. Aborting."
        exit 1
    }
}

function FlashFirmware($modelDirectory, $model) {
    Write-Host "`nFlashing firmware for $model"
    # Replace the following line with your actual flashing logic
    Write-Host "Flashing logic goes here."
}

function SelectPhoneBrand {
    Write-Host "`nSelect a phone brand:"
    Write-Host "1. Samsung"
    Write-Host "2. Techno"  # Add more brands as needed
    Write-Host "3. Back to main menu"

    $choice = Read-Host "Enter your choice (1-3):"

    switch ($choice) {
        '1' { SelectSamsungModel }
        '2' { SelectTechnoModel }
        '3' { return }
        default {
            Write-Host "Invalid choice. Please enter a number between 1 and 3."
            SelectPhoneBrand
        }
    }
}

function SelectSamsungModel {
    Write-Host "`nSelect a Samsung model:"
    Write-Host "1. Galaxy S10"
    Write-Host "2. Galaxy Note 20"  # Add more models as needed
    Write-Host "3. Back to phone brand selection"

    $choice = Read-Host "Enter your choice (1-3):"

    switch ($choice) {
        '1' { DownloadAndFlashSamsungFirmware "s10" }
        '2' { DownloadAndFlashSamsungFirmware "note20" }
        '3' { SelectPhoneBrand }
        default {
            Write-Host "Invalid choice. Please enter a number between 1 and 3."
            SelectSamsungModel
        }
    }
}

function SelectTechnoModel {
    Write-Host "`nSelect a Techno model:"
    Write-Host "1. Camon 15"
    Write-Host "2. Spark 5"  # Add more models as needed
    Write-Host "3. Back to phone brand selection"

    $choice = Read-Host "Enter your choice (1-3):"

    switch ($choice) {
        '1' { DownloadAndFlashTechnoFirmware "camon15" }
        '2' { DownloadAndFlashTechnoFirmware "spark5" }
        '3' { SelectPhoneBrand }
        default {
            Write-Host "Invalid choice. Please enter a number between 1 and 3."
            SelectTechnoModel
        }
    }
}

function DownloadAndFlashSamsungFirmware($model) {
    # Example Samsung firmware download URL
    $samsungFirmwareUrl = "https://example.com/samsung/$model/firmware.zip"
    $modelDirectory = CreateFirmwareDirectory $model
    $firmwarePath = DownloadFirmware $samsungFirmwareUrl $modelDirectory "firmware.zip"
    FlashFirmware $modelDirectory $model
}

function DownloadAndFlashTechnoFirmware($model) {
    # Example Techno firmware download URL
    $technoFirmwareUrl = "https://www.hovatek.com/forum/forum-106.html"
    $modelDirectory = CreateFirmwareDirectory $model
    $firmwarePath = DownloadFirmware $technoFirmwareUrl $modelDirectory "firmware.zip"
    FlashFirmware $modelDirectory $model
}

function Main {
    Write-Host "FlashWizard - Firmware Installer"

    while ($true) {
        Write-Host "`nChoose an option:"
        Write-Host "1. Flash firmware"
        Write-Host "2. Backup firmware"
        Write-Host "3. Restore firmware"
        Write-Host "4. Download firmware"
        Write-Host "5. Select phone brand and model"
        Write-Host "6. Quit"

        $choice = Read-Host "Enter your choice (1-6):"

        switch ($choice) {
            '1' { SelectPhoneBrand }
            '2' {
                $backupDir = Read-Host "Enter backup directory:"
                $updaterZip = Read-Host "Enter updater-zip file path:"
                DoBackup $backupDir $updaterZip
            }
            '3' {
                $backupDir = Read-Host "Enter backup directory:"
                DoRestore $backupDir
            }
            '4' {
                $url = Read-Host "Enter firmware download URL:"
                SelectPhoneBrand
            }
            '5' { SelectPhoneBrand }
            '6' {
                Write-Host "Quitting."
                Cleanup
                exit 0
            }
            default {
                Write-Host "Invalid choice. Please enter a number between 1 and 6."
            }
        }
    }
}

Main
