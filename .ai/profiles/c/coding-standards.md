# Coding Standards - C

- Use ISO C23 features only when supported by the documented compiler matrix.
- Compile with high warning levels and treat warnings as errors in CI.
- Make ownership, lifetime, allocation and cleanup responsibilities explicit.
- Validate sizes, indexes, enum values, pointers and all untrusted input before use.
- Use checked arithmetic for attacker-controlled or size-related calculations.
- Prefer small modules with opaque types and narrow public headers.
- Use function pointers or interface structs only at genuine substitution or platform boundaries.
- Avoid generic utility dumping grounds, hidden mutable globals, macro-based control flow and unsafe string APIs.
- Pair every acquired resource with one clear cleanup path; make error propagation explicit.
- Document thread-safety, reentrancy, endian, alignment and platform assumptions.
