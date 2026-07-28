package com.example.customer;

import java.util.UUID;

public final class CustomerNotFoundException extends RuntimeException {
  private static final long serialVersionUID = 1L;

  public CustomerNotFoundException(UUID id) {
    super("Customer not found: " + id);
  }
}
