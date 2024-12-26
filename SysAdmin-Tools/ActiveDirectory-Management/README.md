# 🛠️ Active Directory Management Tools

## 📄 Overview

This folder contains a comprehensive suite of PowerShell scripts designed to automate and streamline tasks related to Active Directory (AD). These tools help administrators manage user accounts, computer accounts, organizational units, and overall directory maintenance, enhancing both efficiency and security.

---

## 📜 Script List and Descriptions

### User and Computer Account Management

1. **Add-ADComputers-GrantPermissions.ps1**  
   Automates adding workstations to specific OUs in AD and assigns necessary permissions for domain joining.

2. **Add-ADInetOrgPerson.ps1**  
   Simplifies creating `InetOrgPerson` entries in AD, enabling detailed organizational attribute management.

3. **Add-ADUserAccount.ps1**  
   Facilitates creating new AD user accounts within specified OUs through an intuitive user interface.

4. **Adjust-ExpirationDate-ADUserAccount.ps1**  
   Provides a GUI for updating the expiration dates of AD user accounts, ensuring compliance with organizational policies.

5. **Check-Shorter-ADComputerNames.ps1**  
   Identifies AD computer names that do not meet minimum length requirements, helping enforce naming conventions.

6. **Cleanup-Inactive-ADComputerAccounts.ps1**  
   Detects and removes inactive computer accounts in AD, improving security and directory organization.

7. **Cleanup-MetaData-ADForest-Tool.ps1**  
   Cleans up metadata in the AD forest by removing orphaned objects and synchronizing Domain Controllers for optimal performance.

8. **Create-OUsDefaultADStructure.ps1**  
   Helps define and implement a standardized OU structure for easier domain setup or reorganization.

9. **Enforce-Expiration-ADUserPasswords.ps1**  
   Enforces password expiration policies for users within specific OUs, ensuring compliance with security requirements.

10. **Export-n-Import-GPOsTool.ps1**  
    Provides a GUI for exporting and importing Group Policy Objects (GPOs) between domains, with progress tracking.

11. **Inventory-ADDomainComputers.ps1**  
    Generates a detailed inventory of all computers within an AD domain for asset tracking and management.

12. **Inventory-ADGroups-their-Members.ps1**  
    Retrieves group membership details, aiding in audits and compliance checks.

13. **Inventory-ADMemberServers.ps1**  
    Produces detailed reports on member servers in the AD domain, simplifying server management.

14. **Inventory-ADUserAttributes.ps1**  
    Extracts user attributes from AD, helping administrators manage and report user data more effectively.

15. **Inventory-ADUserLastLogon.ps1**  
    Tracks user last logon times, helping identify inactive accounts.

16. **Inventory-ADUserWithNonExpiringPasswords.ps1**  
    Lists users with non-expiring passwords, enabling enforcement of password policies.

17. **Inventory-InactiveADComputerAccounts.ps1**  
    Identifies and removes outdated or inactive computer accounts, ensuring a clean and secure directory.

18. **Manage-Disabled-Expired-ADUserAccounts.ps1**  
    Automates the disabling of expired AD user accounts, improving security and compliance.

19. **Manage-FSMOs-Roles.ps1**  
    Simplifies managing and transferring Flexible Single Master Operation (FSMO) roles within the AD forest.

20. **Move-ADComputer-betweenOUs.ps1**  
    Moves computer accounts between OUs to accommodate structural adjustments.

21. **Move-ADUser-betweenOUs.ps1**  
    Relocates user accounts between OUs to reflect organizational changes.

22. **Reset-ADUserPasswordsToDefault.ps1**  
    Resets passwords for multiple AD users to a default value, simplifying password management.

23. **Retrieve-ADComputer-SharedFolders.ps1**  
    Scans AD computers for shared folders, ensuring only authorized shares are in place.

24. **Retrieve-ADDomain-AuditPolicy-Configuration.ps1**  
    Retrieves advanced audit policies applied via GPOs, generating detailed reports for compliance.

25. **Retrieve-Elevated-ADForestInfo.ps1**  
    Gathers data on elevated accounts and privileged groups across the AD forest for improved security monitoring.

26. **Synchronize-ADForestDCs.ps1**  
    Automates synchronization of all Domain Controllers across the AD forest, ensuring consistent updates.

27. **Unlock-SMBShareADUserAccess.ps1**  
    Restores access to SMB shared resources for AD users, resolving access issues.

28. **Update-ADComputer-Descriptions.ps1**  
    Updates AD computer descriptions via a GUI, improving directory accuracy.

29. **Update-ADUserDisplayName.ps1**  
    Standardizes user display names based on email addresses, with preview and undo options for enhanced control.

---

## 🔍 How to Use

- Each script includes a detailed header for instructions and requirements.
- Open the scripts in a PowerShell editor to review their descriptions and modify parameters as needed.
- Ensure that all necessary modules, such as `ActiveDirectory`, are installed and imported before running the scripts.

---

## 💻 Prerequisites

1. **PowerShell Version:** PowerShell 5.1 or later.  
   Verify your version with:  
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **Active Directory Module:** Ensure the `ActiveDirectory` module is installed. Import it with:  
   ```powershell
   Import-Module ActiveDirectory
   ```

3. **Administrator Privileges:** Most scripts require elevated permissions to access AD configurations and apply changes.

4. **Execution Policy:** Temporarily set the execution policy to allow script execution:  
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
   ``` 

--- 
