namespace CustomerApi;

public sealed record Customer(Guid Id, string Name, string Email);

public sealed record CreateCustomerRequest(string Name, string Email);

public interface ICustomerRepository
{
    Customer? FindById(Guid id);

    Customer Save(Customer customer);
}

public sealed class InMemoryCustomerRepository : ICustomerRepository
{
    private readonly Dictionary<Guid, Customer> _customers = [];

    public Customer? FindById(Guid id) => _customers.GetValueOrDefault(id);

    public Customer Save(Customer customer)
    {
        _customers[customer.Id] = customer;
        return customer;
    }
}

public sealed class CustomerService(ICustomerRepository repository)
{
    public Customer? Get(Guid id) => repository.FindById(id);

    public Customer Create(string name, string email) =>
        repository.Save(new Customer(Guid.NewGuid(), name, email));
}
