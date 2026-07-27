package com.example.customer;
import java.util.UUID;
public record Customer(UUID id, String name, String email) {}
