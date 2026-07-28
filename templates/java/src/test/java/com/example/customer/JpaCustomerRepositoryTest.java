package com.example.customer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class JpaCustomerRepositoryTest {
  private final SpringDataCustomerRepository delegate = mock(SpringDataCustomerRepository.class);
  private final JpaCustomerRepository repository = new JpaCustomerRepository(delegate);

  @Test
  void findByIdMapsEntityToDomain() {
    UUID id = UUID.randomUUID();
    Customer domain = new Customer(id, "Alice", "alice@example.com");
    when(delegate.findById(id)).thenReturn(Optional.of(new CustomerEntity(domain)));

    Optional<Customer> result = repository.findById(id);

    assertThat(result).contains(domain);
  }

  @Test
  void savePersistsAndReturnsDomain() {
    Customer customer = new Customer(UUID.randomUUID(), "Bob", "bob@example.com");
    when(delegate.save(any(CustomerEntity.class)))
        .thenAnswer(invocation -> invocation.getArgument(0));

    Customer result = repository.save(customer);

    assertThat(result).isEqualTo(customer);
  }

  @Test
  void deleteByIdDelegates() {
    UUID id = UUID.randomUUID();

    repository.deleteById(id);

    verify(delegate).deleteById(id);
  }
}
