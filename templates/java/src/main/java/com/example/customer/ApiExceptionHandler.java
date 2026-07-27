package com.example.customer;

import java.net.URI;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
class ApiExceptionHandler {
  @ExceptionHandler(CustomerNotFoundException.class)
  ProblemDetail notFound(CustomerNotFoundException exception) {
    ProblemDetail detail =
        ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, exception.getMessage());
    detail.setType(URI.create("https://example.com/problems/customer-not-found"));
    detail.setTitle("Customer not found");
    return detail;
  }
}
