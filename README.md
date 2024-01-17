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

**ADComputers-MoveBetweenOUs.ps1**: This script is a crucial tool for Active Directory administrators, providing the functionality to seamlessly move computer accounts between different Organizational Units (OUs) within the same domain. It streamlines the process of organizing and reorganizing computer accounts, which is especially beneficial in dynamic environments where frequent updates to account placements are necessary.

**ADGroupsAndMembers-Retrieval.ps1**: This script offers a convenient and efficient way for administrators to retrieve and document Active Directory group information. It provides a user-friendly interface that simplifies the complexities of managing and auditing AD groups, making it an indispensable tool for administrators in maintaining the integrity and organization of group data in Active Directory.

**ADPassword-ForceExpiration.ps1**: Serving as a vital security measure in Active Directory environments, this script enforces the expiration of user passwords within a designated OU. By setting the `ChangePasswordAtLogon` property to true, it ensures that users are required to update their passwords at their next login, thereby enhancing security protocols and maintaining password hygiene across the network.

**ADStructure-CreateDefaultOUs.ps1**: This script is instrumental in establishing a well-organized Active Directory setup. It facilitates the creation of standard Organizational Units such as "Computers," "Users," "Groups," and "Printers," making it particularly useful for administrators setting up new domains or reorganizing existing ones. The script ensures a streamlined and structured AD environment, essential for efficient domain management.

**BulkFileDeletion-Script.ps1 & BulkFileDeletion-Script.txt**: A versatile file management tool, this PowerShell script is designed to efficiently search and delete files based on specific extensions within a selected directory. Featuring a user-friendly graphical interface using Windows Forms, it makes file deletion accessible to users who may not be deeply familiar with command-line operations, enhancing ease of use and productivity.

**Certs-RemoveExpiredCA-Explicit.ps1**: This specialized PowerShell script is adept at managing digital certificates, particularly in removing old Certification Authority (CA) certificates. With its graphical user interface (GUI), users are provided a more intuitive, form-based environment to interact with the script. Users can input the thumbprints of the certificates they wish to remove, and the script efficiently processes these entries, offering progress and completion notifications via the GUI. This script is a significant asset for administrators tasked with maintaining up-to-date and secure certificate environments.

**Certs-RemoveExpiredCA-GPO.ps1**: Designed for digital certificate management within a network environment, this PowerShell script is tailored to remove old Certification Authority (CA) certificates through Group Policy Objects (GPOs). The script, which sets its execution policy to unrestricted, includes a specific function, Remove-OldCACertificates, for accepting and processing the thumbprints of certificates to be removed. It's an invaluable resource for network administrators, streamlining the process of maintaining certificate hygiene, especially in large-scale or automated settings where GPOs are a key part of policy implementation and management.

**DiskVolumes-Rename-GPO.ps1**: Aimed at automating the disk volume renaming process on Windows workstations, this PowerShell script is ideally deployed via Group Policy Objects (GPOs). Focusing primarily on renaming the C: and D: volumes, the script allows for either parameter-based or default naming (using the hostname for C: and "Personal-Files" for D:). It includes a logging function, which is crucial for tracking the process and troubleshooting, making it an effective tool for system administrators in large-scale environments to ensure consistent disk volume naming across workstations.

**DomainComputers-Report.ps1**: This script is expertly crafted to generate a comprehensive report of all computers within a specific Active Directory domain. It serves as an invaluable tool for administrators, providing a thorough overview of all machines in the domain, including crucial information about domain controllers. This script is particularly beneficial for ensuring proper management and oversight of all computing resources within the domain, aiding in effective network administration.

**EventLogs-NewPathsCreation-Servers.ps1**: This script is specifically developed to enhance the management of Event Log files on Windows Servers. It assists administrators in effectively reorganizing, moving, and resizing Event Log files and folders. The script plays a crucial role in optimizing the storage and accessibility of Event Log data, essential for maintaining system health and troubleshooting issues on servers.

**FileNamesShortening-Bulk.ps1**: This PowerShell script is a practical solution for managing file systems with long filenames. Its primary function is to locate files in a designated directory with excessively long names and then truncate these names to a manageable size. Featuring a user-friendly graphical interface, the script facilitates user interaction for specifying the directory and the maximum filename length. It also includes a detailed logging mechanism, documenting the file names both before and after the shortening process. This script is invaluable for organizing files in systems where lengthy file names pose management or compatibility issues.

**ForestReport-MemberServers.ps1**: This script is a vital tool for administrators, aiding in the identification and documentation of member servers within a specific Active Directory domain. It generates detailed information about these servers in a CSV format, enhancing AD management and documentation. This script is particularly useful for maintaining an organized and updated view of all member servers, contributing to efficient domain management.

**InactiveAccounts-ComputerReport.ps1**: Tailored to address the issue of inactive computer accounts in an Active Directory domain, this PowerShell script efficiently identifies and reports such accounts. It aids administrators in maintaining a clean and current AD environment by highlighting computer accounts that may be obsolete, thus contributing to an optimized and secure network.

**RemoteAccess-MultipleRDP.ps1**: This script significantly enhances remote management capabilities by enabling administrators to initiate Remote Desktop Protocol (RDP) sessions to multiple servers at once. It streamlines the process of remote access and server management, offering a more efficient way to handle administrative tasks on multiple servers simultaneously.

**ScriptSettings-GlobalGUI.ps1**: Acting as a foundational template, this script offers a comprehensive graphical user interface (GUI) model that can be customized and incorporated into a variety of PowerShell scripts. It demonstrates the creation and usage of a GUI in PowerShell, making script interaction more user-friendly. The script includes versatile GUI elements like text input boxes, labels, progress bars, and buttons, adaptable for various scripting needs. This script is particularly beneficial for script developers seeking to enhance user interaction and ease of use in their PowerShell tools.

**SMBShare-UserUnlock.ps1**: This script is a practical and essential tool for network and system administrators. It is designed to manage Shared Folder (SMB Share) access, aiding in the quick resolution of user access issues and ensuring uninterrupted operation in shared network environments.

**SoftwareGUID-List.ps1**: This auditing script is adept at generating a detailed inventory of all software installed on Windows systems, including their Global Unique Identifiers (GUIDs). Organized into a CSV file for easy access and documentation, this script is an indispensable tool for software auditing and management in Windows environments.

**UserAccounts-LastLogonReport.ps1**: This script generates a detailed report on user accounts in Active Directory, focusing on their last logon activity. It is a valuable resource for identifying inactive user accounts, which is crucial for efficient user management in AD. The script helps administrators streamline account maintenance, ensuring that Active Directory remains organized and up-to-date with active user information.

**UserLogon-MessageBroadcast-GPO.ps1**: Designed to enhance communication in managed IT environments, this PowerShell script displays warning messages upon user logon on workstations, usually implemented via Group Policy Objects (GPOs). It plays a pivotal role in delivering important notifications or reminders right after users log in. The script verifies the existence of a specified message file (e.g., an HTA file on a network share) and executes it, guaranteeing the consistent display of the message across all targeted workstations. Its error handling silently continues on error occurrences but logs them for review, making it an essential tool for ensuring effective communication in networked environments.

**UserPasswordReset-Default.ps1**: Specially designed for Active Directory environments, this script is a powerful solution for resetting passwords en masse within a specific Organizational Unit (OU). It enables bulk password changes by enforcing a uniform default password for all users in the OU. This functionality is highly beneficial in situations like post-migration processes or when implementing new password policies, simplifying the password reset process and enhancing security.

**UsersWithNonExpiringPasswords-List.ps1**: Dedicated to security auditing, this script compiles a list of users in Active Directory whose passwords are set to never expire. By identifying these accounts, administrators can enforce better password policies and strengthen overall network security, making it an essential tool for maintaining a secure and compliant AD environment.

**Winget-UpgradeInstall-Explicit.ps1**: This interactive script offers a user-friendly approach to updating software on Windows OS using `winget`. Equipped with a progress bar and detailed logging, it simplifies the process of explicit software updates, enhancing user experience and ensuring up-to-date software installations.

**Winget-UpgradeInstall-GPO.ps1**: Tailored for use with Group Policy Object (GPO) implementations, this script streamlines software updates across multiple systems using `winget`. It features detailed logging for each update action, making it an efficient tool for administrators to manage software updates in a networked environment.

**WorkstationDescription-Updater.ps1**: A sophisticated tool for updating workstation descriptions in an Active Directory environment, this script features an enhanced graphical user interface (GUI) for ease of use. Administrators can input details like the server domain controller, a default description for workstations, and the target organizational unit (OU). The script also prompts for administrator credentials to ensure secure and appropriate execution. Its GUI includes a progress bar, visually indicating the update process's completion status. This utility is invaluable for IT administrators who need to update workstation descriptions on a large scale, providing an efficient and user-friendly method for managing networked computer descriptions.

**NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts that will continue to enhance system administration efficiency and effectiveness.

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
