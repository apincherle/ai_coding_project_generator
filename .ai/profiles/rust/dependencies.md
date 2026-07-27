# Dependency Policy - Rust

Use crates.io or approved registries with a committed `Cargo.lock` for applications.
Review licence, provenance, maintenance, advisories, feature flags, build scripts and transitive crates.
Use `cargo audit` and `cargo deny` according to organisational policy.
Minimise enabled features and reject crates that require unjustified unsafe code or untrusted build execution.
