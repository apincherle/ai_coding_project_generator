package com.example.customer;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "customers")
class CustomerEntity {
  @Id private UUID id;
  private String name;
  private String email;

  protected CustomerEntity() {}

  CustomerEntity(Customer customer) {
    this.id = customer.id();
    this.name = customer.name();
    this.email = customer.email();
  }

  Customer toDomain() {
    return new Customer(id, name, email);
  }
}
