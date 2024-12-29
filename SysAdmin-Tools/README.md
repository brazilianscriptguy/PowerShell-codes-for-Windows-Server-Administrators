# 🔧 SysAdmin-Tools Suite

## 📄 Overview

The **SysAdmin-Tools** suite provides a powerful collection of PowerShell scripts designed to streamline and automate the management of Active Directory (AD), Windows Server roles, network infrastructure, and workstation configurations. These scripts simplify complex administrative tasks, enhance operational efficiency, and ensure compliance and security across IT environments.

✨ **Key Features**:
- **User-Friendly Interfaces**: All scripts include a GUI for intuitive use.
- **Detailed Logging**: All scripts generate `.log` files for audit trails and troubleshooting.
- **Exportable Reports**: Reports are often exported in `.csv` format for integration with Reporting and Analytics Tools.

---

## 📂 Folder Structure and Categories

The suite is organized into four main subfolders, grouping scripts by functionality:

### 1. **ActiveDirectory-Management**
   Tools for managing Active Directory, including user accounts, computer accounts, group policies, and directory synchronization.

   - **Examples**:
     - `Add-ADComputers-GrantPermissions.ps1`
     - `Manage-FSMOs-Roles.ps1`
     - `Inventory-ADUserLastLogon.ps1`
     - `Synchronize-ADForestDCs.ps1`

   📄 *Refer to the detailed [ActiveDirectory-Management/README.md](ActiveDirectory-Management/README.md) for a complete list of scripts and usage instructions.*

---

### 2. **GroupPolicyObjects-Templates**
   A collection of ready-to-use GPO templates designed for seamless import into a new Windows Server Forest and Domain structure.
   
   - **Examples**:
     - `enable-logon-message-workstations`
     - `itsm-template-ALL-workstations`
     - `install-cmdb-fusioninventory-agent`
     - `wsus-update-workstation-MODEL`

   📄 *Refer to the detailed [GPOs-Templates/README.md](GPOs-Templates/README.md) for a complete list of scripts and usage instructions.*

---

### 3. **Network-and-Infrastructure-Management**
   Scripts for managing network services (e.g., DHCP, DNS, WSUS) and ensuring reliable infrastructure operations.

   - **Examples**:
     - `Create-NewDHCPReservations.ps1`
     - `Update-DNS-and-Sites-Services.ps1`
     - `Transfer-DHCPScopes.ps1`
     - `Restart-NetworkAdapter.ps1`

   📄 *Refer to the detailed [Network-and-Infrastructure-Management/README.md](Network-and-Infrastructure-Management/README.md) for a complete list of scripts and usage instructions.*

---

### 4. **Security-and-Process-Optimization**
   Tools for optimizing system performance, enforcing compliance, and enhancing security.

   - **Examples**:
     - `Remove-Softwares-NonCompliance-Tool.ps1`
     - `Unjoin-ADComputer-and-Cleanup.ps1`
     - `Initiate-MultipleRDPSessions.ps1`
     - `Remove-EmptyFiles-or-DateRange.ps1`

   📄 *Refer to the detailed [Security-and-Process-Optimization/README.md](Security-and-Process-Optimization/README.md) for a complete list of scripts and usage instructions.*

---

### 5. **SystemConfiguration-and-Deployment**
   Tools for deploying and configuring software, managing group policies, and maintaining consistent system settings across the domain.

   - **Examples**:
     - `Deploy-FusionInventoryAgent-viaGPO.ps1`
     - `Install-KMSLicensingServer-Tool.ps1`
     - `Clear-and-ReSyncGPOs-ADComputers.ps1`
     - `Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1`

   📄 *Refer to the detailed [SystemConfiguration-and-Deployment/README.md](SystemConfiguration-and-Deployment/README.md) for a complete list of scripts and usage instructions.*

---

## 🛠️ Prerequisites

Ensure the following prerequisites are met to maximize the tools' effectiveness:

1. **🖥️ Remote Server Administration Tools (RSAT)**:
   - Install RSAT components for managing AD, DNS, DHCP, and other server roles.
   - Use the following command to install RSAT on Windows 10/11:
     ```powershell
     Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
     ```

2. **⚙️ PowerShell Version**:
   - Use PowerShell 5.1 or later. Verify your version:
     ```powershell
     $PSVersionTable.PSVersion
     ```

3. **🔑 Administrator Privileges**:
   - Scripts require elevated permissions to perform administrative tasks.

4. **🔧 Execution Policy**:
   - Temporarily allow script execution with:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
     ```

5. **📦 Dependencies**:
   - Ensure all required software components and modules (e.g., `ActiveDirectory`, `DHCPServer`) are installed.

---

## 🚀 Getting Started

1. Clone or download this repository:
   ```bash
   git clone https://github.com/brazilianscriptguy/SysAdmin-Tools.git
   ```
2. Navigate to the relevant subfolder and review the `README.md` file for detailed script descriptions and usage instructions.
3. Run scripts using PowerShell:
   ```powershell
   .\ScriptName.ps1
   ```

---

## 📝 Logging and Reporting

- **Logs**: Each script generates `.log` files for tracking operations and debugging.
- **Reports**: Many scripts export results in `.csv` format for reporting and analysis.

---

## ❓ Support and Contributions

For questions or contributions:
- Open an issue or submit a pull request on GitHub.
- Your feedback and collaboration are always welcome!

---
