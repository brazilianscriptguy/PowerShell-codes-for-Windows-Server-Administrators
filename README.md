# PowerShell codes for Windows Server Administrators
Essential scripts and tools meticulously crafted to empower Windows Server Administrators.

## Description

Welcome to the PowerShell Codes for Windows Server Administrators repository, curated by `@brazilianscriptguy`. This repository serves as a treasure trove of PowerShell scripts and tools, each meticulously engineered to streamline the workload of Windows Server administrators. These scripts, ranging from security management to system optimization, embody precision and user-friendliness, ensuring that administrative tasks are both simplified and effective.

Delve into the repository and discover a realm where each script not only addresses specific administrative challenges but also introduces a level of efficiency and clarity that transforms routine tasks into seamless operations. Every tool here is a testament to the power of well-crafted scripting, designed to elevate the standards of server administration.

## Features 
Within this repository, you will find several distinct folders. Please select a folder of your interest and, as a first step, refer to the README.md file located in it main directory. This file contains detailed information about the functions available as well as any requirements necessary for their use.

# Files into AD-AdminTools folder
## Prerequisite:
To effectively utilize the scripts in this folder, it's crucial to have the capability to run PowerShell scripts (.PS1) that incorporate the `Import-Module ActiveDirectory` feature, especially on Windows 10 workstations. For this purpose, the installation of the Remote Server Administration Tools (RSAT) is required. 

1. **Change-Users-Pass-to-DefaultPass.ps1**: Tailored for Active Directory environments, this script efficiently resets passwords for a large number of users within a specific Organizational Unit (OU). It facilitates bulk password changes, enforcing a uniform default password for all users in the OU, making it highly beneficial in scenarios like post-migration processes or when implementing new password policies.

2. **Create-Default-OUs-into-AD-Structure.ps1**: This script simplifies the creation of standard Organizational Units (OUs) such as "Computers," "Users," "Groups," and "Printers" within Active Directory. It's particularly useful for setting up new domains or reorganizing existing structures, ensuring a well-structured and organized AD setup.

3. **Domain-Computers-Report.ps1**: This script is designed to compile a detailed report of all computers within a specified Active Directory domain. It's a handy tool for administrators to have a comprehensive overview of all machines, including domain controllers, in the domain.

4. **Eventlogs-Create-New-Paths-SERVERS.ps1**: Aimed at optimizing the management of Event Log files on Windows Servers, this script aids in efficiently reorganizing, moving, and resizing Event Log files and folders.

5. **Force-AD-Password-Expires.ps1**: This script is an essential security tool in Active Directory environments, as it enforces the expiration of user passwords within a designated OU. It sets the `ChangePasswordAtLogon` property to true, ensuring users are prompted to change their passwords at their next login.

6. **GUID-Installed-Softwares.ps1**: An auditing script that generates a detailed list of all software installed on Windows systems, including their Global Unique Identifiers (GUIDs). The output is organized into a CSV file for easy access and documentation.

7. **Inactive-Computer-Accounts.ps1**: This PowerShell script identifies and reports inactive computer accounts in an Active Directory domain. It's useful for maintaining a clean and updated AD environment by highlighting potentially obsolete computer accounts.

8. **Lastlogon-UserAccounts-Report.ps1**: This script generates a report of user accounts in Active Directory based on their last logon activity. It's a valuable tool for identifying inactive user accounts and ensuring efficient user management in AD.

9. **List-Users-Passwors-Never-Expires.ps1**: Focused on security auditing, this script extracts a list of users in Active Directory whose passwords are set to never expire, allowing administrators to enforce better password policies.

10. **Member-Servers-Forest-Report.ps1**: This script aids administrators in identifying and documenting member servers within a specified Active Directory domain. It outputs crucial information about these servers in a CSV format, aiding in AD management and documentation.

11. **Move-Computers-between-OUs.ps1**: An essential script for Active Directory administrators, it enables the efficient movement of computer accounts between different Organizational Units within the same domain.

12. **Multiple-RDP-Access.ps1**: Enhances remote management capabilities by allowing administrators to initiate Remote Desktop Protocol (RDP) sessions to multiple servers simultaneously, streamlining remote access and server management.

13. **Retrieve-ADGroups-and-Members.ps1**: This script provides a user-friendly interface for retrieving and documenting Active Directory group information, making it easier for administrators to manage and audit AD groups.

14. **Unlock-User-SMB-Share.ps1**: A practical tool for network and system administrators, this script aids in managing Shared Folder (SMB Share) access. It helps in quickly resolving user access issues, ensuring smooth operation in shared network environments.

15. **Winget-Upgrade-Install-by-GPOs.ps1**: Designed for Group Policy Object (GPO) implementations, this script automates software updates across multiple systems using `winget`, with detailed logging for each action.

16. **Winget-Upgrade-Install-Explicit.ps1**: Offers an interactive way to update software on Windows OS using `winget`. The script's progress bar and detailed logging make it a user-friendly tool for explicit software updates.

17. **NEXT COMING SOON**: Anticipate more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

# Files into Eventlogs-Tools folder
## Prerequisite:
Before using the scripts in this folder, ensure that the Microsoft Log Parser utility is installed in your environment.

## Description:
This folder contains scripts specifically designed for selecting and processing Windows Event Log files (*.evtx). They focus on extracting particular information from these logs and then outputting the results in an easy-to-analyze CSV file format.

1. **Count-All-Events-from-EVTX-file.ps1**: This script allows users to select an EVTX (Event Log) file and counts the occurrences of each EventID within that file. It exports the results to a CSV file in the user's Documents folder, making it easier to understand the event counts. This script is helpful for analyzing and summarizing event logs for troubleshooting or auditing purposes.

2. **EventID-307-PrintAudit.ps1**: This script expertly extracts information from the Microsoft-Windows-PrintService/Operational Event Log (EVTX file), focusing on Event ID 307. It captures detailed data about print job activities, including printer usage, page counts, and job sizes. As an indispensable tool for audit and oversight, it offers deep insights into print management and operational efficiency within your environment.

3. **EventID-4624-Logon-via-RDP.ps1**: Designed to scrutinize Windows Security Event Logs, this script zeroes in on Event ID 4624 to elucidate Remote Desktop Protocol (RDP) logon activities. It deftly gathers and organizes essential data about each RDP session, delivering a concise and informative CSV report. This script is ideal for administrators needing to monitor remote access, ensure compliance, and maintain security across their network.

4. **EventID-4625-Logon-account-failed.ps1**: Specializing in analyzing failed logon attempts (Event ID 4625) from Windows Security Event Logs, this script adeptly filters and documents each failed attempt. By translating these logs into an informative CSV file, it offers a panoramic view of security incidents, making it an essential tool for identifying potential breaches, strengthening security measures, and understanding user behavior patterns.

5. **EventID-4648-Logon-using-explicit-credentials.ps1**: Focused on Event ID 4648 in Windows Security Event Logs, this script is adept at identifying and reporting logon activities involving explicit credentials. It systematically compiles information about the user, domain, and source IP into an organized CSV report. This script is invaluable for tracking explicit credential usage, bolstering security, and detecting unusual or unauthorized access patterns.
   
6. **EventID-4660-and-4663-Object-deletion-tracking-actions.ps1**: This script is specifically engineered to track and analyze Events ID 4660 and 4663 in Windows Security Event Logs, which are pivotal for monitoring object deletion activities. It proficiently extracts and documents detailed information regarding these deletion events, including user accounts, domains, object types, and the specifics of the deleted objects. The extracted data is methodically organized into a CSV file, providing a comprehensive and easily interpretable record of object deletion incidents. This script is an essential tool for security and compliance auditing, as it aids in the investigation of data deletion activities and ensures that sensitive information is handled securely within the organization. It plays a critical role in understanding the context of deletions, aiding in identifying potential security breaches or policy violations.

7. **EventID-4771-Kerberos-Pre-Authentication-Failed.ps1**: This advanced script is dedicated to processing Event ID 4771 from Windows Security Event Logs, highlighting Kerberos pre-authentication failures. By capturing and reporting these failures, it serves as a critical tool for uncovering potential security threats, including brute force attacks and misuse of credentials. Its output, in a detailed CSV format, is an essential resource for security audits and proactive defense strategies.
   
8. **EventID-4800-and-4801-Workstation-Locked-and-Unlocked.ps1**: This script is meticulously designed to analyze Windows Security Event Logs for Event IDs 4800 and 4801, which correspond to locking and unlocking of a workstation. It adeptly extracts and organizes key information about these security-related events, including user accounts involved, event times, and workstation IPs. The data is then presented in a structured CSV file, offering a clear view of workstation access patterns. This script is particularly valuable for security monitoring, helping administrators track user activity and identify unusual access patterns, thereby contributing to the overall security management and compliance within the organization.

9. **EventID-6008-System-shutsdown-unexpectedly.ps1**: This script is skillfully crafted to monitor and analyze Event ID 6008 in Windows Event Logs, which indicates an unexpected system shutdown. It proficiently aggregates the occurrences of these events, providing insights into the frequency and patterns of unexpected shutdowns. The script outputs the data into a clearly formatted CSV file, including the number of occurrences and relevant event details. This is an invaluable tool for system administrators and IT professionals to diagnose potential system instability, identify underlying issues, and enhance overall system reliability. The script's ability to automatically open the generated report for immediate review makes it highly user-friendly and efficient for rapid analysis and response to critical system events.
   
10. **NEXT COMING SOON**

## Customizations

This repository is designed with customizability in mind, allowing you to tailor scripts to your specific needs. Below are some common customizations:

### Configuration Files

You can fine-tune the behavior of these scripts by modifying the included configuration files. These files typically contain settings and parameters that control script execution, ensuring they align perfectly with your server environment.

### Script Parameters

Many scripts come with adjustable parameters, allowing you to further customize their functionality. By tweaking these settings, you can tailor the scripts to suit different scenarios and specific needs. Should you encounter any inconsistencies or require adjustments, please feel free to reach out to me for assistance.

## Getting Started
Download your first Windows Server Administration tool for PowerShell and let's start managing like pros!

### Prerequisites

To utilize the scripts in this repository, ensure you have the following prerequisites:

- **Operating System**: Suitable for all Windows Server versions after 2016 Standard.
- **PowerShell Version**: PowerShell 7.3 or later.

#### Additional Setup for Windows 10 Workstations

To run PowerShell scripts (.PS1) that use the `Import-Module ActiveDirectory` functionality on Windows 10 workstations, you need to install the Remote Server Administration Tools (RSAT). RSAT includes the Active Directory module and allows you to manage Windows Server roles and features from a Windows 10 PC.

**Steps to Install RSAT on Windows 10:**

1. **Open Settings**: Access 'Settings' on your Windows 10 computer.
2. **Apps & Features**: Navigate to 'Apps' and then select 'Optional Features'.
3. **Add a Feature**: Click on 'Add a feature'.
4. **Search for RSAT**: Type "RSAT" in the search bar to display all available RSAT tools.
5. **Select and Install**: Specifically, look for and install the following tools:
    - RSAT: Active Directory Domain Services and Lightweight Directory Tools
    - RSAT: DNS Server Tools (if managing DNS)
    - RSAT: Group Policy Management Tools (if managing group policies)
6. **Install**: Choose these tools and click 'Install'.

After installing these tools, you will be able to run scripts that require the Active Directory module using the 'Import-Module ActiveDirectory' command in PowerShell. This setup enables you to perform Active Directory tasks directly from your Windows 10 workstation.

**Note**: Ensure that your user account has the appropriate permissions to manage Active Directory objects. Additionally, your PC must be part of the domain or have network access to the domain controllers.

### Installation

Installing these scripts is a breeze. Follow these steps to get started:

1. Clone the repository to your desired location:

   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git

2. Save the scripts to your preferred directory.

3. Execute the scripts while monitoring the location and environment to ensure proper execution.

Now, you're all set to leverage the power of these PowerShell scripts for efficient Windows Server administration. Feel free to explore and customize them to suit your specific needs.

For questions or further assistance, you can reach out to me at luizhamilton.lhr@gmail.com or join my WhatsApp channel: [WhatsApp Channel](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c).
