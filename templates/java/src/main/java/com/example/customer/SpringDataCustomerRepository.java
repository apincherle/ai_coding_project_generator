package com.example.customer;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

interface SpringDataCustomerRepository extends JpaRepository<CustomerEntity, UUID> {}
