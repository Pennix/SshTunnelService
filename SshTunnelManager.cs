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
        if (!string.IsNullOrEmpty(tunnel.LocalForward))
        {
            arguments += $