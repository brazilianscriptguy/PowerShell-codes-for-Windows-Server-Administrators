# Powershell-WindowsServer-Administrators
Essential scripts and tools meticulously crafted to empower Windows Server Administrators.

## Description

Welcome to the PowerShell Codes for Windows Server Administrators repository, maintained by **@brazilianscriptguy**. As a dedicated scripter for Windows Server Administrator's Tools, I present a collection of meticulously crafted PowerShell scripts and tools tailored to simplify your administrative tasks.

## Features (files into AD-AdminTools folder)

1. **Eventlogs-Create-New-Paths-SERVERS.ps1**: This script streamlines the management of Event Log files on Windows Servers. It allows you to move, reorganize, and adjust the size of Event Log files and folders efficiently, enhancing the organization and maintenance of your server's logging system.

2. **Force-AD-Password-Expires.ps1**: Specifically designed for Active Directory environments, this script forces the expiration of all user passwords within a given Organizational Unit (OU). It sets the `ChangePasswordAtLogon` property to true, requiring users to change their passwords at their next login, thereby enhancing security.

3. **GUID-Installed-Softwares.ps1**: This auditing tool generates a comprehensive list of all software installed on Windows systems, complete with their Global Unique Identifiers (GUIDs). The output is formatted into a user-friendly CSV file, which is conveniently saved in the 'My Documents' folder.

4. **List-Users-Passwors-Never-Expires.ps1**: This script is an essential tool for security auditing in Active Directory environments. It exports a list of users whose passwords are set to never expire. The data is compiled into an easily accessible CSV file and stored in the 'My Documents' folder.

5. **Move-Computers-between-OUs.ps1**: A vital script for Active Directory administrators, it facilitates the movement of computer accounts between different Organizational Units (OUs) within the same domain, streamlining AD management and organizational changes.

6. **Multiple-RDP-Access.ps1**: Enhance remote management capabilities with this script. It reads a list of server addresses from a user-provided file, verifies their existence, and initiates Remote Desktop Protocol (RDP) sessions for each valid server, simplifying remote access to multiple servers.

7. **Winget-Upgrade-Install-by-GPOs.ps1**: Ideal for Group Policy Object (GPO) deployments, this script automates the process of updating software on Windows OS using the `winget` package manager. It logs all actions in a specified file, ensuring a smooth and traceable software update process across multiple systems.

8. **Winget-Upgrade-Install-Explicit.ps1**: This script offers an interactive and user-friendly approach to software updates on Windows OS. With an intuitive progress bar, it utilizes `winget` for package management, performing updates explicitly while logging the process for easy review and audit.

9. **NEXT COMING SOON**: Stay tuned for more innovative and efficient PowerShell scripts designed to streamline your system administration tasks.

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
