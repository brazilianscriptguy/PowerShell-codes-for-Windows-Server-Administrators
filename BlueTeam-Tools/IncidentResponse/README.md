# 🔵 BlueTeam-Tools - IncidentResponse Folder

## 📝 Overview

This subfolder contains scripts specifically designed for **incident response** activities within **Active Directory (AD)** environments. These tools assist administrators in effectively handling security incidents by cleaning up environments and managing files efficiently.

## 🛠️ Prerequisites

Before running these scripts, ensure the following prerequisites are met:

1. **PowerShell**
   - **Requirement:** PowerShell must be enabled.
   - **Module:** Import the **Active Directory** module if necessary.

2. **Administrator Privileges**
   - **Note:** Some operations require elevated permissions to access certain system information and perform administrative tasks.

3. **Remote Server Administration Tools (RSAT)**
   - **Installation:** Ensure RSAT is installed on your Windows 10/11 workstation to enable remote administration of Windows Servers.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

## 📄 Description

This subfolder includes a comprehensive suite of PowerShell scripts designed to streamline **Active Directory (AD)** and **Windows Server** environment management during incident response. These tools automate and simplify a wide range of administrative tasks involving AD objects such as users, groups, and organizational units (OUs), as well as managing server functions and configurations.

> **✨ Each script includes a graphical user interface (GUI) for enhanced user interaction. Scripts also generate `.log` files and export results to `.csv` files, streamlining server and workstation management processes.**

### 📜 Script Descriptions (Alphabetically Ordered)

1. **🧹 Cleanup-MetaData-ADForest-Tool.ps1**  
   - **Purpose:** Automates the cleanup of your AD forest by removing orphaned objects, synchronizing Domain Controllers, and managing unnecessary CNs. This script helps maintain a secure and optimized AD environment post-incident.

2. **🧼 Cleanup-WebBrowsers-Tool.ps1**  
   - **Purpose:** Removes cookies, cache, session data, history, and other residual files from web browsers (Mozilla Firefox, Google Chrome, Microsoft Edge, Internet Explorer) and WhatsApp. Additionally, it performs general system cleanup tasks across all user profiles on a Windows system.

3. **🗑️ Delete-FilesByExtension-Bulk.ps1**  
   - **Purpose:** Facilitates bulk deletion of files based on their extensions, aiding in the removal of unwanted or potentially harmful files during post-incident cleanup.

4. **📑 Delete-FilesByExtension-Bulk.txt**  
   - **Purpose:** A configuration text file used by the **Delete-FilesByExtension-Bulk.ps1** script to specify which file extensions should be targeted for deletion. Administrators can customize this file to define specific file types for removal.

## 🚀 How to Use

1. **🧹 Cleanup-MetaData-ADForest-Tool.ps1**  
   - **Instructions:** Run the script with administrative privileges to clean up your AD forest. A GUI will guide you through options for synchronization, object cleanup, and CN management.

2. **🧼 Cleanup-WebBrowsers-Tool.ps1**  
   - **Instructions:** Execute this script to clean up web browsers by removing residual data such as cookies and cache, ensuring a comprehensive system cleanup.

3. **🗑️ Delete-FilesByExtension-Bulk.ps1**  
   - **Instructions:** Use this script to delete files based on their extensions. First, update the `Delete-FilesByExtension-Bulk.txt` file to specify the file types you wish to remove. The script will then handle the bulk deletion process.

## 📝 Logging and Output

Each script generates logs in `.LOG` format and exports results in `.CSV` files, providing detailed records of the actions taken. These logs and reports facilitate easy analysis and documentation of administrative actions and outcomes.
