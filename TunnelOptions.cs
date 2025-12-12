namespace SshTunnelService;

public class TunnelOptions
{
    public const string Tunnels = "Tunnels";

    public string Name { get; set; } = string.Empty;
    public string Host { get; set; } = string.Empty;
    public int Port { get; set; } = 22;
    public string Username { get; set; } = string.Empty;
    public string PrivateKeyPath { get; set; } = string.Empty;
    public string LocalForward { get; set; } = string.Empty;
    public string RemoteForward { get; set; } = string.Empty;
}
