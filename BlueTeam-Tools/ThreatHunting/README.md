# 🔵 BlueTeam Tools - Threat Hunting

## 📝 Overview

This subfolder contains scripts designed for **threat hunting** and the removal of potential security risks within a network. These scripts automate the purging of expired certificates, cleanup of non-compliant software, and removal of unauthorized shared folders and drives, helping administrators secure and maintain compliance across the network environment.

## 🛠️ Prerequisites

Before using these scripts, ensure the following:

- **PowerShell** is enabled on your system.
- **Administrative privileges** are required to execute the scripts.
- **Group Policy (GPO)** must be properly configured if using GPO-based scripts.

## 📄 Script Descriptions

1. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   Automates the removal of expired Certificate Authorities (CAs), ensuring that outdated and insecure certificates are removed to mitigate security risks.

2. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   Automates the removal of expired CAs using Group Policy, enabling consistent and secure certificate management across multiple domain machines.

3. **🗑️ Purge-ExpiredCERTs-Repository.ps1**  
   Detects and removes expired certificates from the certificate repository, maintaining an up-to-date and secure certificate infrastructure.

4. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   Automates the removal of unauthorized shared folders and drives via Group Policy, ensuring compliance with data-sharing policies and eliminating potential risks for data leakage.

5. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   Removes non-compliant or unauthorized software from machines via Group Policy, enforcing software compliance and reducing vulnerabilities associated with unauthorized applications.

## 🚀 How to Use

Each script is designed to streamline security management:

1. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   - Run this script with administrative privileges to explicitly remove expired Certificate Authorities. It’s useful for environments requiring selective certificate purges.

2. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   - Use this script to automate the removal of expired CAs via Group Policy. It ensures secure certificate management across your network through GPO deployment.

3. **🗑️ Purge-ExpiredCERTs-Repository.ps1**  
   - Execute this script to clean up your certificate repository by purging expired certificates, keeping your environment secure with valid certificates.

4. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   - Run this script to remove unauthorized shared folders and drives via GPO, ensuring compliance with organizational data-sharing policies and reducing security risks.

5. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - Use this script to silently remove non-compliant or unauthorized software via GPO, helping to enforce compliance and reduce vulnerabilities from unauthorized applications.

## 📝 Logging and Output

- Each script generates logs in `.LOG` format and outputs results in `.CSV` files, providing detailed records for auditing and ensuring compliance during threat hunting operations.
