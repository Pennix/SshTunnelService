namespace SshTunnelService;

public class TunnelOptions
{
    public const string Tunnels = "Tunnels";

    public string Name { get; set; } = string.Empty;
    public string Host { get; set; } = string.Empty;
    public int Port { get; set; } = 22;
    public string Username { get; set; } = string.Empty;
    public string PrivateKeyPath { get; set; } = string.Empty;
    public List<string> LocalForward { get; set; } = new();
    public List<string> RemoteForward { get; set; } = new();
}
