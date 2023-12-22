import os
import time
import subprocess
from PyQt5.QtWidgets import (
    QApplication,
    QWidget,
    QVBoxLayout,
    QPushButton,
    QLabel,
    QDesktopWidget,
    QGridLayout,
    QMessageBox,
    QPlainTextEdit,
    QDialog,
)
from subprocess import Popen, PIPE
import webbrowser
from install_drivers import DriverInstallerUI


class FirmwareInstallUI:
    def __init__(self):
        pass  # Add any initialization code here

    def start(self):
        print("Starting firmware installation...")
        # Add any start-up animations or UI updates here

    def finish(self):
        print("Firmware installation completed.")
        # Add any completion animations or UI updates here

    def display_banner(self):
        # Add your ASCII art banner here
        banner = r"""
        _______  _______  _______  _______  _______
       (  ____ \(  ___ )(  ____ )(  ____ \(  ____ )
       | (    \/| (   ) || (    )|| (    \/| (    )|
       | (__    | (___) || (____)|| (__    | (____)|
       |  __)   |  ___  ||     __)|  __)   |     __)
       | (      | (   ) || (\ (   | (      | (\ (
       | (____/\| )   ( || ) \ \__| (____/\| ) \ \__
       (_______/|/     \||/   \__/(_______/|/   \__/
"""
        print(banner)


def download_firmware_menu(ui):
    choices = {
        "1": "All Firmware Versions",
        "2": "Download Firmware",
        "3": "Install Firmware",
        "4": "Go Back",
    }

    while True:
        ui.display_banner()
        print("\033[96mDownload Firmware Menu:\033[0m")
        for key, value in sorted(choices.items()):
            print(f"\033[92m{key}. {value}\033[0m")

        choice = input("\033[95mSelect an option: \033[0m")

        if choice == "1":
            ui.start()
            print("Displaying all firmware versions...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "2":
            ui.start()
            print("Downloading firmware...")

            # Construct the absolute path for install_firmware.py
            script_directory = os.path.dirname(os.path.abspath(__file__))
            install_firmware_path = os.path.join(script_directory, "scripts", "install_firmware.py")

            # Replace 'python' with the appropriate command to run the install_firmware.py script
            subprocess.run(["python", install_firmware_path])
        elif choice == "3":
            ui.start()
            print("Installing firmware...")

            # Construct the absolute path for install_firmware.py
            script_directory = os.path.dirname(os.path.abspath(__file__))
            install_firmware_path = os.path.join(script_directory, "scripts", "install_firmware.py")

            # Replace 'python' with the appropriate command to run the install_firmware.py script
            subprocess.run(["python", install_firmware_path])
            ui.finish()
        elif choice == "4":
            break
        else:
            print("Invalid choice. Please try again.")


def main_menu():
    ui = FirmwareInstallUI()

    choices = {
        "1": "Install Drivers",
        "2": "Detect Device",
        "3": "Download Firmware",
        "4": "Download Other Flashing Tools",
        "5": "Search for Firmware Version based on Phone Model",
        "6": "Select from a List of All Models Available",
        "7": "Exit",
    }

    while True:
        print("\nMain Menu:")
        for key, value in sorted(choices.items()):
            print(f"{key}. {value}")

        choice = input("Select an option: ")

        if choice == "1":
            ui.start()
            
            # Run the driver installation logic
            driver_ui = DriverInstallerUI()
            driver_ui.install_drivers()

            ui.finish()
        elif choice == "2":
            ui.start()
            print("Detecting device...")
            time.sleep(1)  # Add a delay for animation effect

            # Run detect_device.py script
            subprocess.run(["python", os.path.join("scripts", "detect_device.py")])

            ui.finish()
        elif choice == "3":
            download_firmware_menu(ui)
        elif choice == "4":
            ui.start()
            print("Downloading other flashing tools...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "5":
            ui.start()
            print("Searching for firmware version based on phone model...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "6":
            ui.start()
            print("Selecting from a list of all models available...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "7":
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main_menu()