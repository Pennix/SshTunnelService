using SshTunnelService;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "SshTunnelService";
});

builder.Services.Configure<List<TunnelOptions>>(builder.Configuration.GetSection(TunnelOptions.Tunnels));
builder.Services.AddSingleton<SshTunnelManager>();
builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
