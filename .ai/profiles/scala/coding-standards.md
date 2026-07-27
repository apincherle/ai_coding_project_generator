# Coding Standards - Scala

- Use Scala 3 and the documented JDK/build-tool matrix.
- Prefer immutable data, total functions and explicit domain types.
- Use traits at genuine capability, algebra or external boundaries; do not create a trait for every class.
- Prefer concrete internal implementations and responsibility-named modules over generic helpers.
- Keep effect types, execution context and blocking boundaries explicit and consistent with the selected stack.
- Avoid `null`, mutable global state, unsafe casts and unbounded blocking in asynchronous code.
- Model expected failures with typed errors or the project-approved effect/error mechanism.
- Keep implicits/givens discoverable and narrow; avoid clever type-level designs without a demonstrated benefit.
- Apply Scalafmt and Scalafix and treat configured compiler warnings as errors.
