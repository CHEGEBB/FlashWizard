import os
import time
import subprocess

def start():
    print("Starting firmware installation...")

def finish():
    print("Firmware installation completed.")

def display_banner():
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

def download_firmware_menu():
    choices = {
        "1": "All Firmware Versions",
        "2": "Download Firmware",
        "3": "Install Firmware",
        "4": "Go Back",
    }

    while True:
        display_banner()
        print("\033[96mDownload Firmware Menu:\033[0m")
        for key, value in sorted(choices.items()):
            print(f"\033[92m{key}. {value}\033[0m")

        choice = input("\033[95mSelect an option: \033[0m")

        if choice == "1":
            start()
            print("Displaying all firmware versions...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "2":
            start()
            print("Downloading firmware...")

            # Construct the absolute path for install_firmware.py
            script_directory = os.path.dirname(os.path.abspath(__file__))
            install_firmware_path = os.path.join(script_directory, "scripts", "install_firmware.py")

            # Replace 'python' with the appropriate command to run the install_firmware.py script
            subprocess.run(["python", install_firmware_path])
        elif choice == "3":
            start()
            print("Installing firmware...")

            # Construct the absolute path for install_firmware.py
            script_directory = os.path.dirname(os.path.abspath(__file__))
            install_firmware_path = os.path.join(script_directory, "scripts", "install_firmware.py")

            # Replace 'python' with the appropriate command to run the install_firmware.py script
            subprocess.run(["python", install_firmware_path])
            finish()
        elif choice == "4":
            break
        else:
            print("Invalid choice. Please try again.")

def main_menu():
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
            start()
            
            # Run the driver installation logic
            subprocess.run(["python", "install_drivers.py"])

            finish()
        elif choice == "2":
            start()
            print("Detecting device...")
            time.sleep(1)  # Add a delay for animation effect

            # Run detect_device.py script
            subprocess.run(["python", os.path.join("scripts", "detect_device.py")])

            finish()
        elif choice == "3":
            download_firmware_menu()
        elif choice == "4":
            start()
            print("Downloading other flashing tools...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "5":
            start()
            print("Searching for firmware version based on phone model...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "6":
            start()
            print("Selecting from a list of all models available...")
            time.sleep(1)  # Add a delay for animation effect
        elif choice == "7":
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main_menu()
