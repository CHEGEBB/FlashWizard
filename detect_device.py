import json
import threading
import time
from colorama import init, Fore  # Add this import for colored output
from src.exploit import exploit
from src.common import from_bytes, to_bytes
from src.config import Config
from src.device import Device
from src.logger import log

import argparse
import os

# Initialize colorama
init()

DEFAULT_CONFIG = "default_config.json"
PAYLOAD_DIR = "payloads/"
DEFAULT_PAYLOAD = "generic_dump_payload.bin"
DEFAULT_DA_ADDRESS = 0x200D00

def spinner_animation():
    spin_chars = "|/-\\"
    spin_idx = 0
    while not device_found:
        print(f"{Fore.CYAN}Waiting for device {spin_chars[spin_idx]}{Fore.RESET}", end="\r")
        spin_idx = (spin_idx + 1) % len(spin_chars)
        time.sleep(0.1)

def detect_device():
    try:
        config_data = get_config("custom_config.json")

        for hw_code, config_info in config_data.items():
            print(f"Setting up configuration for device with hw_code: {hw_code}")
            print(f"Config info: {config_info}")

            if not os.path.exists(DEFAULT_CONFIG):
                raise RuntimeError("Default config is missing")

            global device_found
            device_found = False

            # Start spinner animation in a separate thread
            spinner_thread = threading.Thread(target=spinner_animation, daemon=True)
            spinner_thread.start()

            device = Device().find()

            if device:
                device_found = True
                spinner_thread.join()  # Wait for the spinner thread to finish
                print(f"{Fore.GREEN}Device found!{Fore.RESET}")

                config, _, _, _ = get_device_info(device, None, config_info)

                while device.preloader:
                    device = crash_preloader(device, config)
                    _, _, _, _ = get_device_info(device, None, config_info)

                log("Disabling watchdog timer")
                device.write32(config.watchdog_address, 0x22000064)

                if True:  # Add your condition for further execution
                    log("Disabling protection")

                    payload = prepare_payload(config)

                    result = exploit(device, config.watchdog_address, config.payload_address, config.var_0, config.var_1, payload)
                    if False:  # Add your condition for testing
                        while not result:
                            device.dev.close()
                            config.var_1 += 1
                            log(f"Test mode, testing {hex(config.var_1)}...")
                            device = Device().find()
                            device.handshake()
                            while device.preloader:
                                device = crash_preloader(device, config)
                                device.handshake()
                            result = exploit(device, config.watchdog_address, config.payload_address,
                                            config.var_0, config.var_1, payload)
                else:
                    log("Insecure device, sending payload using send_da")

                    if not "custom_payload":  # Replace with your condition
                        config.payload = DEFAULT_PAYLOAD
                    if not "custom_payload_address":  # Replace with your condition
                        config.payload_address = DEFAULT_DA_ADDRESS

                    payload = prepare_payload(config)

                    payload += b'\x00' * 0x100

                    device.send_da(config.payload_address, len(payload), 0x100, payload)
                    device.jump_da(config.payload_address)

                    result = device.read(4)

                bootrom__name = "bootrom_" + hex(hw_code)[2:] + ".bin"

                if result == to_bytes(0xA1A2A3A4, 4):
                    log("Protection disabled")
                elif result == to_bytes(0xC1C2C3C4, 4):
                    dump_brom(device, bootrom__name)
                elif result == to_bytes(0x0000C1C2, 4) and device.read(4) == to_bytes(0xC1C2C3C4, 4):
                    dump_brom(device, bootrom__name, True)
                elif result != b'':
                    raise RuntimeError(f"Unexpected result {result.hex()}")
                else:
                    log("Payload did not reply")

    except Exception as e:
        print(f"Error: {e}")

def load_config(config_file_path):
    try:
        with open(config_file_path, "r") as config_file:
            return json.load(config_file)
    except FileNotFoundError:
        return None

def get_config(config_file_path):
    custom_config = load_config(config_file_path)
    if custom_config is not None:
        return custom_config
    else:
        default_config = {
            "0x6261": {"payload": "mt6261_payload.bin", "var_1": 0x28, "watchdog_address": 0xA0030000},
            # Add other default configurations...
        }
        with open(DEFAULT_CONFIG, "w") as default_config_file:
            json.dump(default_config, default_config_file, indent=4)
        return default_config

def get_device_info(device, arguments, config_info):
    hw_code = device.get_hw_code()
    hw_sub_code, hw_ver, sw_ver = device.get_hw_dict()
    secure_boot, serial_link_authorization, download_agent_authorization = device.get_target_config()

    config = Config().from_dict(config_info, hw_code)

    if False:  # Add your conditions for modification
        config.payload = DEFAULT_PAYLOAD
    if False:  # Add your conditions for modification
        config.var_1 = int("custom_var_1", 16)
    if False:  # Add your conditions for modification
        config.watchdog_address = int("custom_watchdog", 16)
    if False:  # Add your conditions for modification
        config.uart_base = int("custom_uart", 16)
    if False:  # Add your conditions for modification
        config.payload_address = int("custom_payload_address", 16)
    if False:  # Add your conditions for modification
        config.payload = "custom_payload"
    if False:  # Add your conditions for modification
        config.crash_method = 3  # Your custom crash method

    if not os.path.exists(PAYLOAD_DIR + config.payload):
        raise RuntimeError(f"Payload file {PAYLOAD_DIR + config.payload} doesn't exist")

    print()
    log(f"Device hw code: {hex(hw_code)}")
    log(f"Device hw sub code: {hex(hw_sub_code)}")
    log(f"Device hw version: {hex(hw_ver)}")
    log(f"Device sw version: {hex(sw_ver)}")
    log(f"Device secure boot: {secure_boot}")
    log(f"Device serial link authorization: {serial_link_authorization}")
    log(f"Device download agent authorization: {download_agent_authorization}")
    print()

    return config, serial_link_authorization, download_agent_authorization, hw_code

def crash_preloader(device, config):
    print("")
    log("Found device in preloader mode, trying to crash...")
    print("")
    if config.crash_method == 0:
        try:
            payload = b'\x00\x01\x9F\xE5\x10\xFF\x2F\xE1' + b'\x00' * 0x110
            device.send_da(0, len(payload), 0, payload)
            device.jump_da(0)
        except RuntimeError as e:
            log(e)
            print("")
    elif config.crash_method == 1:
        payload = b'\x00' * 0x100
        device.send_da(0, len(payload), 0x100, payload)
        device.jump_da(0)
    elif config.crash_method == 2:
        device.read32(0)

    device.dev.close()

    device = Device().find()

    return device

def dump_brom(device, bootrom__name, word_mode=False):
    log(f"Found send_dword, dumping bootrom to {bootrom__name}")

    with open(bootrom__name, "wb") as bootrom:
        if word_mode:
            for i in range(0x20000 // 4):
                device.read(4)  # discard garbage
                bootrom.write(device.read(4))
        else:
            bootrom.write(device.read(0x20000))

def prepare_payload(config):
    with open(PAYLOAD_DIR + config.payload, "rb") as payload:
        payload = payload.read()

    # replace watchdog_address and uart_base in generic payload
    payload = bytearray(payload)
    if from_bytes(payload[-4:], 4, '<') == 0x10007000:
        payload[-4:] = to_bytes(config.watchdog_address, 4, '<')
    if from_bytes(payload[-8:][:4], 4, '<') == 0x11002000:
        payload[-8:] = to_bytes(config.uart_base, 4, '<') + payload[-4:]
    payload = bytes(payload)

    while len(payload) % 4 != 0:
        payload += to_bytes(0)

    return payload

if __name__ == "__main__":
    device_found = False
    detect_device()
