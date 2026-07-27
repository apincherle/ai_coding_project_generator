# Testing Standard - C++

Use GoogleTest and GoogleMock with CTest.
Test observable values, state, exceptions/errors and resource behaviour.
Mock external or platform boundaries, not every internal class. Prefer fakes and real value objects.
Every test must contain a meaningful assertion; interaction expectations alone are insufficient.
Run sanitizers where supported and add fuzz/property tests for parsers, serialization and unsafe inputs.
Test move/copy behaviour, lifetimes, concurrency and ABI-sensitive paths when relevant.
