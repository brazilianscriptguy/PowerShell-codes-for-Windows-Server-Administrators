# 🔵 BlueTeam Tools - Incident Response

## 📝 Overview

This subfolder contains scripts focused on **incident response** activities, particularly related to Active Directory (AD) environments. These tools aid administrators in handling security incidents by cleaning up environments and managing files effectively.

## 🛠️ Prerequisites

To run these scripts, ensure the following:

- ⚙️ You have **PowerShell** enabled and the **Active Directory** module imported (if necessary).
- 🔑 Administrative privileges may be required for some operations.
- 🖥️ **Remote Server Administration Tools (RSAT)** should be installed on your Windows workstation to administer Windows Server functions remotely.

## 📄 Script Descriptions

1. **🧹 Cleanup-ADForest-Tool.ps1**
   - A user-friendly tool designed to clean up your AD forest by removing orphaned objects, synchronizing Domain Controllers, and managing unnecessary CNs. This script helps maintain a secure and optimized AD environment after incidents.

2. **🗑️ Delete-FilesByExtension-Bulk.ps1**
   - A powerful script for bulk deleting files based on their extensions, helping to remove unwanted or potentially harmful files during a post-incident cleanup.

3. **📑 Delete-FilesByExtension-Bulk.txt**
   - A supporting text file used to specify the extensions for the **Delete-FilesByExtension-Bulk.ps1** script. Administrators can customize this file to target specific file types for deletion.

## 🚀 How to Use

1. **🧹 Cleanup-ADForest-Tool.ps1**
   - Execute the script with administrative privileges to start cleaning up your AD forest. A GUI will guide you through the process of selecting options for synchronization, object cleanup, and CN management.

2. **🗑️ Delete-FilesByExtension-Bulk.ps1**
   - Use this script to delete files by their extensions. Update the `Delete-FilesByExtension-Bulk.txt` file to include the file types you wish to remove. Run the script, and it will handle the deletion process in bulk.

## 📝 Logging and Output

Each script generates logs in `.LOG` format and outputs results in `.CSV` files, providing detailed insights into actions taken and helping with post-incident documentation.
