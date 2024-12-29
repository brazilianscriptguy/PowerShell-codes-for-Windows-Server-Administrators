# 🛠️ ScriptsAdditionalSupport Suite

## 📄 Overview

The **ScriptsAdditionalSupport** folder offers a robust collection of scripts designed to address configuration inconsistencies identified by **L1 Service Support Operators**. These tools ensure seamless troubleshooting, maintenance, and optimization for both workstation and server environments, aligning with IT compliance standards.

Each script includes:
- **Advanced error handling**  
- **Detailed logging**  
- **User-friendly GUI**, where applicable  

This Suite improves operational efficiency and simplifies administrative workflows, addressing common configuration issues on workstations.

---

## 📋 Script Descriptions

### **1. ActivateAllAdminShare**
- **Script:** `Activate-All-AdminShares.ps1`  
Enables administrative shares, activates Remote Desktop Protocol (RDP), disables Windows Firewall, and deactivates Windows Defender to facilitate administrative access. Includes a GUI for task management.

---

### **2. ExportCustomThemesFiles**
- **Script:** `Exports-CustomThemes-Files.ps1`  
Standardizes desktop and user interface configurations by exporting custom Windows theme files, such as `LayoutModification.xml`, `.msstyles`, and `.deskthemepack`, across the network.

---

### **3. FixPrinterDriverIssues**
- **Script:** `Fix-PrinterDriver-Issues.ps1`  
Troubleshoots common printer-related issues by:  
  - Resetting the print spooler  
  - Clearing print jobs  
  - Managing printer drivers  
Includes multiple resolution methods and a GUI for ease of use.

---

### **4. GetSID**
- **Tool:** `PsGetsid64.exe` (MS Sysinternals)  
Translates **Security Identifiers (SID)** to display names and vice versa. Useful for diagnosing and managing builtin accounts, domain accounts, and local accounts.

---

### **5. InventoryInstalledSoftwareList**
- **Script:** `Inventory-InstalledSoftwareList.ps1`  
Inventories all installed software on the workstation, generating a comprehensive report for auditing and compliance purposes.

---

### **6. LegacyWorkstationIngress**
- **Script:** `LSA-NetJoin-Legacy.ps1`  
Modifies registry settings to enable legacy operating systems to join modern domains. Fully compatible with Windows Server 2019 and newer.

---

### **7. RecallKESCert**
- **Script:** `RecallKESCert.ps1`  
Repoints the workstation to the antivirus server and renews the required certificate, ensuring continued protection and secure operations.

---

### **8. RenameDiskVolumes**
- **Script:** `ChangeDiskVolumesNames.ps1`  
Renames disk volumes:  
  - **C:** drive is labeled with the hostname.  
  - **D:** drive is labeled for personal data or custom use.  
Detailed logs ensure traceability.

---

### **9. ResyncGPOsDataStore**
- **Script:** `Resync-GPOs-DataStore.ps1`  
Resets all Group Policy Objects (GPOs) on the workstation and synchronizes them with domain policies. A GUI assists users and logs all actions for accountability.

---

### **10. UnjoinADComputer-and-Cleanup**
- **Script:** `Unjoin-ADComputer-and-Cleanup.ps1`  
Unjoins the workstation from the domain and performs cleanup tasks, such as:  
  - Clearing DNS cache  
  - Removing old domain profiles  
  - Resetting environment variables  
Includes a GUI for smooth operation and standardized logging.

---

### **11. WorkStationConfigReport**
- **Script:** `Workstation-Data-Report.ps1`  
Compiles system configuration details, including OS, BIOS, and network information, into a `.CSV` file. Designed with a GUI for user feedback and error handling.

---

### **12. WorkstationTimeSync**
- **Script:** `Workstation-TimeSync.ps1`  
Synchronizes the workstation’s time, date, and time zone with the domain controllers, ensuring network-wide consistency.

---

## 🚀 How to Use

1. Navigate to the **ScriptsAdditionalSupport** folder in the **ITSM-Templates-WKS** directory.  
2. Select and execute the script relevant to the issue or task at hand.  
3. Refer to the usage instructions included in the script headers or associated documentation for detailed guidance.  

---

## 📝 Logging and Output

- **Log Directory:** Each script generates `.log` files saved in `C:\ITSM-Logs-WKS\`.  
- **Details Logged:** Logs capture all actions performed, outcomes, and errors encountered, ensuring transparency and aiding troubleshooting.

---

## 🔗 References

- [ITSM-Templates-WKS Documentation](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators/blob/main/ITSM-Templates-WKS/README.md)  
- For further assistance, contact your **L1 Service Support Coordinator** or refer to the **README.md** in the root directory of **ITSM-Templates-WKS**.
