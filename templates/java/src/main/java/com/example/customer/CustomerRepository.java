package com.example.customer;

import java.util.Optional;
import java.util.UUID;

public interface CustomerRepository {
  Optional<Customer> findById(UUID id);

  Customer save(Customer customer);

  void deleteById(UUID id);
}
