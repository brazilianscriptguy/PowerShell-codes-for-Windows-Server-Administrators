# COMIG SOON !!!

# 🖥️ Efficient Server Management and ITSM Compliance on Windows Server Environments

## 📄 Description

The **ITSM-Templates-SVR** repository is a comprehensive collection of PowerShell and VBScript tools designed for IT Service Management (ITSM) in Windows Server environments. These tools enable IT administrators to automate server configurations, enhance operational efficiency, and maintain compliance with organizational policies.

✨ **Key Features**:
- **Server-Specific Configurations** for streamlined ITSM implementation.  
- **Automated Processes** for domain services, roles, and server hardening.  
- **Detailed Logs and Reports** to track and audit execution outcomes.

---

## 📄 Overview

The **Check-List for Applying ITSM-Templates-SVR** standardizes configurations for servers, improving compliance, security, and operational efficiency.

### **Objectives**:
- Maintain high server availability and reliability.  
- Automate critical server-side ITSM tasks.  
- Ensure compliance with security and governance policies.

---

## 📋 Steps to Use ITSM-Templates-SVR Scripts

1. **Clone the Repository**:  
   - Clone the `ITSM-Templates-SVR` folder to your organization’s **Definitive Media Library (DML)** for centralized access and secure storage.

2. **Deploy Locally to Servers**:  
   - Copy the `ITSM-Templates-SVR` folder from the DML to the `C:\` drive of each server to enable local execution. Running scripts locally reduces dependency on network connectivity and ensures smooth operation.

3. **Maintain an Updated DML**:  
   - Keep the DML repository up-to-date with the latest ITSM-Templates-SVR scripts to align server configurations with current standards.

4. **Configure Using Administrator Accounts**:  
   - Use the server’s local administrator account or a domain admin account for configurations, ensuring security and consistency.

5. **Follow the Checklist**:  
   - Refer to the `Check-List for Applying ITSM-Templates on Windows Server Environments.pdf` for detailed guidance.

6. **Customize Scripts**:  
   - Modify PowerShell and VBScript tools to fit your organization's specific server management requirements.

---

## 📂 ITSM-Templates-SVR Folder Structure and Scripts

### **Folder Descriptions**:
- **Certificates**: Contains SSL/TLS and root certificates for secure server communication.  
- **ConfigurationScripts**: Scripts for configuring server roles and features.  
- **MainDocs**: Editable documentation, including the server configuration checklist.  
- **ModifyReg**: Registry modification scripts for initial server setup and hardening.  
- **PostIngress**: Scripts executed after a server joins a domain, finalizing configurations.  
- **ScriptsAdditionalSupport**: Tools for troubleshooting and resolving server configuration issues.

---

### **Key Scripts**

The main scripts, located in `C:\ITSM-Templates-SVR\ConfigurationScripts\`, automate server configurations for domain environments:

#### **1. ITSM-DefaultServerConfig.ps1**  
This script applies essential configurations for server setup, including:
- Configuring DNS settings.  
- Hardening Windows Server roles and features.  
- Setting up administrative shares and server monitoring.  

#### **2. ITSM-ModifyServerRegistry.ps1**  
This script modifies server registry settings to enforce security and compliance:
- Disables legacy protocols like SMBv1.  
- Configures Windows Update settings for WSUS integration.  
- Enforces secure RDP configurations.  

---

### **PostIngress Scripts**

Located in `C:\ITSM-Templates-SVR\PostIngress\`, these scripts handle server-specific post-domain-join tasks:

1. **ITSM-DNSRegistration.ps1**:  
   Ensures proper DNS registration for Active Directory integration.

2. **ITSM-HardenServer.ps1**:  
   Applies security hardening configurations after the server joins the domain.

---

### **ScriptsAdditionalSupport**

Located in `C:\ITSM-Templates-SVR\ScriptsAdditionalSupport\`, these scripts provide troubleshooting and advanced server management capabilities:

- **CheckServerRoles.ps1**: Lists all installed roles and features on the server.  
- **ExportServerConfig.ps1**: Exports the server’s configuration to a `.csv` file for documentation.  
- **FixNTFSPermissions.ps1**: Corrects NTFS permission inconsistencies.  
- **InventoryServerSoftware.ps1**: Creates an inventory of installed software on the server.  
- **ResetGPOSettings.ps1**: Resets GPO-related configurations to default values.  
- **ServerTimeSync.ps1**: Synchronizes server time with a domain time source.  

---

## 🚀 Next Releases

Future updates will include:
- Automated patch management tools.  
- Enhanced reporting features for server compliance audits.  
- Scripts for integrating cloud-based server services.

---

## 📝 Logging and Output

- **Logs**: All scripts generate `.log` files documenting execution steps and errors.  
- **Reports**: Scripts export data in `.csv` format for detailed analysis and compliance reporting.

---

## 📄 Log File Locations

Logs are stored in `C:\ITSM-Logs-SVR\` and include:
- DNS registration logs.  
- Server role configuration logs.  
- Domain join/removal logs.  

---

## 🔗 References

- [ITSM-Templates-SVR GitHub Repository](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)

---

### **Document Classification**  
This document is **RESTRICTED** for internal use within the Company’s network.
