# Configuring Windows Event Log for PrintService Operational Log

## .SYNOPSIS

Configures Windows Event Log settings for the PrintService Operational log.

## .DESCRIPTION

This registry file automates the configuration of the Windows Event Log for the PrintService Operational channel. It sets parameters such as `AutoBackupLogFiles`, `Flags`, log file location, maximum log size, and retention policy.

## .AUTHOR

Luiz Hamilton Silva - @brazilianscriptguy

## .VERSION

Last Updated: November 26, 2024

## .NOTES

- Ensure that the specified log file path (`"File"`) exists and is accessible.
- This configuration is essential for maintaining and managing print service logs efficiently.
- Apply this `.reg` file with administrative privileges to ensure successful registry modifications.

## Registry Configuration

```reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EventLog\Microsoft-Windows-PrintService\Operational]
"AutoBackupLogFiles"=dword:00000001
"Flags"=dword:00000001
"File"="L:\\Microsoft-Windows-PrintService-Operational\\Microsoft-Windows-PrintService-Operational.evtx"
"MaxSize"=dword:09270000
"MaxSizeUpper"=dword:00000000
"Retention"=dword:ffffffff
```

## Deployment Instructions

### 1. Save the `.reg` File

Save the above content into a file named, for example, `Configure-PrintService-Operational.reg`.

### 2. Store the `.reg` File Securely

Place the `.reg` file in a **shared network location** that is accessible by all target machines. Ensure that the share permissions allow **read access** for the **Authenticated Users** group or the specific accounts that will apply the registry settings.

### 3. Deploy via Group Policy Object (GPO)

#### a. Open Group Policy Management Console (GPMC)

- Press `Win + R`, type `gpmc.msc`, and press **Enter**.

#### b. Create or Edit a GPO

- **Right-click** on the desired **Organizational Unit (OU)**.
- Select **"Create a GPO in this domain, and Link it here..."** or **edit** an existing GPO.

#### c. Navigate to Preferences

- Go to `Computer Configuration` → `Preferences` → `Windows Settings` → `Registry`.

#### d. Create New Registry Items

For each registry value defined in the `.reg` file, create a corresponding registry item in the GPO:

1. **Right-click** on **Registry** and select **"New"** → **"Registry Item"**.

2. **Configure the Registry Item**:

   - **Action**: Select **"Update"**.
   - **Hive**: Select **"HKEY_LOCAL_MACHINE"**.
   - **Key Path**: Enter `SYSTEM\ControlSet001\Services\EventLog\Microsoft-Windows-PrintService\Operational`.
   - **Value Name and Type**:
     - **AutoBackupLogFiles**: `DWORD` = `1`
     - **Flags**: `DWORD` = `1`
     - **File**: `REG_SZ` = `L:\Microsoft-Windows-PrintService-Operational\Microsoft-Windows-PrintService-Operational.evtx`
     - **MaxSize**: `DWORD` = `09270000`
     - **MaxSizeUpper**: `DWORD` = `00000000`
     - **Retention**: `DWORD` = `ffffffff`

3. **Repeat** the above steps for each registry value.

#### e. Apply and Close

After configuring all registry values, click **"OK"** to save the settings. Click **"Apply"** and **"OK"** to close the GPO editor.

### 4. Force Group Policy Update

On target machines, you can expedite the policy application by running:

```powershell
gpupdate /force
```

Alternatively, restart the machines to allow GPO to apply the settings during startup.

### 5. Verify Registry Changes

After deployment, on a target machine, open **Registry Editor** (`regedit`) and navigate to:

```
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\EventLog\Microsoft-Windows-PrintService\Operational
```

Ensure that all the specified values are correctly set.

### 6. Monitor Logs

Check the log file location (`L:\Microsoft-Windows-PrintService-Operational\`) to verify that the `Microsoft-Windows-PrintService-Operational.evtx` log file is being created and updated as per the configurations.

## Best Practices and Final Notes

- **Backup Registry Before Changes**:
  - Always create a backup of the registry before applying changes, especially in a production environment.
  
- **Test on a Single Machine**:
  - Before wide-scale deployment, apply the `.reg` file to a single test machine to ensure it behaves as expected.

- **Ensure Network Share Accessibility**:
  - Verify that the drive letter `L:` is correctly mapped on all target machines and that the specified path exists.
  
- **Monitor Event Logs**:
  - Regularly monitor the Application Event Logs for any errors related to the registry changes or the PrintService Operational logs.
  
- **Documentation**:
  - Maintain documentation of all registry changes for future reference and troubleshooting.
  
- **Security Considerations**:
  - Ensure that the network share containing the log files is secured and accessible only by authorized users to prevent unauthorized access or tampering.

By incorporating this well-documented `.reg` file into your deployment strategy, you ensure consistent and efficient configuration of the PrintService Operational event logs across all target machines in your network.

---

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# Contact

For any questions or support, please contact [Your Name](mailto:your.email@example.com).

# Acknowledgments

- Inspired by [Your Reference or Inspiration].

# Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.
