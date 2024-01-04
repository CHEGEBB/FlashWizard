function Start-FirmwareInstallation {
    Write-Host "Starting firmware installation..."
}

function Finish-FirmwareInstallation {
    Write-Host "Firmware installation completed."
}

function Display-Banner {
    $banner = @'
    _______  _______  _______  _______  _______
   (  ____ \(  ___ )(  ____ )(  ____ \(  ____ )
   | (    \/| (   ) || (    )|| (    \/| (    )|
   | (__    | (___) || (____)|| (__    | (____)|
   |  __)   |  ___  ||     __)|  __)   |     __)
   | (      | (   ) || (\ (   | (      | (\ (
   | (____/\| )   ( || ) \ \__| (____/\| ) \ \__
    (_______/|/     \||/   \__/(_______/|/   \__/
'@
    Write-Host $banner
}

function Download-FirmwareMenu {
    $choices = @{
        "1" = "All Firmware Versions"
        "2" = "Download Firmware"
        "3" = "Install Firmware"
        "4" = "Go Back"
    }

    while ($true) {
        Display-Banner
        Write-Host "`nDownload Firmware Menu:"
        $choices.GetEnumerator() | Sort-Object Key | ForEach-Object {
            Write-Host ("{0}. {1}" -f $_.Key, $_.Value)
        }

        $choice = Read-Host "Select an option"

        switch ($choice) {
            "1" {
                Start-FirmwareInstallation
                Write-Host "Displaying all firmware versions..."
                Start-Sleep -Seconds 1
            }
            "2" {
                Start-FirmwareInstallation
                Write-Host "Downloading firmware..."

                # Construct the absolute path for install_firmware.ps1
                $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
                $installFirmwarePath = Join-Path $scriptDirectory "scripts\install_firmware.ps1"

                # Replace 'powershell' with the appropriate command to run the install_firmware.ps1 script
                Start-Process powershell -ArgumentList "-File $installFirmwarePath" -Wait
            }
            "3" {
                Start-FirmwareInstallation
                Write-Host "Installing firmware..."

                # Construct the absolute path for install_firmware.ps1
                $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
                $installFirmwarePath = Join-Path $scriptDirectory "scripts\install_firmware.ps1"

                # Replace 'powershell' with the appropriate command to run the install_firmware.ps1 script
                Start-Process powershell -ArgumentList "-File $installFirmwarePath" -Wait
                Finish-FirmwareInstallation
            }
            "4" { break }
            default { Write-Host "Invalid choice. Please try again." }
        }
    }
}

function Main-Menu {
    $choices = @{
        "1" = "Install Drivers"
        "2" = "Detect Device"
        "3" = "Download Firmware"
        "4" = "Download Other Flashing Tools"
        "5" = "Search for Firmware Version based on Phone Model"
        "6" = "Select from a List of All Models Available"
        "7" = "Exit"
    }

    while ($true) {
        Write-Host "`nMain Menu:"
        $choices.GetEnumerator() | Sort-Object Key | ForEach-Object {
            Write-Host ("{0}. {1}" -f $_.Key, $_.Value)
        }

        $choice = Read-Host "Select an option"

        switch ($choice) {
            "1" {
                Start-FirmwareInstallation

                # Run the driver installation logic
                Start-Process powershell -ArgumentList "-File install_drivers.ps1" -Wait

                Finish-FirmwareInstallation
            }
            "2" {
                Start-FirmwareInstallation
                Write-Host "Detecting device..."
                Start-Sleep -Seconds 1
                # Run detect_device.ps1 script
                Start-Process powershell -ArgumentList "-File scripts\detect_device.ps1" -Wait

                Finish-FirmwareInstallation
            }
            "3" { Download-FirmwareMenu }
            "4" {
                Start-FirmwareInstallation
                Write-Host "Downloading other flashing tools..."
                Start-Sleep -Seconds 1
            }
            "5" {
                Start-FirmwareInstallation
                Write-Host "Searching for firmware version based on phone model..."
                Start-Sleep -Seconds 1
            }
            "6" {
                Start-FirmwareInstallation
                Write-Host "Selecting from a list of all models available..."
                Start-Sleep -Seconds 1
            }
            "7" { Write-Host "Exiting..."; break }
            default { Write-Host "Invalid choice. Please try again." }
        }
    }
}

# Execute the main menu
Main-Menu
