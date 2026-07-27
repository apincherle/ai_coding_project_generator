using CustomerApi;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;

const string CorrelationIdHeader = "X-Correlation-ID";

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<ICustomerRepository, InMemoryCustomerRepository>();
builder.Services.AddScoped<CustomerService>();
builder.Services.AddOpenApi();
builder.Services.AddHealthChecks();

// Bound the accepted request body size as a defence-in-depth control; the reverse proxy/ingress
// in front of this service should also enforce a body size limit at the edge.
builder.WebHost.ConfigureKestrel(options => options.Limits.MaxRequestBodySize = 1_000_000);

// Drain in-flight requests before the process exits. Kubernetes/containers send SIGTERM; the
// host's default shutdown timeout can be raised via HostOptions.ShutdownTimeout if requests
// routinely take longer than the default 30 seconds to complete.
builder.Services.Configure<HostOptions>(options => options.ShutdownTimeout = TimeSpan.FromSeconds(30));

var app = builder.Build();
app.MapOpenApi();

app.Use(async (context, next) =>
{
    var correlationId = context.Request.Headers.TryGetValue(CorrelationIdHeader, out var existing) &&
        existing.Count > 0 && !string.IsNullOrWhiteSpace(existing[0])
        ? existing[0]!
        : Guid.NewGuid().ToString();
    context.Items[CorrelationIdHeader] = correlationId;
    context.Response.OnStarting(() =>
    {
        context.Response.Headers[CorrelationIdHeader] = correlationId;
        return Task.CompletedTask;
    });
    await next();
});

// Liveness: the process is up and able to serve requests.
app.MapHealthChecks("/health");

// Readiness: dependencies are reachable. No checks are registered yet, so this is always healthy;
// register a real check tagged "ready" (e.g. a datastore ping) once a backing store is introduced.
app.MapHealthChecks("/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
});

var customers = app.MapGroup("/api/v1/customers");
customers.MapGet(
    "/{id:guid}",
    (Guid id, CustomerService service) =>
    {
        var customer = service.Get(id);
        return customer is null ? Results.NotFound() : Results.Ok(customer);
    });
customers.MapPost(
    "/",
    (CreateCustomerRequest request, CustomerService service) =>
    {
        if (string.IsNullOrWhiteSpace(request.Name) || !request.Email.Contains('@'))
        {
            return Results.ValidationProblem(
                new Dictionary<string, string[]>
                {
                    ["request"] = ["Name and valid email are required."],
                });
        }

        var customer = service.Create(request.Name, request.Email);
        return Results.Created($"/api/v1/customers/{customer.Id}", customer);
    });

app.Run();

public partial class Program;
