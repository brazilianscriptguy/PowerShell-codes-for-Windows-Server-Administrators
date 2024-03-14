# Files in the ITSM-Templates Folder

## Prerequisite:
Before utilizing the scripts within this directory, ensure that `Windows PowerShell 5.1` or higher is installed on your system. These scripts are designed for IT Service Management tasks and may utilize commands such as `Get-WmiObject` for system information retrieval and `Invoke-Command` for executing tasks on remote computers. Ensure that you have administrative privileges on the systems you intend to manage with these scripts.

## Description:
This directory hosts a collection of PowerShell script templates designed to streamline IT Service Management (ITSM) tasks. These scripts facilitate a wide range of operations, from system health checks and software inventory management to user account management and service configuration, tailored to enhance the efficiency and effectiveness of ITSM processes.

1. **System-HealthCheck.ps1:** This script performs a comprehensive health assessment of system components, including CPU, memory, disk usage, and network connectivity. It generates a detailed report, aiding in proactive system maintenance and troubleshooting.

2. **Software-Inventory.ps1**: Automates the process of gathering installed software across networked computers, aiding in license management and compliance checks. Outputs are structured for easy analysis and record-keeping.

3. **User-AccountManagement.ps1**: Streamlines the creation, modification, and deletion of user accounts in Active Directory, including password resets and group membership adjustments, with detailed logging for audit purposes.

4. **Service-ConfigurationAudit.ps1**: Reviews and reports on the configuration of critical Windows Services, comparing current states against best practice or predefined standards, to ensure optimal security and performance settings.

5. **Network-PerformanceMonitor.ps1**: Leverages native PowerShell cmdlets to monitor network performance metrics, such as latency and packet loss, providing insights into network health and aiding in the troubleshooting of connectivity issues.

6. **Security-PatchCompliance.ps1**: Assesses and reports on the compliance status of security patches across servers and workstations, facilitating vulnerability management and compliance with security policies.

7. **Backup-OperationValidator.ps1**: Validates the success of scheduled backup operations, checking for completion status and logging any failures, to ensure data integrity and availability for disaster recovery.

8. **Log-EventAnalysis.ps1**: Aggregates and analyzes Windows event logs, identifying common errors and security incidents, and summarizing findings for IT staff review, improving operational awareness and incident response.

9. **Print-ServiceUsage.ps1**: Reports on print service usage, including printer status, queue lengths, and volume of print jobs, to assist in the management of printing resources and cost control measures.

10. **Disk-SpaceCleanup.ps1**: Identifies and optionally cleans up disk space on servers and workstations, targeting temporary files, unused profiles, and old logs to maintain optimal performance and reduce unnecessary storage costs.

11. **NEXT COMING SOON**: Our continuous improvement process means new scripts will be added to address evolving ITSM needs, offering more innovative and efficient tools to enhance IT service delivery.

## Additional Assistance
For further help or to find more detailed information on prerequisites and environment configuration, please refer to the README-main.md file.
