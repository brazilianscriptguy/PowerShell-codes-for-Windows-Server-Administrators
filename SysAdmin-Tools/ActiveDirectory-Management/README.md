# 🛠️ Active Directory Management Tools

## 📄 Overview

This repository contains a suite of PowerShell scripts designed to streamline and automate tasks related to Active Directory (AD) management. These tools assist administrators in managing user accounts, computer accounts, organizational units (OUs), and directory maintenance, enhancing both efficiency and security.

---

## 📜 Script List and Descriptions

### User and Computer Account Management
1. **Add-ADComputers-GrantPermissions.ps1**  
   Automates adding workstations to specific OUs in AD and assigns the necessary permissions for domain joining.

2. **Add-ADInetOrgPerson.ps1**  
   Simplifies the creation of `InetOrgPerson` entries in AD, enabling detailed organizational attribute management.

3. **Add-ADUserAccount.ps1**  
   Facilitates creating new AD user accounts within specified OUs via an intuitive user interface.

4. **Adjust-ExpirationDate-ADUserAccount.ps1**  
   Provides a GUI for updating expiration dates of AD user accounts to ensure compliance.

5. **Cleanup-Inactive-ADComputerAccounts.ps1**  
   Detects and removes inactive computer accounts, improving directory organization and security.

6. **Manage-Disabled-Expired-ADUserAccounts.ps1**  
   Automates the disabling of expired AD user accounts to enhance security and compliance.

7. **Reset-ADUserPasswordsToDefault.ps1**  
   Resets passwords for multiple AD users to a default value, simplifying password management.

8. **Unlock-SMBShareADUserAccess.ps1**  
   Restores access to SMB shared resources for AD users, resolving access issues.

9. **Create-OUsDefaultADStructure.ps1**  
   Helps define and implement a standardized OU structure for domain setup or reorganization.

10. **Move-ADComputer-betweenOUs.ps1**  
    Moves computer accounts between OUs to accommodate structural adjustments.

11. **Move-ADUser-betweenOUs.ps1**  
    Relocates user accounts between OUs to reflect organizational changes.

12. **Export-n-Import-GPOsTool.ps1**  
    Provides a GUI for exporting and importing GPOs between domains, with progress tracking.

13. **Retrieve-ADDomain-AuditPolicy-Configuration.ps1**  
    Retrieves detailed reports on advanced audit policies applied via GPOs for compliance monitoring.

14. **Inventory-ADDomainComputers.ps1**  
    Generates a detailed inventory of all computers within an AD domain for asset tracking.

15. **Inventory-ADGroups-their-Members.ps1**  
    Retrieves group membership details for audits and compliance checks.

16. **Inventory-ADMemberServers.ps1**  
    Produces detailed reports on member servers in the AD domain.

17. **Inventory-ADUserAttributes.ps1**  
    Extracts user attributes for better user data management and reporting.

18. **Inventory-ADUserLastLogon.ps1**  
    Tracks user last logon times to identify inactive accounts.

19. **Inventory-ADUserWithNonExpiringPasswords.ps1**  
    Lists users with non-expiring passwords for enforcing password policies.

20. **Inventory-InactiveADComputerAccounts.ps1**  
    Identifies and removes outdated or inactive computer accounts to maintain a clean directory.

21. **Retrieve-Elevated-ADForestInfo.ps1**  
    Collects data on elevated accounts and privileged groups across the AD forest.

22. **Cleanup-MetaData-ADForest-Tool.ps1**  
    Cleans up metadata in the AD forest by removing orphaned objects and synchronizing Domain Controllers.

23. **Manage-FSMOs-Roles.ps1**  
    Simplifies the management and transfer of FSMO roles within the AD forest.

24. **Synchronize-ADForestDCs.ps1**  
    Automates synchronization of all Domain Controllers, ensuring consistent updates.

25. **Update-ADComputer-Descriptions.ps1**  
    Updates AD computer descriptions via a GUI to improve directory accuracy.

26. **Update-ADUserDisplayName.ps1**  
    Standardizes user display names based on email addresses with preview and undo options.

---

## 🔍 How to Use

1. **Script Header:** Each script includes a detailed header with instructions and requirements.  
2. **PowerShell Editor:** Open scripts in a PowerShell editor to review descriptions and modify parameters as needed.  
3. **Run Scripts:** Use elevated permissions where necessary to execute the scripts.

---

## 💻 Prerequisites

1. **PowerShell Version:** Ensure PowerShell 5.1 or later is installed.  
   Check your version with:  
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **Active Directory Module:** Ensure the `ActiveDirectory` module is installed and import it with:  
   ```powershell
   Import-Module ActiveDirectory
   ```

3. **Administrator Privileges:** Many scripts require elevated permissions to access and modify AD configurations.

4. **Execution Policy:** Temporarily allow script execution by setting the execution policy:  
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   ```
---
