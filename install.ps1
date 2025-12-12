# SshTunnelService Installer Script

# This script must be run with Administrator privileges.
# You may need to adjust your execution policy to run this script.
# You can do so for the current process by running:
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

param(
    [string]$InstallPath = "C:\Program Files\SshTunnelService"
)

# --- Add Windows Forms Assembly for File Dialogs ---
Add-Type -AssemblyName System.Windows.Forms

# --- Gather SSH Tunnel Parameters ---
Write-Host "Please provide the details for your SSH tunnel." -ForegroundColor Cyan

$tunnelName = Read-Host -Prompt "Tunnel Name (e.g., MyServerTunnel)"
$tunnelHost = Read-Host -Prompt "SSH Host (e.g., ssh.example.com)"
$portInput = Read-Host -Prompt "SSH Port (default: 22)"
if ([string]::IsNullOrWhiteSpace($portInput)) { $tunnelPort = "22" } else { $tunnelPort = $portInput }
$tunnelUsername = Read-Host -Prompt "SSH Username"

$tunnel = @{
    Name = $tunnelName
    Host = $tunnelHost
    Port = $tunnelPort
    Username = $tunnelUsername
}

# File selector for PrivateKeyPath
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = [Environment]::GetFolderPath('UserProfile') + "\.ssh"
$openFileDialog.Filter = "All Files (*.*)|*.*"
$openFileDialog.Title = "Select your SSH Private Key"
if ($openFileDialog.ShowDialog() -eq "OK") {
    $originalKeyPath = $openFileDialog.FileName
} else {
    $originalKeyPath = Read-Host -Prompt "Path to your SSH Private Key (file dialog cancelled, please enter manually)"
}

$tunnel.LocalForward = (Read-Host -Prompt "Local Forwards (comma-separated, e.g., 8080:localhost:80,8443:localhost:443)").Split(',') | ForEach-Object { $_.Trim() }
$tunnel.RemoteForward = (Read-Host -Prompt "Remote Forwards (comma-separated, e.g., 8888:localhost:8888)").Split(',') | ForEach-Object { $_.Trim() }

# --- Create Secure Key Directory and Copy Key ---
$secureKeyPath = Join-Path $InstallPath "keys"
New-Item -ItemType Directory -Force -Path $secureKeyPath
$originalKeyFileName = Split-Path -Path $originalKeyPath -Leaf
$newKeyPath = Join-Path $secureKeyPath $originalKeyFileName
Copy-Item -Path $originalKeyPath -Destination $newKeyPath

# Set permissions to LocalSystem only
icacls.exe $newKeyPath /inheritance:r /grant "NT AUTHORITY\SYSTEM:(R)"
$tunnel.PrivateKeyPath = $newKeyPath

# --- Create appsettings.json content ---
$appSettings = @{
    Logging = @{
        LogLevel = @{
            Default = "Information"
            "Microsoft.Hosting.Lifetime" = "Information"
        }
    }
    Tunnels = @(
        $tunnel
    )
}
$appSettingsJson = $appSettings | ConvertTo-Json -Depth 5

# --- Prompt for Local Release File ---
Write-Host ""
Write-Host "Select local release ZIP file, or close dialog to download from GitHub." -ForegroundColor Cyan

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = Get-Location
$openFileDialog.Filter = "ZIP Files (*.zip)|*.zip|All Files (*.*)|*.*"
$openFileDialog.Title = "Select local release ZIP file"
$downloaded = $false
if ($openFileDialog.ShowDialog() -eq "OK" -and (Test-Path $openFileDialog.FileName)) {
    $zipPath = $openFileDialog.FileName
    Write-Host "Using local release file: $zipPath" -ForegroundColor Green
} else {
    # --- Download Release ---
    $releaseUrl = "https://github.com/Pennix/SshTunnelService/releases/download/v1.1.0/SshTunnelService-v1.1.0-win-x64.zip"
    $zipPath = Join-Path $env:TEMP "SshTunnelService.zip"

    Write-Host "Downloading release from $releaseUrl..." -ForegroundColor Green
    Invoke-WebRequest -Uri $releaseUrl -OutFile $zipPath
    $downloaded = $true
}

# --- Unzip Release ---
Write-Host "Creating installation directory: $InstallPath" -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $InstallPath

Write-Host "Extracting files to $InstallPath..." -ForegroundColor Green
Expand-Archive -Path $zipPath -DestinationPath $InstallPath -Force

# --- Write the new appsettings.json ---
Write-Host "Configuring SSH tunnel..." -ForegroundColor Green
Set-Content -Path (Join-Path $InstallPath "appsettings.json") -Value $appSettingsJson

# --- Install and Start the Service ---
$serviceName = "SshTunnelService"
$serviceExe = Join-Path $InstallPath "SshTunnelService.exe"

Write-Host "Creating Windows Service: $serviceName" -ForegroundColor Green
sc.exe create $serviceName binPath= "$serviceExe"

Write-Host "Starting service..." -ForegroundColor Green
Start-Service -Name $serviceName

# --- Cleanup ---
if ($downloaded) {
    Remove-Item -Path $zipPath
}

Write-Host "Installation complete! The SshTunnelService is now running." -ForegroundColor Yellow
