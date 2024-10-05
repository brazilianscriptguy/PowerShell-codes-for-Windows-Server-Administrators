# 🔵 BlueTeam Tools - Threat Hunting

## 📝 Overview

This subfolder contains scripts aimed at **threat hunting** and the removal of potential security risks within a network. The scripts automate the purging of expired certificates, cleanup of non-compliant software, and the removal of unauthorized shared folders and drives, helping administrators ensure that the network environment is secure and compliant.

## 🛠️ Prerequisites

Before using these scripts, ensure the following:

- ⚙️ **PowerShell** is enabled on your system.
- 🔑 Administrative privileges are required to execute these scripts.
- 🖥️ **Group Policy (GPO)** should be properly configured if using GPO-based scripts.

## 📄 Script Descriptions

1. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**
   - This script focuses on the explicit removal of expired Certificate Authorities (CAs), ensuring that outdated and insecure certificates are removed from the environment to prevent potential security risks.

2. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**
   - Automates the removal of expired Certificate Authorities using Group Policy, ensuring that the certificate infrastructure is secure and compliant across multiple machines within the domain.

3. **🗑️ Purge-ExpiredCERTs-Repository.ps1**
   - Detects and purges expired certificates from the certificate repository, keeping the system’s certificate infrastructure up to date and secure.

4. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**
   - Automates the removal of unauthorized shared folders and drives via Group Policy, ensuring that shared resources comply with organizational policies and eliminating potential vectors for data leakage.

5. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**
   - Removes non-compliant or unauthorized software from machines via Group Policy, helping to enforce software compliance and mitigate potential vulnerabilities associated with unauthorized software.

## 🚀 How to Use

Each script is designed to simplify the process of securing your environment:

1. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   - Run this script with administrative privileges to explicitly remove expired Certificate Authorities. This is particularly useful for environments where you need to selectively purge CAs that have outlived their validity.

2. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   - Use this script to automate the removal of expired CAs across your network using Group Policy. Deploy it through your GPO settings for efficient and widespread certificate management.

3. **🗑️ Purge-ExpiredCERTs-Repository.ps1**  
   - Execute this script to clean up your certificate repository by purging expired certificates, ensuring your environment only holds valid and secure certificates.

4. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   - Run this script to remove unauthorized shared folders and drives from workstations via GPO. It ensures compliance with data-sharing policies and reduces security risks associated with unauthorized shared resources.

5. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - Use this script to silently remove non-compliant or unauthorized software via GPO, enforcing compliance and reducing vulnerabilities from unauthorized software installations.

## 📝 Logging and Output

- Each script logs actions in `.LOG` format and outputs results in `.CSV` files, providing detailed documentation for auditing and ensuring compliance tracking during threat hunting operations.
