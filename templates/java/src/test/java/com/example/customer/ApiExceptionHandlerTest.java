package com.example.customer;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;

class ApiExceptionHandlerTest {
  private final ApiExceptionHandler handler = new ApiExceptionHandler();

  @Test
  void mapsNotFoundToProblemDetail() {
    UUID id = UUID.randomUUID();
    CustomerNotFoundException exception = new CustomerNotFoundException(id);

    ProblemDetail detail = handler.notFound(exception);

    assertThat(detail.getStatus()).isEqualTo(HttpStatus.NOT_FOUND.value());
    assertThat(detail.getTitle()).isEqualTo("Customer not found");
    assertThat(detail.getDetail()).contains(id.toString());
    assertThat(detail.getType()).hasToString("https://example.com/problems/customer-not-found");
  }
}
