# 🔵 BlueTeam Tools - Malicious Process Detection

## 📝 Overview

This folder contains scripts designed to help detect and remove **malicious processes** and unwanted applications in Windows environments. These tools allow administrators to efficiently uninstall suspicious or unauthorized software, ensuring system integrity and enhancing security.

## 🛠️ Prerequisites

To use these scripts effectively, ensure the following:

- ⚙️ **PowerShell** is enabled on your system.
- 🔑 **Administrative privileges** are required to uninstall applications.
- 🖥️ The **name of the application** to be uninstalled is correctly identified.

## 📄 Script Descriptions

1. **🔍 Decipher-EML-MailMessages.ps1**  
   - Applies multiple decoding methods to suspicious characters in email messages, including offset subtraction, encoding conversions, ROT13, and Caesar cipher brute force. This script helps in analyzing potentially harmful email content.

2. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   - Uninstalls multiple software applications based on a list of software names provided in a `.TXT` file. It logs all actions, handles errors gracefully, and allows users to execute, cancel, or close the uninstallation process with ease.

3. **📝 Softwares-NonCompliance-List.txt**  
   - A supporting text file used by the **Remove-Softwares-NonCompliance-Tool.ps1** script. It contains the names of the software applications to be uninstalled, ensuring only the specified apps are targeted.

4. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - Enforces software compliance by removing non-compliant or unauthorized software via Group Policy (GPO). This script helps reduce vulnerabilities by automatically uninstalling unauthorized applications across multiple machines.

5. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - Provides a user-friendly GUI for selecting and uninstalling applications from workstations. This tool is particularly useful for detecting and removing unwanted or malicious software. The process is automated, minimizing manual intervention and ensuring effective removal.

## 🚀 How to Use

### 1. **🔍 Decipher-EML-MailMessages.ps1**  
   - **Step 1:** Open the **Decipher-EML-MailMessages.ps1** script with administrative privileges.
   - **Step 2:** Specify the email message or suspicious string to be analyzed. The script will attempt multiple decoding methods (offset subtraction, encoding conversions, ROT13, Caesar cipher brute force) on the provided message.
   - **Step 3:** Review the output, which will display decoded results in a readable format. This helps to identify potential malicious content hidden within the message.
   - **Step 4:** Log files will be generated, documenting the decoding process and the results for further analysis.

### 2. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   - **Step 1:** Open the **📝 Softwares-NonCompliance-List.txt** file and list the names of the software you want to uninstall. Ensure each software name is on a separate line.
   - **Step 2:** Run the **Remove-Softwares-NonCompliance-Tool.ps1** script with administrative privileges.
   - **Step 3:** The script will automatically uninstall all the listed applications. It will log all actions performed and handle any errors encountered during the process.
   - **Step 4:** Review the generated log file for details on the uninstallation process and any errors that were handled.

### 3. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - **Step 1:** Prepare your GPO to deploy this script across multiple systems.
   - **Step 2:** Execute the **Remove-Softwares-NonCompliance-viaGPO.ps1** script to silently remove non-compliant or unauthorized software from target machines.
   - **Step 3:** The script will uninstall the specified software and log the results. Review the logs to confirm the uninstallation was successful and to ensure compliance across all systems.

### 4. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - **Step 1:** Run the **Uninstall-SelectedApp-Tool.ps1** script with administrative privileges.
   - **Step 2:** A graphical user interface (GUI) will appear, showing a list of installed applications on the system.
   - **Step 3:** Select the application(s) you want to uninstall from the list.
   - **Step 4:** Confirm the uninstallation. The script will proceed to uninstall the selected application(s) and log the actions taken, including any errors encountered.
   - **Step 5:** Review the log file for details about the uninstalled applications and any issues that were handled during the process.

## 📝 Logging and Output

- 📄 Each script generates detailed logs in `.LOG` format, documenting every step of the process, from decoding suspicious emails to uninstalling software.
- 📊 These logs are valuable for auditing, further analysis, and ensuring system integrity after actions have been performed.
