using FluentAssertions;
using NSubstitute;
using Xunit;

namespace CustomerApi.Tests;

public sealed class CustomerServiceTests
{
    [Fact]
    public void ReturnsCustomer()
    {
        var customer = new Customer(Guid.NewGuid(), "Alice", "alice@example.com");
        var repository = Substitute.For<ICustomerRepository>();
        repository.FindById(customer.Id).Returns(customer);

        var result = new CustomerService(repository).Get(customer.Id);

        result.Should().BeEquivalentTo(customer);
    }

    [Fact]
    public void CreatesCustomerWithMeaningfulOutcome()
    {
        var repository = Substitute.For<ICustomerRepository>();
        repository.Save(Arg.Any<Customer>()).Returns(call => call.Arg<Customer>());

        var result = new CustomerService(repository).Create("Bob", "bob@example.com");

        result.Name.Should().Be("Bob");
        result.Email.Should().Be("bob@example.com");
        result.Id.Should().NotBeEmpty();
    }
}
