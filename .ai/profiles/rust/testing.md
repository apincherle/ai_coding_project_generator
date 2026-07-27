# Testing Standard - Rust

Use built-in unit and integration tests, proptest for invariant-rich logic and Testcontainers for external systems.
Test observable values, state, errors and persistence effects.
Use traits, fakes or mockall only at genuine external boundaries.
Every test must contain a meaningful assertion about an outcome; mock expectations alone are insufficient.
Test cancellation, concurrency and async failure paths where relevant. Use Miri, sanitizers or loom for high-risk
unsafe or concurrent code when supported by the project.
