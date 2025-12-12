# SshTunnelService

This is a .NET Worker Service that creates and manages SSH tunnels as a Windows Service.

## Configuration

The SSH tunnels are configured in the `appsettings.json` file. You can add one or more tunnels to the `Tunnels` array.

```json
"Tunnels": [
  {
    "Name": "ExampleTunnel",
    "Host": "example.com",
    "Port": 22,
    "Username": "user",
    "PrivateKeyPath": "C:\\Users\\user\\.ssh\\id_rsa",
    "LocalForward": "8080:localhost:80",
    "RemoteForward": ""
  }
]
```

**Make sure to use double backslashes (`\\`) for paths in `appsettings.json`.**

## Build and Publish

1.  **Build the project:**
    ```sh
    dotnet build -c Release
    ```

2.  **Publish the project:**
    Publish the project to a self-contained directory. This will include the .NET runtime and all dependencies.

    ```sh
    dotnet publish -c Release -r win-x64 --self-contained true
    ```
    The published files will be in `bin/Release/net10.0/win-x64/publish/`.

## Install as a Windows Service

1.  **Open PowerShell as an Administrator.**

2.  **Create the service:**
    Use the `sc.exe` command to create the Windows Service. Make sure to provide the full path to the executable in the `binPath` argument.

    ```powershell
    sc.exe create SshTunnelService binPath= "C:\path\to\your\project\bin\Release\net10.0\win-x64\publish\SshTunnelService.exe"
    ```

3.  **Start the service:**
    ```powershell
    sc.exe start SshTunnelService
    ```

4.  **Stop the service:**
    ```powershell
    sc.exe stop SshTunnelService
    ```

5.  **Delete the service:**
    ```powershell
    sc.exe delete SshTunnelService
    ```

## PowerShell Installer Scripts

For easier installation and uninstallation on Windows, you can use the provided PowerShell scripts: `install.ps1` and `uninstall.ps1`.

**Important:** These scripts must be run with Administrator privileges. You might need to adjust your PowerShell execution policy to run them (e.g., `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process` for the current session).

### `install.ps1`

This script automates the setup of the `SshTunnelService` as a Windows Service:
*   Downloads the latest release binary from GitHub (or uses a local ZIP if provided).
*   Prompts you for SSH tunnel configuration parameters (Host, Port, Username, Private Key Path, Local Forwards, Remote Forwards).
*   Copies your private SSH key to a secure location within the installation directory and sets appropriate permissions.
*   Installs the service using `sc.exe`.
*   Starts the service.

**Usage:**
```powershell
.\install.ps1
```

### `uninstall.ps1`

This script automates the removal of the `SshTunnelService`:
*   Stops the running service.
*   Deletes the service using `sc.exe`.
*   Optionally removes the entire installation directory.

**Usage:**
```powershell
.\uninstall.ps1
```

## Logs

The service logs events to the Windows Event Viewer. You can find the logs under "Windows Logs" > "Application" with the source name "SshTunnelService".

```