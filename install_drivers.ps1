$drivers = @{
    "ADB" = "https://androidmtk.com/download-universal-adb-driver"
    "Fastboot" = "https://www.flashtool.org/android/drivers-fastbootadb/"
    "MediaTek" = "https://www.hovatek.com/forum/thread-16640.html"
    "Google USB" = "https://developer.android.com/studio/run/win-usb"
}

# Function to simulate downloading animation
function Show-DownloadingAnimation {
    Write-Host "Downloading... " -NoNewline
    for ($i = 0; $i -lt 3; $i++) {
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline
    }
    Write-Host ""
}

# Function to download a driver
function Download-Driver {
    param (
        [string]$driver,
        [string]$url
    )

    Show-DownloadingAnimation
    Write-Host "Downloading $driver Driver..."
    Start-Process $url -Wait
}

# Function to display how-to-install information
function Display-HowToInstall {
    $filePath = Join-Path (Get-Location) "how_to_install.txt"

    try {
        $content = Get-Content -Path $filePath -Raw
        Write-Host "How to Install Drivers:"
        Write-Host $content
    } catch {
        Write-Host "Error: File Not Found - $filePath"
    }
}

# Download each driver
foreach ($driver in $drivers.Keys) {
    Download-Driver -driver $driver -url $drivers[$driver]
    Start-Sleep -Seconds 5  # Add a delay (e.g., 5 seconds) between each driver download
}

# Display how-to-install information
Display-HowToInstall
