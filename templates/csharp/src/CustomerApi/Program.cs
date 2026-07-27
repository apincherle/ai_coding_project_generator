using CustomerApi;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<ICustomerRepository, InMemoryCustomerRepository>();
builder.Services.AddScoped<CustomerService>();
builder.Services.AddOpenApi();

var app = builder.Build();
app.MapOpenApi();

var customers = app.MapGroup("/api/v1/customers");
customers.MapGet("/{id:guid}", (Guid id, CustomerService service) =>
{
    var customer = service.Get(id);
    return customer is null ? Results.NotFound() : Results.Ok(customer);
});
customers.MapPost("/", (CreateCustomerRequest request, CustomerService service) =>
{
    if (string.IsNullOrWhiteSpace(request.Name) || !request.Email.Contains('@'))
        return Results.ValidationProblem(new Dictionary<string, string[]> { ["request"] = ["Name and valid email are required."] });
    var customer = service.Create(request.Name, request.Email);
    return Results.Created($"/api/v1/customers/{customer.Id}", customer);
});

app.Run();
public partial class Program;
