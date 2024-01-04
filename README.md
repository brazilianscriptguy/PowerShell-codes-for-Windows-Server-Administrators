# PowerShell codes for Windows Server Administrators
Essential scripts and tools meticulously crafted to empower Windows Server Administrators.

## Description

Welcome to the PowerShell Codes for Windows Server Administrators repository, curated by @brazilianscriptguy. This repository serves as a treasure trove of PowerShell scripts and tools, each meticulously engineered to streamline the workload of Windows Server administrators. These scripts, ranging from security management to system optimization, embody precision and user-friendliness, ensuring that administrative tasks are both simplified and effective.

Delve into the repository and discover a realm where each script not only addresses specific administrative challenges but also introduces a level of efficiency and clarity that transforms routine tasks into seamless operations. Every tool here is a testament to the power of well-crafted scripting, designed to elevate the standards of server administration.

## Features 
Within this repository, you will find several distinct folders. Please select a folder of your interest and, as a first step, refer to the README.md file located in it main directory. This file contains detailed information about the functions available as well as any requirements necessary for their use.

# Files into AD-AdminTools folder
1. **Change-Users-Pass-to-DefaultPass.ps1**: This script is a powerful tool for system administrators managing a large number of user accounts in Active Directory. It simplifies the process of resetting user passwords in bulk within a specified Organizational Unit (OU). By allowing the administrator to set a default password for all users in the OU, the script ensures quick and uniform password updates, which is especially useful in scenarios like post-migration processes or widespread password policy changes. Its user-friendly interface makes it easy to specify the target OU and the new default password, streamlining what would otherwise be a time-consuming task.

2. **Create-Default-OUs-into-AD-Structure.ps1**: This innovative PowerShell script, equipped with a user-friendly graphical interface, significantly simplifies the process of creating Organizational Units (OUs) within an Active Directory environment. Targeted towards system and network administrators, it streamlines the establishment of essential OUs like "Computers," "Printers," "Groups," and "Users" in specified paths. By just entering the base OU path, users can swiftly generate these default OUs, ensuring a structured and organized AD setup. This tool is particularly valuable for setting up new domains or reorganizing existing ones, promoting efficient and error-free AD management.

3. **Eventlogs-Create-New-Paths-SERVERS.ps1**: This script streamlines the management of Event Log files on Windows Servers. It allows you to move, reorganize, and adjust the size of Event Log files and folders efficiently, enhancing the organization and maintenance of your server's logging system.

4. **Force-AD-Password-Expires.ps1**: Specifically designed for Active Directory environments, this script forces the expiration of all user passwords within a given Organizational Unit (OU). It sets the `ChangePasswordAtLogon` property to true, requiring users to change their passwords at their next login, thereby enhancing security.

5. **GUID-Installed-Softwares.ps1**: This auditing tool generates a comprehensive list of all software installed on Windows systems, complete with their Global Unique Identifiers (GUIDs). The output is formatted into a user-friendly CSV file, which is conveniently saved in the 'My Documents' folder.

6. **List-Users-Passwors-Never-Expires.ps1**: This script is an essential tool for security auditing in Active Directory environments. It exports a list of users whose passwords are set to never expire. The data is compiled into an easily accessible CSV file and stored in the 'My Documents' folder.

7. **Move-Computers-between-OUs.ps1**: A vital script for Active Directory administrators, it facilitates the movement of computer accounts between different Organizational Units (OUs) within the same domain, streamlining AD management and organizational changes.

8. **Multiple-RDP-Access.ps1**: Enhance remote management capabilities with this script. It reads a list of server addresses from a user-provided file, verifies their existence, and initiates Remote Desktop Protocol (RDP) sessions for each valid server, simplifying remote access to multiple servers.

9. **UnlockUser-SMB-Share.ps1:** This script is a valuable tool for network and system administrators dealing with Shared Folder (SMB Share) access management. It facilitates the quick unlocking of user access to specific SMB shares, ensuring uninterrupted workflow and efficient user access management. The script comes with a user-friendly graphical interface, allowing administrators to easily input the share name, domain, and username to identify and unlock blocked users. Ideal for environments where users frequently face access issues due to lockouts or permission changes, this script helps maintain seamless access to critical shared resources on the network. Its efficient and straightforward operation makes it an essential utility in the toolkit of any IT professional responsible for managing shared network resources.

10. **Winget-Upgrade-Install-by-GPOs.ps1**: Ideal for Group Policy Object (GPO) deployments, this script automates the process of updating software on Windows OS using the `winget` package manager. It logs all actions in a specified file, ensuring a smooth and traceable software update process across multiple systems.

11. **Winget-Upgrade-Install-Explicit.ps1**: This script offers an interactive and user-friendly approach to software updates on Windows OS. With an intuitive progress bar, it utilizes `winget` for package management, performing updates explicitly while logging the process for easy review and audit.

12. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts designed to streamline your system administration tasks.

# Files into Eventlogs-Tools folder
## Prerequisite:
Before using the scripts in this folder, ensure that the Microsoft Log Parser utility is installed in your environment.

## Description:
This folder contains scripts specifically designed for selecting and processing Windows Event Log files (*.evtx). They focus on extracting particular information from these logs and then outputting the results in an easy-to-analyze CSV file format.

1. **EventID-307-PrintAudit.ps1**: This script expertly extracts information from the Microsoft-Windows-PrintService/Operational Event Log (EVTX file), focusing on Event ID 307. It captures detailed data about print job activities, including printer usage, page counts, and job sizes. As an indispensable tool for audit and oversight, it offers deep insights into print management and operational efficiency within your environment.

2. **EventID-4624-Logon-via-RDP.ps1**: Designed to scrutinize Windows Security Event Logs, this script zeroes in on Event ID 4624 to elucidate Remote Desktop Protocol (RDP) logon activities. It deftly gathers and organizes essential data about each RDP session, delivering a concise and informative CSV report. This script is ideal for administrators needing to monitor remote access, ensure compliance, and maintain security across their network.

3. **EventID-4625-Logon-account-failed.ps1**: Specializing in analyzing failed logon attempts (Event ID 4625) from Windows Security Event Logs, this script adeptly filters and documents each failed attempt. By translating these logs into an informative CSV file, it offers a panoramic view of security incidents, making it an essential tool for identifying potential breaches, strengthening security measures, and understanding user behavior patterns.

4. **EventID-4648-Logon-using-explicit-credentials.ps1**: Focused on Event ID 4648 in Windows Security Event Logs, this script is adept at identifying and reporting logon activities involving explicit credentials. It systematically compiles information about the user, domain, and source IP into an organized CSV report. This script is invaluable for tracking explicit credential usage, bolstering security, and detecting unusual or unauthorized access patterns.
   
6. **EventID-4660-and-4663-Object-deletion-tracking-actions.ps1**: This script is specifically engineered to track and analyze Events ID 4660 and 4663 in Windows Security Event Logs, which are pivotal for monitoring object deletion activities. It proficiently extracts and documents detailed information regarding these deletion events, including user accounts, domains, object types, and the specifics of the deleted objects. The extracted data is methodically organized into a CSV file, providing a comprehensive and easily interpretable record of object deletion incidents. This script is an essential tool for security and compliance auditing, as it aids in the investigation of data deletion activities and ensures that sensitive information is handled securely within the organization. It plays a critical role in understanding the context of deletions, aiding in identifying potential security breaches or policy violations.

7. **EventID-4771-Kerberos-pre-authentication-failed.ps1**: This advanced script is dedicated to processing Event ID 4771 from Windows Security Event Logs, highlighting Kerberos pre-authentication failures. By capturing and reporting these failures, it serves as a critical tool for uncovering potential security threats, including brute force attacks and misuse of credentials. Its output, in a detailed CSV format, is an essential resource for security audits and proactive defense strategies.
   
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

- Suitable for all Windows Server versions after 2016 Standard.
- PowerShell 7.3 (or later)

### Installation

Installing these scripts is a breeze. Follow these steps to get started:

1. Clone the repository to your desired location:

   ```bash
   git clone https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators.git

2. Save the scripts to your preferred directory.

3. Execute the scripts while monitoring the location and environment to ensure proper execution.

Now, you're all set to leverage the power of these PowerShell scripts for efficient Windows Server administration. Feel free to explore and customize them to suit your specific needs.

For questions or further assistance, you can reach out to me at luizhamilton.lhr@gmail.com or join my WhatsApp channel: [WhatsApp Channel](https://whatsapp.com/channel/0029VaEgqC50G0XZV1k4Mb1c).
