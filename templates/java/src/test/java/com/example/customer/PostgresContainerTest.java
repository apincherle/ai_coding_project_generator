package com.example.customer;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;

class PostgresContainerTest {
  @Test
  void startsRealPostgres() {
    try (PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine")) {
      postgres.start();
      assertThat(postgres.isRunning()).isTrue();
    }
  }
}
