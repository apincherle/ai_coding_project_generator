# Coding Standards - C++

- Use C++23 only within the documented compiler and standard-library matrix.
- Follow RAII; express ownership with values and smart pointers. Avoid owning raw pointers.
- Prefer value semantics, standard-library facilities and scoped resource wrappers.
- Use interfaces or templates at genuine substitution, platform or policy boundaries; do not abstract every class.
- Prefer concrete internal types and responsibility-named collaborators over generic helpers.
- Avoid macros except for narrow portability/build needs; avoid global mutable state and unchecked casts.
- Make exception, error, thread-safety, ABI and lifetime contracts explicit.
- Validate ranges and sizes; use safe views such as `std::span` and `std::string_view` only with valid lifetimes.
- Keep headers minimal, preserve binary compatibility when required and treat warnings as errors.
