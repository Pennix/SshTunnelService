# SshTunnelService Uninstaller Script

# This script must be run with Administrator privileges.

param(
    [string]$InstallPath = "C:\Program Files\SshTunnelService"
)

$serviceName = "SshTunnelService"

# --- Stop and Delete the Service ---
Write-Host "Stopping service: $serviceName..." -ForegroundColor Green
Stop-Service -Name $serviceName -ErrorAction SilentlyContinue

Write-Host "Deleting service: $serviceName..." -ForegroundColor Green
sc.exe delete $serviceName

# --- Remove Installation Directory ---
if (Test-Path -Path $InstallPath) {
    $confirmation = Read-Host -Prompt "Do you want to delete the installation directory? (Y/N)"
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        Write-Host "Deleting installation directory: $InstallPath..." -ForegroundColor Green
        Remove-Item -Path $InstallPath -Recurse -Force
    }
}

Write-Host "Uninstallation complete." -ForegroundColor Yellow
