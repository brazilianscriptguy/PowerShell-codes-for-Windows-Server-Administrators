# 🔵 BlueTeam Tools - Malicious Process Detection

## 📝 Overview

This folder contains scripts designed to assist with the detection and removal of **malicious processes** and unwanted applications in Windows environments. These tools enable administrators to efficiently uninstall suspicious or unauthorized software, ensuring system integrity and security.

## 🛠️ Prerequisites

To use these scripts effectively, ensure the following:

- ⚙️ **PowerShell** is enabled on your system.
- 🔑 **Administrative privileges** are required to uninstall applications.
- 🖥️ The **name of the application** to be uninstalled is identified and correct.

## 📄 Script Descriptions

1. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   This script uninstalls multiple software applications based on a list of software names provided in a `.TXT` file. It logs all actions, handles errors gracefully, and allows users to execute, cancel, or close the uninstallation process seamlessly.
   
2. **📝 Softwares-NonCompliance-List.txt**  
   A supporting text file used by the **Remove-Softwares-NonCompliance-Tool.ps1** script, containing the list of software names to be uninstalled.

3. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   Removes non-compliant or unauthorized software from machines via Group Policy (GPO). This script enforces software compliance and reduces vulnerabilities by automatically uninstalling unauthorized applications.

4. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   This script provides a GUI for selecting and uninstalling applications from workstations. It is particularly useful for detecting and removing unwanted or malicious software. The process is automated, minimizing manual intervention and ensuring efficient removal.

## 🚀 How to Use

1. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   - Update the **📝 Remove-Softwares-NonCompliance.txt** file with the names of the software you wish to uninstall.
   - Run the script, and it will uninstall all specified applications, logging actions and handling errors during the process.

2. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - Use this script to silently remove non-compliant or unauthorized software via GPO, helping to enforce compliance and minimize security risks.

3. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - Run the script with administrative privileges to open the GUI.
   - Select the application(s) you wish to uninstall from the list.
   - Confirm the uninstallation, and the script will log the actions taken, detailing the successfully removed applications.

## 📝 Logging and Output

- 📄 Each script generates logs in `.LOG` format, documenting the actions taken during the uninstallation process.
- 📊 These logs are useful for auditing and further analysis of system changes after the uninstallation.
