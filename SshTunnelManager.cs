using System.Diagnostics;
using Microsoft.Extensions.Options;

namespace SshTunnelService;

public class SshTunnelManager : IDisposable
{
    private readonly ILogger<SshTunnelManager> _logger;
    private readonly List<TunnelOptions> _tunnels;
    private readonly List<Process> _processes = new();

    public SshTunnelManager(ILogger<SshTunnelManager> logger, IOptions<List<TunnelOptions>> tunnels)
    {
        _logger = logger;
        _tunnels = tunnels.Value;
    }

    public void StartTunnels()
    {
        foreach (var tunnel in _tunnels)
        {
            StartTunnel(tunnel);
        }
    }

    private void StartTunnel(TunnelOptions tunnel)
    {
        var arguments = $"-N -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -i \"{tunnel.PrivateKeyPath}\" {tunnel.Username}@{tunnel.Host} -p {tunnel.Port}";
        foreach (var forward in tunnel.LocalForward)
        {
            if (!string.IsNullOrEmpty(forward))
            {
                arguments += $" -L {forward}";
            }
        }
        foreach (var forward in tunnel.RemoteForward)
        {
            if (!string.IsNullOrEmpty(forward))
            {
                arguments += $" -R {forward}";
            }
        }

        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "ssh",
                Arguments = arguments,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            },
            EnableRaisingEvents = true
        };

        process.Exited += (sender, e) =>
        {
            _logger.LogWarning("Tunnel '{Name}' exited. Restarting...", tunnel.Name);
            StartTunnel(tunnel);
        };

        process.OutputDataReceived += (sender, e) => { if (e.Data != null) _logger.LogInformation(e.Data); };
        process.ErrorDataReceived += (sender, e) => { if (e.Data != null) _logger.LogError(e.Data); };

        _logger.LogInformation("Starting tunnel '{Name}' with arguments: {Arguments}", tunnel.Name, arguments);
        process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        _processes.Add(process);
    }

    public void Dispose()
    {
        foreach (var process in _processes)
        {
            if (!process.HasExited)
            {
                process.Kill();
            }
            process.Dispose();
        }
    }
}