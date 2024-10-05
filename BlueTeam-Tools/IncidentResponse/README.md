# 🔵 BlueTeam Tools - Incident Response

## 📝 Overview

This subfolder contains scripts designed for **incident response** activities, particularly in **Active Directory (AD)** environments. These tools assist administrators in handling security incidents by effectively cleaning up environments and managing files.

## 🛠️ Prerequisites

To run these scripts, ensure the following:

- **PowerShell** is enabled, and the **Active Directory** module is imported, if necessary.
- **Administrative privileges** may be required for some operations.
- **Remote Server Administration Tools (RSAT)** should be installed on your Windows workstation for remote Windows Server administration.

## 📄 Script Descriptions

1. **🧹 Cleanup-MetadData-ADForest-Tool.ps1**  
   A user-friendly tool designed to clean up your AD forest by removing orphaned objects, synchronizing Domain Controllers, and managing unnecessary CNs. This script helps maintain a secure and optimized AD environment after incidents.

2. **🧼 Cleanup-WebBrowser-Tool.ps1**  
   Thoroughly removes cookies, cache, session data, and other residual files from web browsers (Mozilla Firefox, Google Chrome, Microsoft Edge, Internet Explorer), WhatsApp, and performs general system cleanup tasks across all user profiles on a Windows system.

3. **🗑️ Delete-FilesByExtension-Bulk.ps1**  
   A powerful script for bulk deleting files based on their extensions, helping to remove unwanted or potentially harmful files during post-incident cleanup.

4. **📑 Delete-FilesByExtension-Bulk.txt**  
   A supporting text file used to specify the extensions for the **Delete-FilesByExtension-Bulk.ps1** script. Administrators can customize this file to target specific file types for deletion.

## 🚀 How to Use

1. **🧹 Cleanup-MetadData-ADForest-Tool.ps1**  
   - Run the script with administrative privileges to clean up your AD forest. A GUI will guide you through options for synchronization, object cleanup, and CN management.

2. **🧼 Cleanup-WebBrowser-Tool.ps1**  
   - Execute this script to clean up web browsers, removing residual data like cookies and cache, ensuring a comprehensive system cleanup.

3. **🗑️ Delete-FilesByExtension-Bulk.ps1**  
   - Use this script to delete files by their extensions. Update the `Delete-FilesByExtension-Bulk.txt` file to specify the file types you want to remove. The script will then handle the bulk deletion.

## 📝 Logging and Output

Each script generates logs in `.LOG` format and outputs results in `.CSV` files, providing detailed records of the actions taken, which can be used for post-incident documentation.
