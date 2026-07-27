package com.example.customer;

import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Repository;

@Repository
class JpaCustomerRepository implements CustomerRepository {
  private final SpringDataCustomerRepository delegate;

  JpaCustomerRepository(SpringDataCustomerRepository delegate) {
    this.delegate = delegate;
  }

  @Override
  public Optional<Customer> findById(UUID id) {
    return delegate.findById(id).map(CustomerEntity::toDomain);
  }

  @Override
  public Customer save(Customer customer) {
    return delegate.save(new CustomerEntity(customer)).toDomain();
  }

  @Override
  public void deleteById(UUID id) {
    delegate.deleteById(id);
  }
}
