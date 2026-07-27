# Coding Standards - Rust

- Use the stable toolchain and the repository's declared minimum supported Rust version.
- Prefer ownership and borrowing over cloning; make lifetimes understandable rather than artificially complex.
- Use traits at genuine behavioural or external boundaries, not for every type.
- Prefer concrete internal types, enums and responsibility-named modules.
- Model valid states with types; use `Result` and domain errors instead of panics in recoverable paths.
- Avoid `unwrap` and `expect` in production paths unless an invariant is documented and locally evident.
- Keep `unsafe` isolated, minimal, documented with safety invariants and covered by focused tests.
- Avoid hidden global state, blocking work in async executors and holding locks across `.await`.
- Apply rustfmt and Clippy; document public APIs and important concurrency guarantees.
