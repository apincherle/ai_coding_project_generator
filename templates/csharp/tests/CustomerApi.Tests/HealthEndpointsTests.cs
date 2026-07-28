using System.Net;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace CustomerApi.Tests;

public sealed class HealthEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public HealthEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task HealthEndpointReturnsHealthy()
    {
        using var client = _factory.CreateClient();

        var response = await client.GetAsync("/health");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadAsStringAsync();
        body.Should().NotBeNullOrWhiteSpace();
    }

    [Fact]
    public async Task ReadyEndpointReturnsHealthy()
    {
        using var client = _factory.CreateClient();

        var response = await client.GetAsync("/ready");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task ResponseIncludesCorrelationIdHeader()
    {
        using var client = _factory.CreateClient();

        var response = await client.GetAsync("/health");

        response.Headers.Contains("X-Correlation-ID").Should().BeTrue();
    }

    [Fact]
    public async Task PropagatesInboundCorrelationId()
    {
        using var client = _factory.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Get, "/health");
        request.Headers.Add("X-Correlation-ID", "req-123");

        var response = await client.SendAsync(request);

        response.Headers.GetValues("X-Correlation-ID").Should().ContainSingle().Which.Should().Be("req-123");
    }
}
