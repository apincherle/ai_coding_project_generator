# Testing Standard - C

Use CMocka or Unity with CTest and the repository-approved test runner.
Test observable return values, output buffers, state transitions and error codes.
Use fakes or function-pointer boundaries for operating-system, device, clock, network and storage dependencies.
Every test must contain a meaningful assertion; call-count verification alone is insufficient.
Run AddressSanitizer and UndefinedBehaviorSanitizer where supported, plus leak and valgrind-style checks on
the designated platform. Add fuzz/property tests for parsers, protocols and binary formats.
