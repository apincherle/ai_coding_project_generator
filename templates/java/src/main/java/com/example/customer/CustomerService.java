package com.example.customer;

import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class CustomerService {
  private final CustomerRepository repository;

  public CustomerService(CustomerRepository repository) {
    this.repository = repository;
  }

  public Customer get(UUID id) {
    return repository.findById(id).orElseThrow(() -> new CustomerNotFoundException(id));
  }

  public Customer create(CustomerRequest request) {
    return repository.save(new Customer(UUID.randomUUID(), request.name(), request.email()));
  }

  public Customer update(UUID id, CustomerRequest request) {
    get(id);
    return repository.save(new Customer(id, request.name(), request.email()));
  }

  public void delete(UUID id) {
    repository.deleteById(id);
  }
}
