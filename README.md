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

## Logs

The service logs events to the Windows Event Viewer. You can find the logs under "Windows Logs" > "Application" with the source name "SshTunnelService".

```