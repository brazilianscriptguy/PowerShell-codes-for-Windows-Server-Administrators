# 🔵 BlueTeam Tools - Malicious Process Detection

## 📝 Overview

This folder contains a script designed to assist with the detection and removal of **malicious processes** and applications in Windows environments. The **Uninstall-SelectedApp.ps1** script offers administrators an efficient way to uninstall suspicious or unwanted applications, helping to safeguard system integrity and security.

## 🛠️ Prerequisites

To use the script effectively, ensure the following:

- **PowerShell** is enabled on your system.
- **Administrative privileges** are required to uninstall applications.
- The **name of the application** to be uninstalled is known and correctly identified.

## 📄 Script Description

1. **🗑️ Uninstall-SelectedApp.ps1**  
   This script provides a GUI for selecting and uninstalling applications from workstations. It is particularly useful for detecting and removing unwanted or potentially malicious software. The script automates the uninstallation process, reducing manual intervention and ensuring efficient removal.

## 🚀 How to Use

1. **🗑️ Uninstall-SelectedApp.ps1**  
   - Run the script with administrative privileges to open the GUI.
   - Select the application(s) you want to uninstall from the displayed list.
   - Confirm the action to proceed with the uninstallation.
   - The script will log the results, detailing the applications that were successfully removed.

## 📝 Logging and Output

- The script generates logs in `.LOG` format, documenting the uninstalled applications.
- These logs can be used for auditing purposes and further analysis of system changes after the uninstallation.
