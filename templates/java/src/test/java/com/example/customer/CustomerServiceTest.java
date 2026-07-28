package com.example.customer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class CustomerServiceTest {
  private final CustomerRepository repository = mock(CustomerRepository.class);
  private final CustomerService service = new CustomerService(repository);

  @Test
  void returnsCustomer() {
    UUID id = UUID.randomUUID();
    when(repository.findById(id))
        .thenReturn(Optional.of(new Customer(id, "Alice", "alice@example.com")));
    Customer result = service.get(id);
    assertThat(result.name()).isEqualTo("Alice");
  }

  @Test
  void reportsMissingCustomer() {
    UUID id = UUID.randomUUID();
    when(repository.findById(id)).thenReturn(Optional.empty());
    assertThatThrownBy(() -> service.get(id))
        .isInstanceOf(CustomerNotFoundException.class)
        .hasMessageContaining(id.toString());
  }

  @Test
  void createsCustomerAndAssertsOutcome() {
    CustomerRequest request = new CustomerRequest("Bob", "bob@example.com");
    when(repository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    Customer result = service.create(request);
    assertThat(result)
        .extracting(Customer::name, Customer::email)
        .containsExactly("Bob", "bob@example.com");
    verify(repository).save(any(Customer.class));
  }

  @Test
  void updatesExistingCustomer() {
    UUID id = UUID.randomUUID();
    when(repository.findById(id))
        .thenReturn(Optional.of(new Customer(id, "Old", "old@example.com")));
    when(repository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

    Customer result = service.update(id, new CustomerRequest("New", "new@example.com"));

    assertThat(result)
        .extracting(Customer::id, Customer::name, Customer::email)
        .containsExactly(id, "New", "new@example.com");
  }

  @Test
  void deleteDelegatesToRepository() {
    UUID id = UUID.randomUUID();

    service.delete(id);

    verify(repository).deleteById(id);
  }
}
