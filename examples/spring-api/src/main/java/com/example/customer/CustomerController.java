package com.example.customer;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/customers")
public class CustomerController {
  private final CustomerService service;

  public CustomerController(CustomerService service) {
    this.service = service;
  }

  @GetMapping("/{id}")
  public Customer get(@PathVariable UUID id) {
    return service.get(id);
  }

  @PostMapping
  public ResponseEntity<Customer> create(@Valid @RequestBody CustomerRequest request) {
    Customer created = service.create(request);
    return ResponseEntity.created(URI.create("/api/v1/customers/" + created.id())).body(created);
  }

  @PutMapping("/{id}")
  public Customer update(@PathVariable UUID id, @Valid @RequestBody CustomerRequest request) {
    return service.update(id, request);
  }

  @DeleteMapping("/{id}")
  public ResponseEntity<Void> delete(@PathVariable UUID id) {
    service.delete(id);
    return ResponseEntity.noContent().build();
  }
}
