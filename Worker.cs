namespace SshTunnelService;

public class Worker(ILogger<Worker> logger, SshTunnelManager tunnelManager) : BackgroundService
{
    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        logger.LogInformation("Worker starting at: {time}", DateTimeOffset.Now);

        tunnelManager.StartTunnels();

        stoppingToken.Register(() =>
        {
            logger.LogInformation("Worker stopping at: {time}", DateTimeOffset.Now);
            tunnelManager.Dispose();
        });

        return Task.CompletedTask;
    }
}
