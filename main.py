# main.py
from user_interface import display_welcome_message, select_option
from install_drivers import install_required_drivers
from detect_device import detect_device
from install_firmware import install_firmware
from backup_restore import do_backup, do_restore

def main():
    display_welcome_message()

    # Install drivers
    install_required_drivers()

    # Device detection logic
    device = detect_device()

    while True:
        # Display options to the user
        selected_option = select_option()

        if selected_option == 1:
            # Firmware installation logic
            install_firmware(device)
        elif selected_option == 2:
            # Firmware backup logic
            do_backup(device)
        elif selected_option == 3:
            # Firmware restore logic
            do_restore(device)
        elif selected_option == 4:
            # Quit the program
            print("Quitting FlashWizard.")
            break
        else:
            print("Invalid option. Please choose a valid option.")

if __name__ == "__main__":
    main()
