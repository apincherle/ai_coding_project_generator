package com.example.customer;

import java.util.UUID;

public final class CustomerNotFoundException extends RuntimeException {
  public CustomerNotFoundException(UUID id) {
    super("Customer not found: " + id);
  }
}
