# 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository provides a carefully curated collection of `.VBS` and PowerShell scripts designed to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These scripts automate various administrative tasks, enabling IT professionals to optimize workflows and maintain consistent configurations across workstations.

> **✨ Each script in this repository features a graphical user interface (GUI), enhancing user interaction, and includes functionalities for generating operational `.log` files, making workstation management more intuitive and user-friendly.**

## 🛠️ Prerequisites

Before using the scripts in this folder, ensure the following prerequisites are met:

1. **⚙️ PowerShell**
   - **Requirement:** PowerShell must be enabled on your system.
   - **Module:** Import the **Active Directory** module if necessary.

2. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to uninstall applications and access certain system information.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Ensure RSAT is installed on your Windows 10/11 workstation to enable remote administration of Windows Servers.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

4. **🔧 Script Execution Policy**
   - **Requirement:** Adjust the script execution policy on your workstation to permit the running of `.VBS` scripts. This may require modifications to align with your organization's security policies.

5. **📦 Required Dependencies**
   - **Requirement:** Verify that all necessary dependencies are in place, including additional scripts, files, or software components essential for the successful execution of the `.VBS` scripts.

## 📋 Steps to Use ITSM-Templates Scripts

1. **Clone the Repository**  
   Clone the entire `ITSM-Templates` folder to your Definitive Media Library (DML) network path. This will serve as your central repository for the scripts.

2. **Follow the Checklist**  
   Refer to the `APRIL-21-2024-Check-List to apply ITSM-Templates on Windows 10x11 Workstations.pdf` located in the root of the `ITSM-Templates` folder for detailed instructions.

3. **Customize Scripts**  
   Review and customize each `.VBS` and `.REG` file according to your specific needs.

4. **Personalize Workstation Appearance**  
   Customize workstation themes by reviewing and updating files in the `ITSM-Templates\CustomImages` folder.

## 🛠️ Script Descriptions

### ITSM-Templates Folder

#### ITSM-DefaultVBSing.vbs

Located in `C:\ITSM-Templates\UniqueScripts\`, this script performs ten distinct configurations on Windows workstations as part of the ITSM process:

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

Located in `C:\ITSM-Templates\UniqueScripts\`, this script performs ten registry modifications as part of the ITSM process:

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

## 📝 Logging and Output

- 📄 **Logging:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, from uninstalling software to handling errors.
- 📊 **Export Functionality:** Results are exported in `.CSV` format, providing easy-to-analyze data for auditing and reporting purposes.
