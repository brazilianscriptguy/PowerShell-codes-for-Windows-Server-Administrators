# 🔧 SysAdmin-Tools Suite

## 📄 Overview

The **SysAdmin-Tools** repository offers a robust collection of PowerShell scripts to streamline and automate the management of Active Directory (AD), Windows Server roles, network infrastructure, and workstation configurations. Each script is crafted to handle repetitive and complex administrative tasks, providing IT administrators with tools to enhance efficiency, security, and compliance across their environments.

✨ **Key Features**:
- **User-Friendly Interfaces:** Many scripts feature a GUI for easier interaction.
- **Detailed Logging:** Every script generates `.LOG` files for operational transparency and troubleshooting.
- **Exportable Reports:** Output results are often provided in `.CSV` format for easy reporting and integration with analytics tools.

---

## 📂 Folder Structure and Categories

This repository is organized into four main subfolders, grouping scripts by their functional domain:

### 1. **ActiveDirectory-Management**
   Tools focused on managing Active Directory, including user accounts, computer accounts, group policies, and directory synchronization.

   - **Examples of Scripts:**
     - Add-ADComputers-GrantPermissions.ps1
     - Manage-FSMOs-Roles.ps1
     - Inventory-ADUserLastLogon.ps1
     - Synchronize-ADForestDCs.ps1

   📄 *Refer to the detailed [ActiveDirectory-Management/README.md](ActiveDirectory-Management/README.md) for a complete list of scripts and usage.*

---

### 2. **Network-and-Infrastructure-Management**
   Scripts aimed at managing network services such as DHCP, DNS, and WSUS, as well as ensuring reliable infrastructure operations.

   - **Examples of Scripts:**
     - Create-NewDHCPReservations.ps1
     - Update-DNS-and-Sites-Services.ps1
     - Transfer-DHCPScopes.ps1
     - Restart-NetworkAdapter.ps1

   📄 *Refer to the detailed [Network-and-Infrastructure-Management/README.md](Network-and-Infrastructure-Management/README.md) for a complete list of scripts and usage.*

---

### 3. **Security-and-Process-Optimization**
   Scripts designed to optimize system performance, enforce compliance, and enhance security across the IT environment.

   - **Examples of Scripts:**
     - Remove-Softwares-NonCompliance-Tool.ps1
     - Unjoin-ADComputer-and-Cleanup.ps1
     - Initiate-MultipleRDPSessions.ps1
     - Remove-EmptyFiles-or-DateRange.ps1

   📄 *Refer to the detailed [Security-and-Process-Optimization/README.md](Security-and-Process-Optimization/README.md) for a complete list of scripts and usage.*

---

### 4. **SystemConfiguration-and-Deployment**
   Tools for deploying and configuring software, managing group policies, and ensuring consistent system settings across the domain.

   - **Examples of Scripts:**
     - Deploy-FusionInventoryAgent-viaGPO.ps1
     - Install-KMSLicensingServer-Tool.ps1
     - Clear-and-ReSyncGPOs-ADComputers.ps1
     - Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1

   📄 *Refer to the detailed [SystemConfiguration-and-Deployment/README.md](SystemConfiguration-and-Deployment/README.md) for a complete list of scripts and usage.*

---

## 🛠️ Prerequisites

To maximize the effectiveness of these tools, ensure the following prerequisites are in place:

1. **🖥️ Remote Server Administration Tools (RSAT):**
   - Install RSAT components to enable management of AD, DNS, DHCP, and other server roles.
   - Use the following PowerShell command to install RSAT on Windows 10/11:
     ```powershell
     Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
     ```

2. **⚙️ PowerShell Version:**
   - Ensure you are using PowerShell 5.1 or later. Check your version with:
     ```powershell
     $PSVersionTable.PSVersion
     ```

3. **🔑 Administrator Privileges:**
   - Scripts require elevated permissions to perform administrative tasks.

4. **🔧 Execution Policy:**
   - Temporarily allow script execution with:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
     ```

5. **📦 Dependencies:**
   - Confirm all necessary software components and modules (e.g., `ActiveDirectory`, `DHCPServer`) are installed.

---

## 🚀 How to Get Started

1. Clone or download this repository to your system:
   ```bash
   git clone https://github.com/brazilianscriptguy/SysAdmin-Tools.git
   ```
2. Navigate to the relevant folder and review the `README.md` file for detailed descriptions and usage instructions.
3. Execute scripts using the following:
   ```powershell
   .\ScriptName.ps1
   ```

---

## 📝 Logging and Reports

- **Logs:** Detailed `.LOG` files provide an audit trail of script operations and troubleshooting insights.
- **Reports:** Many scripts export results in `.CSV` format for reporting and integration.

---

## ❓ Support and Contributions

For questions or contributions, feel free to open an issue or submit a pull request in the GitHub repository. Your feedback and collaboration are welcome!
