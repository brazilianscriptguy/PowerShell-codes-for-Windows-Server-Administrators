# 🔵 BlueTeam Tools - Malicious Process Detection

## 📝 Overview

This folder contains scripts designed to assist with the detection and removal of **malicious processes** and applications in Windows environments. These tools help administrators efficiently uninstall suspicious or unwanted applications, safeguarding system integrity and security.

## 🛠️ Prerequisites

To use these scripts effectively, ensure the following:

- **PowerShell** is enabled on your system.
- **Administrative privileges** are required to uninstall applications.
- The **name of the application** to be uninstalled is known and correctly identified.

## 📄 Script Descriptions

1. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   Removes non-compliant or unauthorized software from machines via Group Policy, enforcing software compliance and reducing vulnerabilities associated with unauthorized applications.

2. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   Provides a GUI for selecting and uninstalling applications from workstations. It is particularly useful for detecting and removing unwanted or potentially malicious software. The script automates the uninstallation process, reducing manual intervention and ensuring efficient removal.

## 🚀 How to Use

1. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   Use this script to silently remove non-compliant or unauthorized software via GPO, helping to enforce compliance and reduce vulnerabilities from unauthorized applications.

2. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - Run the script with administrative privileges to open the GUI.
   - Select the application(s) you want to uninstall from the displayed list.
   - Confirm the action to proceed with the uninstallation.
   - The script will log the results, detailing the applications that were successfully removed.

## 📝 Logging and Output

- Both scripts generate logs in `.LOG` format, documenting the actions taken.
- These logs can be used for auditing purposes and further analysis of system changes after uninstallation.
