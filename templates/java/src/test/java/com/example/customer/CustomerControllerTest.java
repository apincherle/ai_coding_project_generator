package com.example.customer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

class CustomerControllerTest {
  private final CustomerService service = mock(CustomerService.class);
  private final CustomerController controller = new CustomerController(service);

  @Test
  void getDelegatesToService() {
    UUID id = UUID.randomUUID();
    Customer customer = new Customer(id, "Alice", "alice@example.com");
    when(service.get(id)).thenReturn(customer);

    Customer result = controller.get(id);

    assertThat(result).isSameAs(customer);
  }

  @Test
  void createReturnsCreatedWithLocation() {
    CustomerRequest request = new CustomerRequest("Bob", "bob@example.com");
    UUID id = UUID.randomUUID();
    when(service.create(request)).thenReturn(new Customer(id, "Bob", "bob@example.com"));

    ResponseEntity<Customer> response = controller.create(request);

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    assertThat(response.getHeaders().getLocation()).hasToString("/api/v1/customers/" + id);
    assertThat(response.getBody()).isNotNull();
    assertThat(response.getBody().name()).isEqualTo("Bob");
  }

  @Test
  void updateDelegatesToService() {
    UUID id = UUID.randomUUID();
    CustomerRequest request = new CustomerRequest("Carol", "carol@example.com");
    Customer updated = new Customer(id, "Carol", "carol@example.com");
    when(service.update(id, request)).thenReturn(updated);

    Customer result = controller.update(id, request);

    assertThat(result).isEqualTo(updated);
  }

  @Test
  void deleteReturnsNoContent() {
    UUID id = UUID.randomUUID();

    ResponseEntity<Void> response = controller.delete(id);

    verify(service).delete(id);
    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
  }
}
