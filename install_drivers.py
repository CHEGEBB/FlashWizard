import os
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QLabel, QDesktopWidget, QGridLayout, \
    QMessageBox, QPlainTextEdit, QDialog
from subprocess import Popen, PIPE
import webbrowser

class DriverInstallerUI(QWidget):
    def __init__(self):
        super().__init__()

        self.selected_drivers = []

        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Driver Installer')
        self.setGeometry(100, 100, 600, 400)
        self.center_on_screen()

        layout = QVBoxLayout()

        drivers = {
            "ADB": "https://androidmtk.com/download-universal-adb-driver",
            "Fastboot": "https://www.flashtool.org/android/drivers-fastbootadb/",
            "MediaTek": "https://www.hovatek.com/forum/thread-16640.html",
            "Google USB": "https://developer.android.com/studio/run/win-usb",
        }

        grid_layout = QGridLayout()

        row = 0
        for driver, url in drivers.items():
            label = QLabel(f"Download {driver} Driver:")
            grid_layout.addWidget(label, row, 0)
            driver_button = QPushButton(f"Download {driver} Driver", self)
            driver_button.clicked.connect(lambda _, driver=driver: self.download_driver(driver, drivers[driver]))
            grid_layout.addWidget(driver_button, row, 1)
            row += 1

        how_to_install_button = QPushButton("How to Install", self)
        how_to_install_button.clicked.connect(self.display_how_to_install)
        layout.addLayout(grid_layout)
        layout.addWidget(how_to_install_button)

        created_by_label = QLabel("Created by: CHEGEBB")
        layout.addWidget(created_by_label)

        self.setLayout(layout)

    def center_on_screen(self):
        screen = QDesktopWidget().screenGeometry()
        widget = self.geometry()
        x = (screen.width() - widget.width()) // 2
        y = (screen.height() - widget.height()) // 2
        self.move(x, y)

    def download_driver(self, driver, url):
        webbrowser.open(url)

    def display_how_to_install(self):
        # Assuming you have a text file named "how_to_install.txt" in the same directory as this script
        file_path = os.path.join(os.path.dirname(__file__), "how_to_install.txt")
        
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read()

            how_to_install_dialog = QDialog(self)
            how_to_install_dialog.setWindowTitle("How to Install Drivers")
            how_to_install_dialog.setGeometry(100, 100, 600, 400)

            text_edit = QPlainTextEdit(how_to_install_dialog)
            text_edit.setPlainText(content)
            text_edit.setReadOnly(True)

            layout = QVBoxLayout()
            layout.addWidget(text_edit)
            how_to_install_dialog.setLayout(layout)

            how_to_install_dialog.exec_()
        except FileNotFoundError:
            QMessageBox.critical(self, "File Not Found", f"Could not find {file_path}")

if __name__ == '__main__':
    app = QApplication([])
    window = DriverInstallerUI()
    window.show()
    app.exec_()
