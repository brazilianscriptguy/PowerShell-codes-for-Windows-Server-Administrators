# 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository provides a carefully curated collection of `.VBS` and PowerShell scripts designed to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These scripts automate various administrative tasks, enabling IT professionals to optimize workflows and maintain consistent configurations across workstations.

> **✨ Each script in this repository **features a graphical user interface** `(GUI)`, **enhances user interaction**, and includes functionalities for **generating operational** `.log` files, making workstation management more intuitive and user-friendly.**

---

## Installation and Setup

### Requirements

To effectively run these scripts on Windows 10 and 11 workstations, ensure the following prerequisites are met:

1. **Windows PowerShell 5.1 or Newer**: Make sure your workstation is equipped with PowerShell version 5.1 or later for effective script execution.

2. **Administrative Rights**: Ensure you have administrative privileges to run the scripts, as they may require system-level changes.

3. **Script Execution Policy**: Adjust the script execution policy on your workstation to permit the running of `.VBS` scripts. This may require modifications to align with your organization's security policies.

4. **Required Dependencies**: Verify that all necessary dependencies are in place. This includes additional scripts, files, or software components essential for the successful execution of the `.VBS` scripts.

## 📋 Steps to Use ITSM-Templates Scripts

1. **Clone the Repository**: Clone the entire `ITSM-Templates` folder to your Definitive Media Library (DML) network path. This will serve as your central repository for the scripts.

2. **Follow the Checklist**: Refer to the `APRIL-21-2024-Check-List to apply ITSM-Templates on Windows 10x11 Workstations.pdf` located in the root of the `ITSM-Templates` folder for detailed instructions.

3. **Customize Scripts**: Review and customize each `.VBS` and `.REG` file according to your specific needs.

4. **Personalize Workstation Appearance**: Customize workstation themes by reviewing and updating files in the `ITSM-Templates\CustomImages` folder.

## 🛠️ Script Descriptions

### ITSM-Templates Folder

#### ITSM-DefaultVBSing.vbs

This script, located in `C:\ITSM-Templates\UniqueScripts\`, performs ten distinct configurations on Windows workstations as part of the ITSM process. The script configurations include:

1. **All-Certificates-Install.vbs**: Installs essential certificates for secure connections.
2. **CopyDefaultFolders.vbs**: Standardizes desktop folders and XML profiles.
3. **CopyHosts.vbs**: Secures network connections prior to antivirus installation.
4. **CopyLogonBackground.vbs**: Standardizes lock screen images.
5. **CopyUserLogo.vbs**: Standardizes user profile images.
6. **CopyWallPaperDefault.vbs**: Applies uniform desktop wallpapers.
7. **Disable-Windows-Firewall.vbs**: Disables the Windows Firewall.
8. **Grant-Full-Access-Legacy-App.vbs**: Grants execution permissions for legacy applications.
9. **Renew-all-IP-Connections.vbs**: Renews all TCP/IP connections.
10. **WSUS-Clean-SID.vbs**: Cleans WSUS connections.

#### ITSM-ModifyREGing.vbs

This script, located in `C:\ITSM-Templates\UniqueScripts\`, performs ten registry modifications as part of the ITSM process, including:

1. **AddStartPageADM.reg**: Configures the browser homepage.
2. **DisableUAC-LUA.reg**: Disables User Account Control (UAC).
3. **Enable-AutoShareAdmin.reg**: Enables administrative sharing.
4. **Register-Owner.reg**: Customizes company data in Windows licenses.
5. **WSUS-App-Intranet.reg**: Points to the corporate WSUS server.
6. **DesktopCurrent.reg**: Configures desktop settings for the current user.
7. **DesktopDefault.reg**: Configures default desktop settings.
8. **EnableCustomLogonBackgrounds.reg**: Customizes logon screen backgrounds.
9. **Domain-Ingress-Win10x11.reg**: Protects domain shares with secure settings.
10. **ITSM-Templates.deskthemepack**: Applies a consistent desktop theme.

### Additional Scripts

The `ScriptsAdditionalSupport` folder includes supplementary scripts for addressing configuration inconsistencies:

- **ChangeDiskVolumes**: Renames disk volumes locally.
- **ExportCustomThemes**: Exports custom theme files.
- **FixPrinterIssues**: Resolves spooler and printer driver issues.
- **GetSID**: Identifies the Security Identifier (SID) of the OS.
- **LegacyWorkstationIngress**: Enables legacy OS workstations to join new domains.
- **ResetGPOsDataStore**: Resets and re-synchronizes workstation GPOs.
- **UnjoinDomain**: Unjoins workstations from the domain.
- **UnlockAllAdminShares**: Unlocks administrative shares and disables security features.
- **WorkStationConfigReport**: Generates configuration reports.
- **WorkstationTimeSync**: Synchronizes workstation time, date, and time zone settings.

## 🚀 Next Releases

Stay tuned for new scripts addressing evolving ITSM needs, offering more innovative and efficient tools to enhance IT service delivery.

## ❓ Additional Assistance

All script codes are customizable to fit your preferences and requirements. For more detailed information on prerequisites and environment setup, refer to the `README.md` file in the root directory.
