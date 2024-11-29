# 🛠️ Active Directory Management Tools

## 📄 Overview
This folder contains a collection of PowerShell scripts specifically designed to manage and automate tasks related to Active Directory (AD). These scripts help streamline processes for managing user accounts, computer accounts, organizational units, and directory maintenance, enhancing both efficiency and security.

---

## 📜 Script List and Descriptions

1. **Add-ADComputers-GrantPermissions.ps1**  
   Automates the addition of workstations to specific OUs in AD and assigns necessary permissions for domain joining.

2. **Add-ADInetOrgPerson.ps1**  
   Simplifies the creation of `InetOrgPerson` entries in AD, allowing administrators to input detailed account and organizational attributes.

3. **Add-ADUserAccount.ps1**  
   Facilitates the creation of new AD user accounts within specified OUs, providing an intuitive user interface.

4. **Adjust-ExpirationDate-ADUserAccount.ps1**  
   Provides a GUI to search and update the expiration dates of AD user accounts, simplifying account management.

5. **Cleanup-Inactive-ADComputerAccounts.ps1**  
   Identifies and removes inactive computer accounts, enhancing directory security and efficiency.

6. **Create-OUsDefaultADStructure.ps1**  
   Helps define a standardized OU structure within AD for easier domain setup and reorganization.

7. **Enforce-Expiration-ADUserPasswords.ps1**  
   Enforces password expiration policies for users within specified OUs.

8. **Inventory-ADDomainComputers.ps1**  
   Generates a comprehensive inventory of computers within an AD domain for asset tracking and management.

9. **Inventory-ADGroups-their-Members.ps1**  
   Retrieves detailed group membership information for auditing and compliance purposes.

10. **Inventory-ADMemberServers.ps1**  
    Creates detailed reports on member servers within an AD domain.

11. **Inventory-ADUserAttributes.ps1**  
    Extracts user attributes from AD to assist with management and reporting.

12. **Inventory-ADUserLastLogon.ps1**  
    Provides insights into user last logon times to identify inactive accounts.

13. **Inventory-ADUserWithNonExpiringPasswords.ps1**  
    Lists AD users with non-expiring passwords to ensure compliance with security policies.

14. **Inventory-InactiveADComputerAccounts.ps1**  
    Identifies and removes outdated or inactive computer accounts in AD.

15. **Manage-Disabled-Expired-ADUserAccounts.ps1**  
    Disables expired user accounts to improve security and maintain compliance.

16. **Manage-FSMOs-Roles.ps1**  
    Facilitates the transfer and management of FSMO roles across the AD forest for seamless domain operation.

17. **Move-ADComputer-betweenOUs.ps1**  
    Moves computer accounts between OUs for organizational adjustments.

18. **Move-ADUser-betweenOUs.ps1**  
    Moves user accounts between OUs to reflect changes in organizational structure.

19. **Reset-ADUserPasswordsToDefault.ps1**  
    Resets passwords for a group of AD users to a default value.

20. **Synchronize-ADForestDCs.ps1**  
    Synchronizes changes across all Domain Controllers in the AD forest.

21. **Unlock-SMBShareADUserAccess.ps1**  
    Restores user access to SMB shared resources.

22. **Update-ADComputer-Descriptions.ps1**  
    Updates computer descriptions in AD via a user-friendly GUI.

23. **Update-ADUserDisplayName.ps1**  
    Updates user display names based on email addresses to maintain consistency.

---

## 🔍 How to Use
Each script comes with detailed headers for guidance. Open the scripts in a PowerShell editor to review their specific instructions.

---

