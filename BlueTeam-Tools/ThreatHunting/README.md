# 🔵 BlueTeam Tools - Threat Hunting

## 📝 Overview

This folder contains a collection of PowerShell scripts designed for **threat hunting** and removing potential security risks within a Windows network. These scripts automate critical tasks such as purging expired certificates, cleaning up non-compliant software, and removing unauthorized shared folders and drives. They help administrators secure the network environment and maintain compliance with organizational policies.

## 🛠️ Prerequisites

Before using these scripts, ensure the following prerequisites are met:

- ⚙️ **PowerShell** is enabled on your system.
- 🔑 **Administrative privileges** are required to execute the scripts.
- 🖥️ **Group Policy (GPO)** must be properly configured for scripts that rely on GPO.

## 📄 Script Descriptions

1. **🔍 Decipher-EML-MailMessages.ps1**  
   - This script applies various decoding methods to suspicious characters in email messages, including offset subtraction, encoding conversions, ROT13, and Caesar cipher brute force. It helps in analyzing potentially harmful email content and identifying hidden threats.

2. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   - This script automates the selective removal of expired Certificate Authorities (CAs), ensuring outdated and insecure certificates are purged to reduce security risks.

3. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   - Removes expired CAs using Group Policy, enabling automated and consistent certificate management across multiple domain machines.

4. **🗑️ Purge-ExpiredCERTs-Repository.ps1**  
   - Detects and removes expired certificates from the certificate repository, maintaining an up-to-date and secure certificate infrastructure.

5. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   - Automates the removal of unauthorized shared folders and drives via Group Policy, helping ensure compliance with data-sharing policies and mitigating the risk of data leaks.

## 🚀 How to Use

Follow the steps below to use each script effectively:

### 1. **🔍 Decipher-EML-MailMessages.ps1**  
   - **Step 1:** Run the script with administrative privileges.
   - **Step 2:** Specify the email message or suspicious string to analyze. The script will apply decoding methods such as offset subtraction, encoding conversions, ROT13, and Caesar cipher brute force.
   - **Step 3:** Review the output, which displays the decoded results in a readable format. This can help uncover potentially malicious content within the email.
   - **Step 4:** The script generates logs that document the decoding process and results, which can be used for further analysis.

### 2. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   - **Step 1:** Run this script with administrative privileges.
   - **Step 2:** The script will identify and remove expired Certificate Authorities (CAs) from your system, selectively purging outdated and insecure certificates.
   - **Step 3:** Check the logs for details on which CAs were removed and any errors encountered during the process.

### 3. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   - **Step 1:** Ensure Group Policy (GPO) is properly configured.
   - **Step 2:** Run the script to automatically remove expired CAs across domain machines via GPO.
   - **Step 3:** The script will log all actions, providing a comprehensive record of removed certificates and ensuring consistency across your network.

### 4. **🗑️ Purge-ExpiredCERTs-Repository.ps1**  
   - **Step 1:** Run the script with administrative privileges.
   - **Step 2:** The script scans the certificate repository, identifying and removing expired certificates to keep your environment secure.
   - **Step 3:** Logs will be generated, detailing the certificates that were removed and documenting any issues.

### 5. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   - **Step 1:** Ensure Group Policy (GPO) is configured correctly.
   - **Step 2:** Run the script to remove unauthorized shared folders and drives across your network.
   - **Step 3:** The script will log all actions taken and provide a detailed record of shared folders and drives removed, helping maintain compliance with your organization’s data-sharing policies.

## 📝 Logging and Output

- **Log Format**: Each script generates logs in `.LOG` format, providing a detailed record of actions taken and any errors encountered during execution.
- **Output**: Some scripts also output results in `.CSV` files for easy auditing and reporting. These logs and outputs help ensure compliance and provide a trail for further investigation during threat hunting operations.
